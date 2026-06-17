# Demo 15 — Git Internals: Was passiert im Hintergrund?

Zeigt live was Git tatsächlich macht — `.git`-Ordner, Objekte, Branches als Pointer, Three Trees, Reflog. Perfekt um das tiefe Verständnis zu vermitteln was Git wirklich ist: ein Content-adressable Storage mit Snapshots.

## Befehlsablauf

### 1. Der `.git` Ordner — das Herz von Git

Jedes Git-Repository hat einen versteckten `.git` Ordner. Hier liegt ALLES was Git über dein Projekt weiß. Kein externes System, keine Cloud — ein Ordner. Kopierst du das Repo, hast du alles dabei.

```bash
cd start

# Vollständige Baumstruktur — das ist Git in echt
find .git -type f | head -20
# → .git/HEAD
# → .git/config
# → .git/description
# → .git/objects/1a/2b3c4d...
# → .git/refs/heads/main
# → .git/logs/HEAD

# Was ist HEAD? Ein Zeiger auf den aktuellen Branch
cat .git/HEAD
# → ref: refs/heads/main
# HEAD zeigt nicht direkt auf einen Commit,
# sondern auf den Branch-Namen. Der Branch zeigt auf den Commit.
# Git fragt also: HEAD → "main" → Hash

# Ein Branch ist nur eine Datei mit einem Hash
cat .git/refs/heads/main
# → 73de0724...
# Das wars. 40 Hex-Zeichen. Ein Branch kostet dich 41 Byte.
# Jeder Branch, jeder Tag — alles nur Dateien mit Hashes.
```

**Erklärung warum das wichtig ist:** Weil Branches so billig sind, macht Git keine Aufhebens darum. Ein neuer Branch kostet nichts. `git branch feature/xyz` schreibt 41 Byte in eine Datei. Fertig. Deshalb ist Git so anders als SVN oder CVS — dort war ein Branch ein teurer Kopiervorgang vom gesamten Repository. In Git: 41 Byte.

### 2. Objekte erkunden — Blobs, Trees, Commits

Git kennt genau 4 Objekttypen. Alles andere (Branches, Tags, Stash) sind Zeiger auf diese Objekte. Die Objekte liegen im `.git/objects/` Ordner, albtraumhaft organisiert: erster Hex-Zeichen = Ordnername, restliche 38 = Dateiname.

```bash
# Alle Objekte im Speicher auflisten
find .git/objects -type f
# → .git/objects/c4/9b...
# → .git/objects/ab/cd...
# Git packt SHA-1 Hash in 2-stelligen Ordner + 38-stelligen Dateinamen
# Weil: zu viele Dateien in einem Ordner = langsam

# Commit anschauen — was in einem Commit wirklich drin steckt
git cat-file -p HEAD
# → tree c49b...
# → parent 0d71be5... (erstes Commit hat keinen parent)
# → author openClaw ...
# → committer openClaw ...
#
#     FEAT: Add greet function

# Der Tree — die Ordnerstruktur zum Zeitpunkt des Commits
git cat-file -p HEAD^{tree}
# → 100644 blob abc123... readme.md
# → 040000 tree def456... src/

# src/ ist ein Unterordner → zeigt auf einen weiteren Tree
git cat-file -p 'HEAD^{tree}:src/'
# Git speichert Ordner ebenfalls als Tree-Objekt!

# Ein Blob — der Inhalt einer Datei
git cat-file -p HEAD:readme.md
# → "Hallo Git Welt"
# Kein Dateiname! 
# Der Dateiname steht im Tree, der Inhalt im Blob.
# Deshalb: Datei umbenennen = neuer Tree, gleicher Blob → kein Speicherverbrauch!

# Typ des Objekts bestimmen
git cat-file -t HEAD              # → commit
git cat-file -t 'HEAD^{tree}'     # → tree
git cat-file -t HEAD:readme.md    # → blob
```

**Erklärung des Objektmodells:** Stell dir vor du baust einen LEGO-Turm. Der **Commit** ist ein Foto des Turms zu einem bestimmten Zeitpunkt. Der **Tree** ist die Bauanleitung: "Hier steht ein roter Stein, hier ein blauer..." Der **Blob** ist der einzelne Stein selbst — sein Wert, nicht sein Platz. Wenn du den Turm veränderst und ein Stein bleibt gleich, ist es immer noch DERSELBE Stein (gleicher Hash). Darum ist Git so effizient: Schnappschüsse, aber ohne Speicherverschwendung.

