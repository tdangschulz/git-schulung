## Schnellstart

```bash
# Auspacken
cd /tmp
tar xzf pfad/zu/start.tar.gz
cd start

# Status: README.md bereits committet, Arbeitsverzeichnis sauber
# Erster Befehl: Datei bearbeiten und neuen Commit machen
echo "Zweite Zeile" >> README.md
git diff
git add . && git commit -m "Zweite Zeile hinzugefügt"
```

# Hallo Git

Diese Datei dient als erster Einstieg in den Git-Workflow.
Jeder Befehl wird mit einer Hintergrund-Erklärung versehen.

---

## Befehlsablauf

### 1. `git init`

```bash
git init
```

**Was passiert im Hintergrund?**

Git erstellt den `.git`-Ordner — das ist das gesamte Repository.
Ohne `.git/` ist ein Ordner einfach nur ein Ordner.

```
.git/
├── HEAD          → Zeigt auf den aktuellen Branch (erstmal: ref: refs/heads/main)
├── config        → Repo-Konfiguration (user.name, user.email, remote, etc.)
├── description   → Nur für GitWeb
├── hooks/        → Scripts, die bei bestimmten Aktionen laufen (pre-commit, post-commit, etc.)
├── info/         → Zusätzliche Infos (exclude = lokale .gitignore)
├── objects/      → 🔥 DAS HERZ: Alle deine Dateien + Commits als komprimierte Blobs
│   ├── pack/     → Gepackte Objekte (Git packt alte Objekte in .pack-Dateien)
│   └── info/     → Pack-Index
└── refs/         → Zeiger (Pointer) auf Commits
    ├── heads/    → Lokale Branches (z.B. refs/heads/main)
    └── tags/     → Tags (z.B. refs/tags/v1.0)
```

**🧠 Merken:** `.git/objects/` ist die **Objekt-Datenbank**. ALLES in Git
(Dateien, Bäume, Commits) wird hier als Objekt gespeichert. Wenn du `git init`
machst, wird dieser Ordner angelegt — leer, bereit zum Befüllen.

---

### 2. `git status`

```bash
git status
```

**Was passiert im Hintergrund?**

Git vergleicht DREI Zustände:

```
[Working Directory]  ←──→  [Index/Staging]  ←──→  [HEAD/Letzter Commit]
     (deine              (was im nächsten         (was zuletzt
      Dateien)            Commit landet)            committed wurde)
```

1. **Working Tree vs Index:** Ungestagte Änderungen (rot)
2. **Index vs HEAD:** Gestagte Änderungen (grün)
3. **Unbekannte Dateien:** Untracked files (nicht im Index und nicht in HEAD)

**Für Trainer:** Das ist die wichtigste Lektion des ganzen Workshops.
`git status` sagt dir EXAKT, wo im Three-Tree-System du gerade bist.

---

### 3. `git add <datei>`

```bash
git add README.md
```

**Was passiert im Hintergrund?**

1. Git nimmt die Datei und berechnet den **SHA-1-Hash** (40-stelliger Hex-Wert)
   ```
   SHA-1("README.md\n# Mein Projekt") = e69de29bb2d1d6434b8b29ae775ad8c2e48c5391
   ```

2. Git **komprimiert** die Datei (zlib) und speichert sie in `.git/objects/`

3. Der Hash wird in die **Staging-Area (Index)** eingetragen — Datei `.git/index`

4. Ab jetzt „kennt" Git die Datei

**Der SHA-1-Hash ist der Dateiname im Objekt-Store:**
```bash
# Nach git add findest du:
.git/objects/e6/9de29bb2d1d6434b8b29ae775ad8c2e48c5391
# \________/ \________________________________________/
#  Ordner          Dateiname (ohne Hash-Präfix)
```

**🧠 Merken:** `git add` ist eigentlich ein **Speichern** — die Datei
wird als Blob-Objekt in die Datenbank geschrieben. Der Index merkt sich
nur den Hash und den Dateipfad.

