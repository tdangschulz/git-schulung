# Demo 15 — Git Internals: Was passiert im Hintergrund?

Zeigt live was Git tatsächlich macht — `.git`-Ordner, Objekte, Branches als Pointer, Three Trees, Reflog.

## Befehlsablauf

### 1. Der `.git` Ordner — das Herz

```bash
cd start

# Vollständige Baumstruktur
find .git -type f | head -20

# Was ist HEAD?
cat .git/HEAD
# → ref: refs/heads/main

# Ein Branch ist nur eine Datei mit einem Hash
cat .git/refs/heads/main
```

**Erklärung:** `.git/HEAD` zeigt auf den aktuellen Branch. Der Branch selbst ist nur eine Datei mit einem 40-stelligen SHA-1 Hash. Mehr nicht.

### 2. Objekte erkunden — Blobs, Trees, Commits

```bash
# Alle Objekte im Speicher
find .git/objects -type f

# Den aktuellen Commit anschauen
git cat-file -p HEAD
# → tree hash, parent hash, author, message

# Den Tree (Ordnerstruktur) anschauen
git cat-file -p HEAD^{tree}
# → readme.md → blob hash
# → src/ → tree hash (Unterordner!)

# Den Blob (Dateiinhalt) anschauen — z.B. readme.md
git cat-file -p HEAD:readme.md

# Typ des Objekts herausfinden
git cat-file -t HEAD      # → commit
git cat-file -t HEAD^{tree}  # → tree
git cat-file -t HEAD:readme.md  # → blob
```

**Erklärung:** Git kennt nur 4 Objekttypen. `git cat-file -p` zeigt den Inhalt, `-t` den Typ.

### 3. SHA-1 — Wie der Hash entsteht

```bash
# Gleicher Inhalt = gleicher Hash
echo "Hallo Git" | git hash-object --stdin

# Anderer Inhalt = anderer Hash
echo "Hallo Git Welt" | git hash-object --stdin

# Der Hash ist: sha1("blob <groesse>\0<inhalt>")
echo -n "Hallo Git" | wc -c       # → 10
printf "blob 10\0Hallo Git" | sha1sum

# Ist identisch! (mit git hash-object)
git hash-object --stdin < <(echo -n "Hallo Git")
```

**Erklärung:** Der Hash ist 100% deterministisch. Gleicher Inhalt = gleicher Hash, auf jedem Rechner weltweit.

### 4. Snapshots, nicht Diffs

```bash
# Jeder Commit hat einen KOMPLETTEN Tree
# -> Vergleiche Tree-Hashes verschiedener Commits:
git cat-file -p HEAD^{tree}
git cat-file -p HEAD~1^{tree}

# Unveränderte Dateien teilen sich denselben Blob-Hash!
# -> src/version.py wurde nie geändert
git rev-parse HEAD:src/version.py
git rev-parse HEAD~1:src/version.py
# → Identisch!
```

**Erklärung:** Git speichert Snapshots, keine Diffs. Unveränderte Dateien teilen denselben Hash → werden nur einmal gespeichert.

### 5. Die Drei Bäume (Three Trees)

```bash
# AUSGANGSLAGE: Alles sauber
git status

# 1. HEAD = letzter Commit
git rev-parse HEAD

# 2. Index = aktuelles Staging  (identisch mit HEAD)
git diff --cached   # → nichts (HEAD == Index)

# 3. Working Directory = deine Dateien (identisch mit Index)
git diff            # → nichts (Index == Working Dir)

# ÄNDERUNG: Datei bearbeiten
echo "Neuer Inhalt" > readme.md

# Working Dir ≠ Index!
git diff            # → zeigt Änderung

# ADDEN: Kopiert von Working Dir → Index
git add readme.md
git diff            # → nichts (Working Dir == Index)
git diff --cached   # → zeigt Änderung (HEAD ≠ Index)

# COMMIT: Friert den Index als Tree ein
git commit -m "FEAT: Neuer Inhalt"
# → Neuer Commit, neuer Tree
# → Alte Objekte existieren weiter!
```

### 6. Branches sind nur Post-it-Zettel

```bash
# Aktuelle Position
cat .git/refs/heads/main
git rev-parse HEAD
# → Identisch! Der Branch IST der Pointer.

# Neuen Branch anlegen = neue Datei
git branch feature/neu
cat .git/refs/heads/feature/neu
# → Gleicher Hash wie main

# Löschen = Datei löschen (Commits bleiben!)
git branch -D feature/neu
cat .git/refs/heads/feature/neu  # → weg
git log --oneline                # → Commits noch da!
```

**Erklärung:** Ein Branch ist wirklich nur eine Datei mit einem Hash. Löschen = Zeiger weg. Der Garbage Collector räumt erst nach 90 Tagen auf.

### 7. Der Reflog — dein Rettungsnetz

```bash
# Alle HEAD-Bewegungen der letzten 90 Tage
git reflog

# Auch gelöschte Branches sind noch da!
# Einen "weggeworfenen" Commit wiederherstellen:
git reflog
# 1a2b3c4 HEAD@{2}: commit: FEAT: Add greet function
git branch wiederhergestellt 1a2b3c4
```

**Erklärung:** Der Reflog zeichnet ALLE HEAD-Änderungen auf. Erst wenn der Reflog-Eintrag nach 90 Tagen abläuft, kann Git wirklich löschen.

### 8. Feature-Branch — Live verfolgen

```bash
git switch feature/hallo-name

# Nach dem Switch: HEAD und Branch zeigen woanders hin!
cat .git/HEAD               # → ref: refs/heads/feature/hallo-name
git rev-parse HEAD          # → anderer Hash
git merge-base main feature/hallo-name  # → gemeinsamer Vorfahr

# Der 3-Way-Merge-Vergleich:
git show feature/hallo-name:src/app.py
git show main:src/app.py
git show $(git merge-base main feature/hallo-name):src/app.py
```

## ⚠️ Typische Praxisprobleme

**❗ `git cat-file -p` gibt nichts aus:** Der Hash ist falsch oder das Objekt wurde gelöscht (GC).
→ Komplette Objekt-ID verwenden oder Tab-Completion.

**❗ Verwirrung mit `HEAD^{tree}`:** Die geschweiften Klammern müssen im Terminal escaped werden.
→ Bash: `git cat-file -p 'HEAD^{tree}'` oder TAB-Taste nach `HEAD^` drücken.

**❗ Reflog zu lang:** Nach Monaten voller Einträge unübersichtlich.
→ `git reflog expire --expire=now --all` zum Zurücksetzen.

**❗ Ältere Commits haben andere Hashes auf verschiedenen Rechnern:** Nein! Gleicher Inhalt = gleicher Hash.
→ Bei unterschiedlichen Hashes: unterschiedlicher Inhalt (unterschiedlicher Parent, Tree, Timestamp, Author).