### 3. SHA-1 — Wie der Hash entsteht

Jedes Objekt hat eine eindeutige ID, die aus seinem Inhalt berechnet wird. Dieser Hash ist 100% deterministisch: Gleicher Inhalt = gleicher Hash, auf jedem Rechner, in jeder Zeitzone, heute wie in 10 Jahren.

```bash
# Der einfachste Fall: Ein Blob aus dem Nichts
echo "Hallo Git" | git hash-object --stdin
# → c49b... (ein SHA-1 Hash)
# Die Pipe schickt "Hallo Git\n" an hash-object

# Kleine Änderung → völlig anderer Hash
echo "Hallo Git Welt" | git hash-object --stdin
# → 123abc... (völlig anderer Hash, obwohl nur 4 Zeichen mehr!)

# So entsteht der Hash (Git-Interna)
echo -n "Hallo Git" | wc -c          # → 9 (ohne newline)
printf "blob 9\0Hallo Git" | sha1sum
# → c49b... (IDENTISCH mit git hash-object!)
# Git schreibt: "blob <Laenge>\0<Inhalt>" und hasht das.

# Darum: Datei umbenennen → gleicher Hash
echo "readme" | git hash-object --stdin
echo "readme2" | git hash-object --stdin
# Wenn die Datei gleichen Inhalt hat: GLEICHER Hash!
# Der Dateiname steckt im Tree, nicht im Blob.
```

**Erklärung warum kryptografische Hashes:** SHA-1 ist ein kryptografischer Hash. Git vertraut darauf, dass zwei unterschiedliche Inhalte NIE denselben Hash erzeugen. Das bedeutet: Wenn zwei Objekte denselben Hash haben, sind sie garantiert identisch. Darauf basiert Gits Integrität. Und ja — SHA-1 ist mathematisch geknackt, aber für Git reichts (Git migriert gerade zu SHA-256).

### 4. Snapshots, nicht Diffs

Das ist das größte Missverständnis über Git. Jeder Commit ist kein "Diff zum vorherigen", sondern ein vollständiger Snapshot ALLER Dateien. Git lügt dich nur beim `git log -p` an (es zeigt dir Diffs an, weil das für Menschen lesbarer ist).

```bash
# Jeder Commit hat einen KOMPLETTEN Tree
git cat-file -p HEAD^{tree}
git cat-file -p HEAD~1^{tree}   # vorheriger Commit
# Beide zeigen EINE komplette Ordnerstruktur
# Nicht: "add these 3 lines, remove 2 lines" — sondern ALLE Dateien

# Beweis: Unveränderte Dateien teilen sich denselben Blob-Hash
# src/version.py wurde nie verändert in der Demo
git rev-parse HEAD:src/version.py
# → 37b1...

git rev-parse HEAD~1:src/version.py
# → 37b1... IDENTISCH!

# Beide Commits zeigen auf DENSELBEN Blob!
# Git speichert die unveränderten Dateien nicht doppelt.
# Jeder Commit IST ein vollständiger Snapshot,
# ABER nur geänderte Dateien verbrauchen neuen Speicherplatz.
```

**Warum das wichtig ist:** Wenn du `git log --all --oneline` siehst und 200 Commits siehst, dann sind das 200 vollständige Snapshots deines Projekts. Git kann jeden einzelnen Commit auspacken, ohne die vorherigen zu berechnen (im Gegensatz zu SVN/Darcs/others). Das macht `git switch`, `git checkout`, `git bisect` blitzschnell. Und die Speichereffizienz kommt durch geteilte Blobs, nicht durch Diffs.

### 5. Die Drei Bäume (Three Trees)

Git lebt in drei Zuständen. Wenn man das versteht, wird `git add`, `git commit`, `git restore` plötzlich logisch. Die drei Bäume sind: **HEAD** (letzter Commit), **Index** (Staging), **Working Directory** (deine sichtbaren Dateien).