---

### 4. `git commit -m "Nachricht"`

```bash
git commit -m "Initial commit"
```

**Was passiert im Hintergrund?**

Hier passieren DREI Dinge im Eiltempo:

#### Schritt 1: Tree-Objekt erstellen

Git nimmt den **Index** (alles was gestaged ist) und erstellt ein
**Tree-Objekt**. Ein Tree ist wie ein Verzeichnis-Snapshot:

```
Tree-Objekt (Hash: 7c9b5a...)
├── README.md → Blob e69de29...  (Datei-Inhalt)
├── src/
│   ├── index.js → Blob a1b2c3d...
│   └── style.css → Blob d4e5f6g...
└── .gitignore → Blob x1y2z3...
```

#### Schritt 2: Commit-Objekt erstellen

Git erstellt ein **Commit-Objekt** mit Metadaten:

```
Commit-Objekt (Hash: 8f2d1c4...)
├── Tree:    7c9b5a...           (Verzeichnis-Snapshot)
├── Parent:  abc1234...          (vorheriger Commit oder keiner)
├── Author:  Max Mustermann      (aus git config user.name/email)
├── Committer: Max Mustermann    (kann abweichen bei Rebases)
└── Message: "Initial commit"    (deine Commit-Nachricht)
```

Der SHA-1-Hash des Commit-Objekts ist der **Commit-Hash**!

#### Schritt 3: Branch-Zeiger aktualisieren

Git schreibt den neuen Commit-Hash in die Branch-Referenz:

```
refs/heads/main → 8f2d1c4... (vorher: abc1234...)
```

Und aktualisiert `HEAD`:
```
.git/HEAD → ref: refs/heads/main  (bleibt gleich — zeigt immer auf den Branch)
```

**🧠 Merken:** Ein Commit ist nur ein **Pointer auf einen Tree** + Metadaten.
Wenn du `git log --oneline` siehst, sind das die Commit-Objekte.
Die eigentlichen Datei-Inhalte sind in den Tree-/Blob-Objekten.

---

### 5. `git diff`

```bash
# Datei ändern, dann:
git diff
```

**Was passiert im Hintergrund?**

Git vergleicht **Working Directory vs Index**:

```
Working Directory  ←──→  Index (.git/index)
  ("main: rot"          ("main: blau" — alter Stand)
   ungespeichert)
```

**Ergebnis:** Ein Patch-artiger Output, der zeigt WELCHE Zeilen
sich zwischen dem aktuellen Datei-Inhalt und dem Index-Inhalt
unterscheiden.

**Warum `git diff` NACH dem Stagen nichts zeigt?**
Weil Index und Working Directory wieder gleich sind.

```bash
echo "neuer Text" >> README.md
git diff    # → Zeigt die Änderung! (Working vs Index)
git add README.md
git diff    # → Nichts! (Working == Index)
git diff --staged  # → Zeigt die Änderung (Index vs HEAD)
```

---

### 6. `git add . && git commit -m "..."`

```bash
git add .
git commit -m "Meine Änderung"
```

**Hintergrund: Der komplette Workflow**

```
1) echo "Text" >> datei.txt
   → Zeichenkette im Arbeitsspeicher → auf Festplatte geschrieben

2) git add datei.txt
   → SHA-1-Hash der Datei berechnet
   → zlib-komprimiert in .git/objects/ geschrieben
   → Eintrag in .git/index (Dateipfad + Hash)

3) git commit -m "Nachricht"
   → Index ausgelesen → Tree-Objekt gebaut
   → Commit-Objekt (Tree + Metadaten + Parent)
   → Branch-Referenz (refs/heads/main) aktualisiert
   → HEAD bleibt (zeigt auf den Branch)
```

**🧠 Merken:** Die Dinge heißen:

| Bezeichnung | Inhalt | Wo? |
|---|---|---|
| **Blob** | Datei-Inhalt | `.git/objects/xx/xxxx...` |
| **Tree** | Verzeichnis-Struktur | `.git/objects/xx/xxxx...` |
| **Commit** | Snapshot + Metadaten | `.git/objects/xx/xxxx...` |
| **Index** | Staging-Area mit Datei-Hashes | `.git/index` |
| **Ref** | Zeiger auf Commit | `.git/refs/heads/main` |
| **HEAD** | Aktueller Branch/Marker | `.git/HEAD` |

---

### 7. `git log --oneline --graph`

```bash
git log --oneline --graph
```

**Was passiert im Hintergrund?**

1. **HEAD lesen:** `.git/HEAD` → zeigt auf `refs/heads/main`
2. **Branch lesen:** `.git/refs/heads/main` → aktueller Commit-Hash
3. **Commit-Objekt laden:** `.git/objects/xx/xxxx...` → Commit auspacken (zlib)
4. **Baum aufbauen:** Über die `parent`-Felder rückwärts durch die Kette
5. **Graph zeichnen:** Wenn `--graph` gesetzt ist, werden Verzweigungen
   als ASCII-Linien dargestellt (`|`, `/`, `\`)

**Für Trainer:** `git log` ist eigentlich eine **Graph-Walk-through**.
Es läuft den Commit-Graph entlang — immer vom aktuellen HEAD rückwärts
bis zum Root-Commit oder wo Git keinen Parent mehr findet.

---

## 🔬 Live-Hack: Die Objekte mit eigenen Augen sehen

```bash
# Nach ein paar Commits:
cd /tmp/git-schulung/recap-demo

# Zeige alle Objekt-Typen
git cat-file -t HEAD         # → commit
git cat-file -t HEAD^{tree}  # → tree

# Zeige Inhalt
git cat-file -p HEAD         # → Commit-Metadaten + Tree-Hash
git cat-file -p HEAD^{tree}  # → Verzeichnis-Struktur

# Die Roh-Daten
find .git/objects -type f    # Alle Objekt-Dateien
```

**Der Klassiker:**
```bash
# Commit-Hash aus git log nehmen und Objekt-Typ prüfen:
HASH=$(git rev-parse HEAD)
echo "Commit $HASH ist ein $(git cat-file -t $HASH)"
echo "Sein Tree: $(git rev-parse HEAD^{tree})"
# Das Tree-Objekt referenziert die Blobs (Dateien):
git ls-tree HEAD
# → Zeigt: Modus, Typ, Hash, Dateiname
```

---

## 📊 Das Three-Tree-Modell visuell

```
                    git add                 git commit
Working Directory ──────────→ Index/Staging ──────────→ Repository (HEAD)
  (Arbeitsdateien)             (Nächster Commit)         (Letzter Commit)
        │                            │                        │
        │  git diff                  │  git diff --staged      │
        │  (WT vs Index)             │  (Index vs HEAD)       │
        ▼                            ▼                        ▼
   Ungestagte Änderungen        Gestagte Änderungen       Nichts (oder
   (rot in git status)          (grün in git status)      divergiert bei Branches)
```

---

## ⚠️ Typische Praxisprobleme

**❗ Vim-Falle:** Nach \`git commit\` ohne \`-m\` öffnet sich Vim.
→ \`:wq\` zum Speichern + Schließen. Oder: \`git config --global core.editor "nano"\`

**❗ Git add vergessen:** \`git status\` zeigt untracked/unstaged Dateien — die sind NICHT im Commit!
→ Erst \`git add .\` (oder gezielt \`git add datei.txt\`), dann \`git commit\`

**❗ Commit-Nachricht zu knapp:** \`git commit -m "update"\` sagt nichts.
→ Besser: \`git commit -m "Add login functionality"\`

**❗ `git diff` zeigt nichts nach `git add`:**
→ Weil der Index jetzt den aktuellen Stand hat. Nutze \`git diff --staged\` für Index-vs-HEAD.