```bash
# AUSGANGSLAGE: Alle drei Bäume identisch
git status
# → nothing to commit, working tree clean

# HEAD = der aktuelle Commit (im .git/objects)
git rev-parse HEAD
# → 73de072...

# Index = Staging Area (binäre Datei .git/index)
# Vergleiche HEAD mit Index:
git diff --cached   # → nichts! HEAD == Index

# Working Directory = deine sichtbaren Dateien
# Vergleiche Index mit Working Dir:
git diff            # → nichts! Index == Working Dir

# Also: HEAD == Index == Working Dir → "clean"
# ---------- Jetzt ändern wir was ----------

# Datei bearbeiten (änder nur Working Directory)
echo "Neuer Inhalt" > readme.md

# Working Dir ≠ Index!
git diff
# → diff --git a/readme.md b/readme.md
# → -Hallo Git Welt
# → +Neuer Inhalt

# Index ≠ HEAD noch immer (oder vielleicht schon?)
# git diff --cached → immer noch nichts (noch nicht geaddet!)

# ADD: Kopiert von Working Dir in den Index
git add readme.md

# Jetzt: Index == Working Dir (beide haben "Neuer Inhalt")
git diff            # → nichts mehr!

# Aber: HEAD ≠ Index (im HEAD steht noch "Hallo Git Welt")
git diff --cached   # → zeigt die Änderung! Wird gleich committed.

# COMMIT: Friert den Index als neuen Tree ein
git commit -m "FEAT: Neuer Inhalt"
# → Git nimmt den aktuellen Index, erstellt einen Tree,
#   verpackt ihn in einen neuen Commit, und schiebt
#   den Branch-Zeiger auf den neuen Commit.

# Danach wieder: HEAD == Index == Working Dir → clean
```

**Erklärung zum Mitnehmen:** Der ganze Git-Alltag dreht sich darum, Daten zwischen diesen drei Bäumen zu verschieben. `git add` = Working → Index. `git commit` = Index → HEAD. `git restore` = HEAD → Working (rückwärts). Wenn einer dieser Schritte unklar ist, denk an die drei Bäume.

### 6. Branches sind nur Post-it-Zettel

In den meisten Tools ist ein Branch "ein separater Entwicklungszweig". Technisch ist das bullshit. Ein Branch ist ein **beweglicher Zeiger auf einen Commit**. Nichts sonst. Kein Kopieren, kein Fork, kein Speicherverbrauch.

```bash
# Aktuelle Position
cat .git/refs/heads/main
# → 73de072...
# Und was ist HEAD?
git rev-parse HEAD
# → 73de072... IDENTISCH!
# Weil: HEAD → Branch → Commit

# Neuen Branch = neue Datei mit gleichem Inhalt
git branch feature/neu
cat .git/refs/heads/feature/neu
# → 73de072... Gleicher Hash!

# Nach einem Commit auf dem neuen Branch:
git switch feature/neu
echo "Feature" > feature.txt
git add . && git commit -m "FEAT: New feature"
cat .git/refs/heads/feature/neu
# → NEUER Hash! Der Branch ist weitergewandert.
# main zeigt noch auf den alten Commit.

# Löschen = Datei löschen. Die Commits bleiben!
git branch -D feature/neu
cat .git/refs/heads/feature/neu  # → Datei existiert nicht mehr
ls .git/refs/heads/              # → nur noch main

# Aber die Commits sind noch da:
git log --oneline all
# Oder direkt:
git log --all --oneline
# → ALLE Commits sichtbar, obwohl der Branch-Zeiger weg ist.
```

**Warum das wichtig ist:** Weil Branches billige Zeiger sind, kann Git sich endlos viele Branches leisten. Jeder Branch ist nur `echo "hash" > datei`. Darum ist Git so branch-happy. Und darum kann man einen "gelöschten" Branch so leicht wiederherstellen: Der Garbage Collector räumt verwaiste Commits erst nach 90 Tagen auf (bzw. wenn der Reflog-Eintrag abläuft).

### 7. Der Reflog — dein Rettungsnetz

Der Reflog (Reference Log) zeichnet ALLE Bewegungen von HEAD auf. Nicht nur Commits, sondern auch Switches, Resets, Rebases, Merges. 90 Tage lang. Das ist dein Sicherheitsnetz gegen "ich hab grad alles kaputt gemacht".

```bash
# Alle HEAD-Bewegungen der letzten 90 Tage
git reflog
# → 73de072 HEAD@{0}: checkout: moving from main to feature/hallo-name
# → 73de072 HEAD@{1}: checkout: moving from feature/hallo-name to main
# → 73de072 HEAD@{2}: checkout: moving from main to feature/hallo-name
# → 0d71be5 HEAD@{3}: commit: FEAT: Initial project
# → ...

# JEDE Aktion wird geloggt — auch abgebrochene Rebases
git rebase --abort  # steht auch im Reflog!

# Einen vermeintlich verlorenen Commit wiederherstellen
# Z.B. nach: git reset --hard HEAD~2 (weil man dachte "der letzte Commit war scheiße")
# Im Reflog steht noch der alte HEAD:
# 1a2b3c4 HEAD@{5}: commit: FEAT: Add greet function
git branch gerettet 1a2b3c4
# → Zack, Branch zeigt auf den alten Commit. Gerettet.

# Reflog hat PRO REPO einen separaten Log-Ordner:
cat .git/logs/HEAD
# → Das ist die Rohdaten-Quelle für git reflog
# Spalten: alter_Hash neuer_Hash Autor_Datumsstempel Aktion
```

**Erklärung:** Der Reflog ist dein "Das hätte ich fast verloren"-Protokoll. In 10 Jahren Git-Nutzung hab ich ihn vielleicht 3 Mal gebraucht — aber diese 3 Male haben mich vor stundenlanger Arbeit bewahrt. Fun Fact: `git reflog` ist nicht der richtige Befehl — es gibt nur `git log -g` oder `git reflog show`. Aber weil alle `git reflog` sagen, hat Git daraus einen offiziellen Alias gemacht.

### 8. Feature-Branch — Live die Objekte verfolgen

Jetzt kombinieren wir alles: Wechsel auf den Feature-Branch und sehen live was mit HEAD, Branch-Zeiger und den Objekten passiert.

```bash
# Wechsel auf den Feature-Branch
git switch feature/hallo-name

# Was sagt HEAD jetzt?
cat .git/HEAD
# → ref: refs/heads/feature/hallo-name
# HEAD zeigt nicht mehr auf main, sondern auf feature/hallo-name!

# Der aktuelle Commit ist ein anderer
git rev-parse HEAD            # → 06970aa... (feature-Branch)
git rev-parse main            # → 73de072... (bleibt wo er war)

# Den gemeinsamen Vorfahren finden (Merge Base)
git merge-base main feature/hallo-name
# → 73de072... (letzter gemeinsamer Commit beider Branches)

# 3-Way-Merge visualisieren: Wie Git Konflikte erkennt
# Git vergleicht 3 Versionen:
echo "=== UNSERE Version (main) ==="
git show main:src/app.py

echo "=== DEREN Version (feature) ==="
git show feature/hallo-name:src/app.py

echo "=== GEMEINSAMER VORFAHR ==="
git show $(git merge-base main feature/hallo-name):src/app.py
# Wenn main und feature DIESELBE Zeile anders haben als der Vorfahr → KONFLIKT

# Und weil du weißt wie's funktioniert:
# Der Merge-Base ist selbst ein Commit-Objekt mit eigenem Tree und Blobs
git cat-file -p $(git merge-base main feature/hallo-name)
# → tree ...  ← das ist der Vorfahr-Tree!
```

**Erklärung:** Wenn du verstanden hast dass ein Commit ein Objekt ist, ein Branch ein Zeiger darauf, und ein Merge-Base auch nur ein Commit... dann hast du Git verstanden. Alles baut aufeinander auf. Es gibt keine Magie, keine versteckten Fallstricke. Nur Objekte, Zeiger und die drei Bäume.

## ⚠️ Typische Praxisprobleme

**❗ `git cat-file -p` gibt nichts aus:** Der Hash ist falsch oder das Objekt wurde gelöscht (GC).
→ Komplette Objekt-ID verwenden oder Tab-Completion.

**❗ Verwirrung mit `HEAD^{tree}`:** Die geschweiften Klammern müssen im Terminal escaped werden.
→ Bash: `git cat-file -p 'HEAD^{tree}'` oder TAB-Taste nach `HEAD^` drücken.

**❗ Reflog zu lang:** Nach Monaten voller Einträge unübersichtlich.
→ `git reflog expire --expire=now --all` zum Zurücksetzen.

**❗ Ältere Commits haben andere Hashes auf verschiedenen Rechnern:** Nein! Gleicher Inhalt = gleicher Hash.
→ Bei unterschiedlichen Hashes: unterschiedlicher Inhalt (unterschiedlicher Parent, Tree, Timestamp, Author).
