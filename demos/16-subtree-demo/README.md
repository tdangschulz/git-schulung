# Demo 16: Subtree — Externe Projekte einbinden

**Ziel:** Lerne, wie du fremde Repos in einen Unterordner deines Projekts
integrierst — mit voller History, Updates und der Möglichkeit, Änderungen
zurückzugeben.

## Theorie

### Was ist Subtree?

Subtree kopiert den **vollständigen Inhalt + Historie** eines externen Repos
**in einen Unterordner** deines eigenen Repos. Andere Entwickler brauchen
keinen Extra-Befehl beim Klonen — alles liegt direkt im Repo.

```
Dein Repo vor Subtree:      Dein Repo nach Subtree:
┌─────────────────┐       ┌──────────────────────────┐
│  app.py          │       │  app.py                   │
│  README.md       │       │  README.md                │
│  src/            │       │  src/                     │
│    main.js       │       │    main.js                │
└─────────────────┘       │  vendor/                  │
                            │    bootstrap/     ←──┐   │
                            │      bootstrap.css │  │   │
                            │      .git          │  │   │
                            └────────────────────┴──┴───┘
                                      Externes Repo
                                      (komplette History)
```

### Vorteile gegenüber Submodulen

| Submodule | Subtree |
|---|---|
| Zeiger (Link) auf externen Commit | Echter Inhalt im Repo |
| Extra-Schritt beim Klonen (`--recursive`) | Nichts — alles sofort da |
| Externes Repo separat verwalten | Externes Repo = Teil des eigenen |
| Änderungen im Submodul = eigener Push | Änderungen = normaler Commit im eigenen Repo |

### Zwei Wege zum Ziel

| Weg | Befehl | Voraussetzung |
|---|---|---|
| **`git subtree`** (Komfort-Wrapper) | `git subtree add --prefix=...` | Git ≥ 1.7.11 + Paket `git-subtree` |
| **`git merge -s subtree`** (eingebaute Strategie) | `git fetch + git merge -s subtree` | Immer verfügbar — kein Extra-Paket |

Beide machen am Ende dasselbe. Der Unterschied:
- `git subtree add` automatisert den **ersten Import** (spart das manuelle Verschieben)
- `git merge -s subtree` ist der **Motor** dahinter und immer da
- Für Updates (ab dem 2. Mal) reicht in **beiden** Fällen: `git merge -s subtree`

---

## 🖥️ Live-Demo

**Externes Projekt:** 👉 <https://github.com/tdangschulz/git-subtree>

### Setup

```bash
cd demos/16-subtree-demo/start
git log --oneline --graph --all
ls
```

Du siehst das Hauptprojekt („WebApp") — **kein vendor/-Ordner**.
Alles noch clean.

```
* 78c1c8d feat: Basis-Stylesheet
* 4d9e437 feat: Version-Modul
* 5b5a30f feat: Hello-Funktion
* 5348ca1 feat: JavaScript-Grundstruktur
* 9e07bc6 Initial commit: WebApp-Setup
```

---

### Variante 1: Schnellstart — `git subtree add` (wenn installiert)

> **Voraussetzung:** `git subtree` muss auf deinem System verfügbar sein.
> Fehlt es, installiere es mit:
> ```bash
> sudo apt install git-subtree    # Debian/Ubuntu/Mint
> brew install git-subtree        # macOS
> sudo dnf install git-subtree    # Fedora
> ```

Inline (ohne Remote anzulegen) — die „Quick & Dirty"-Methode:

```bash
git subtree add --prefix=vendor/bootstrap \
  https://github.com/tdangschulz/git-subtree.git main --squash \
  -m "chore: Bootstrap eingebunden"
```

**Was passiert?**
1. Git holt das externe Repo
2. Kopiert alle Dateien nach `vendor/bootstrap/`
3. Fasst die externe History in **einen Commit** zusammen (`--squash`)
4. Erzeugt einen Merge-Commit

**Ohne `--squash`** bleibt die volle 5-Commit-History erhalten:

```bash
git subtree add --prefix=vendor/bootstrap \
  https://github.com/tdangschulz/git-subtree.git main \
  -m "chore: Bootstrap (volle History)"
```

**Prüfen:**
```bash
ls vendor/bootstrap/
# → bootstrap.css  grid.css  LICENSE  README.md
```

---

### Variante 2: Mit Remote-Tracking

Empfohlen für regelmäßige Updates — das externe Repo wird als
echter Remote eingetragen.

```bash
# Remote hinzufügen
git remote add bootstrap https://github.com/tdangschulz/git-subtree.git

# Subtree einbinden (--squash = kompakte History)
git subtree add --prefix=vendor/bootstrap bootstrap main --squash \
  -m "chore: Bootstrap per Remote eingebunden"
```

**Vorteil gegenüber Inline:** Du musst die URL nicht jedes Mal
neu tippen, sondern nutzt einfach `bootstrap` als Kürzel.

---

### Variante 3: Ohne `git subtree` — manueller Import (immer verfügbar)

Falls `git subtree` nicht installiert ist, machst du den Import
händisch — die volle Kontrolle über jeden Schritt.

**Schritt 1: Externes Repo klonen**

```bash
git clone https://github.com/tdangschulz/git-subtree.git /tmp/subtree-extern
cd /tmp/subtree-extern
```

**Schritt 2: Inhalt nach vendor/bootstrap/ verschieben**

```bash
mkdir -p vendor
git mv bootstrap.css grid.css LICENSE README.md vendor/bootstrap/
git commit -m "chore: Bootstrap nach vendor verschoben"
```

Jetzt hat das externe Repo einen zusätzlichen Commit:
```
* abc1234 chore: Bootstrap nach vendor verschoben     ← NEU
* c3c514f feat: Primary Button                        ← originale History
* c7ef15b feat: Grid-System                            ← bleibt erhalten
* c94b50e feat: Button-Styles
* 6119724 chore: Lizenz hinzugefügt
* b5c3180 Initial commit: Bootstrap v1.0
```

**Schritt 3: Als Remote einbinden und mergen**

```bash
cd -  # zurück ins Hauptprojekt

git remote add subtree-extern /tmp/subtree-extern
git fetch subtree-extern
git merge subtree-extern/main --allow-unrelated-histories \
  -m "chore: Bootstrap per Subtree eingebunden"
```

**Schritt-für-Schritt:**

| Schritt | Was passiert | Sichtbar? |
|---|---|---|
| **1. Clone** | Vollständige Kopie des externen Repos | Ja — clone-Ausgabe |
| **2. Git mv** | Dateien nach `vendor/bootstrap/` verschieben + Commit | Ja — „1 file changed" |
| **3. Remote add** | `subtree-extern` zeigt auf `/tmp/subtree-extern` | Nein |
| **4. Fetch** | Lädt alle Commits ins Hauptprojekt | Ja — „Fetching subtree-extern" |
| **5. Merge** | `--allow-unrelated-histories` verbindet die getrennten Historien | Ja — „Merge made by the 'ort' strategy." |
| **6. Merge-Commit** | Ein Commit mit zwei Eltern | Ja — im Log |

**Prüfen:**
```bash
ls vendor/bootstrap/
git log --oneline --graph --all
```

```
*   1234567 chore: Bootstrap per Subtree eingebunden  ← Merge-Commit
|\
| * abc1234 chore: Bootstrap nach vendor verschoben   ← Move-Commit
| * c3c514f feat: Primary Button                      ← originale History
...
* eb110ab feat: Basis-Stylesheet                      ← deine Commits
...
```

---

### Updates vom externen Projekt ziehen

Egal ob du Variante 1, 2 oder 3 gewählt hast:
Nach dem ersten Import ist der Workflow für Updates identisch.

**Einen neuen Commit vorbereiten:**

Öffne <https://github.com/tdangschulz/git-subtree> im Browser,
editiere `bootstrap.css` (ersetze `v1.2` durch `v2.0`) und committe.

**Oder lokal:** In das geklonte externe Repo gehen:
```bash
cd /tmp/subtree-extern
echo "/*! Bootstrap v2.0 */" > bootstrap.css
git add . && git commit -m "Release v2.0"
git mv bootstrap.css vendor/bootstrap/
git commit -m "chore: v2.0 nach vendor verschoben"
cd -
```

**Update einspielen (Variante A — per Remote):**

```bash
git fetch subtree-extern
git merge subtree-extern/main -m "chore: Bootstrap auf v2.0 aktualisiert"
```

**Update einspielen (Variante B — `merge -s subtree`):**

```bash
git reset --hard HEAD~1  # zurück auf v1

git fetch https://github.com/tdangschulz/git-subtree.git \
  main:refs/remotes/extern/bootstrap
git merge -s subtree extern/bootstrap -m "chore: Bootstrap v2.0 (-s subtree)"
```

**Der Unterschied:**
- **Variante A** braucht das manuelle `git mv` im Zwischen-Repo
- **Variante B** (`-s subtree`) erkennt den Zielordner automatisch

**👣 `-s subtree` Schritt für Schritt:**

| Schritt | Was passiert |
|---|---|
| **1. Fetch** | Holt den v2.0 Commit aus dem externen Repo |
| **2. Merge-Base** | Sucht gemeinsamen Vorfahren = Merge-Commit aus dem ersten Import |
| **3. `-s subtree`** | Erkennt: „Zielordner ist `vendor/bootstrap/`" — leitet alle Dateien dorthin um |
| **4. Merge-Commit** | Fertiger Commit mit zwei Eltern |

**Prüfen:**
```bash
cat vendor/bootstrap/bootstrap.css
# → /*! Bootstrap v2.0 */
```

---

### Eigene Änderungen zurückgeben (Contributing Back)

Du hast Bootstrap angepasst und willst die Änderungen zurück ins
originale Repo geben.

**Per `git subtree push` (mit Wrapper):**

```bash
echo "/* Angepasst für WebApp */" >> vendor/bootstrap/bootstrap.css
git add vendor/bootstrap/
git commit -m "fix: Bootstrap an WebApp angepasst"

git subtree push --prefix=vendor/bootstrap \
  https://github.com/tdangschulz/git-subtree.git main
```

**Manuell (ohne `git subtree`):**

```bash
# Split the subtree history
git subtree split --prefix=vendor/bootstrap -b split-branch

# Push zum externen Repo
git push https://github.com/tdangschulz/git-subtree.git split-branch:main
```

`git subtree split` extrahiert die Commits aus `vendor/bootstrap/`
und erzeugt daraus einen Branch, der aussieht, als wären die Änderungen
direkt im externen Repo entstanden.

---

### Was passiert OHNE `-s subtree`?

**Wichtig zu verstehen:** Ohne die Subtree-Strategie landen die Dateien
im Root statt im gewünschten Ordner.

```bash
git reset --hard HEAD~1  # zurück auf v1

git fetch https://github.com/tdangschulz/git-subtree.git main:refs/remotes/extern/test
git merge extern/test -m "Merge ohne subtree"

ls
# → bootstrap.css liegt im ROOT!  ← FALSCH!
```

**Aufräumen:**
```bash
git reset --hard ORIG_HEAD
```

> **Erklärung:** Ohne `-s subtree` landet der externe Inhalt da, wo er
> im externen Repo lag — im Root. Mit `-s subtree` wandert er automatisch
> in den vorgesehenen Unterordner.

---

### Squash vs. Volle History

**Squash** komprimiert die externe History in einen Commit —
platzsparend, aber ohne Zwischenschritte.

| Aspekt | Squash (`--squash`) | Volle History |
|---|---|---|
| Commits | 1 | 5 + Move-Commit |
| Nachvollziehbarkeit | Keine Zwischenschritte | Jeder einzelne Schritt |
| Platz | Minimal | Größer |
| Wann sinnvoll? | Große, stabile Libraries | Kleine Projekte, aktive Entwicklung |

**Squash-Merge manuell:**
```bash
git reset --hard HEAD~1
git merge --squash --allow-unrelated-histories subtree-extern/main
git commit -m "chore: Bootstrap eingebunden (gesquasht)"
git log --oneline vendor/bootstrap/
# → Nur ein Commit
```

---

### Vollständige Demo (alles in einem Durchlauf)

```bash
# === Setup ===
cd demos/16-subtree-demo/start
ls                                   # kein vendor/

# === 1) Externes Repo vorbereiten ===
git clone https://github.com/tdangschulz/git-subtree.git /tmp/subtree-extern
cd /tmp/subtree-extern
mkdir -p vendor
git mv bootstrap.css grid.css LICENSE README.md vendor/bootstrap/
git commit -m "chore: nach vendor verschoben"
cd -

# === 2) Als Remote + Merge ===
git remote add subtree-extern /tmp/subtree-extern
git fetch subtree-extern
git merge subtree-extern/main --allow-unrelated-histories \
  -m "chore: Bootstrap eingebunden"
ls vendor/bootstrap/

# === 3) Update (manuelles mv) ===
cd /tmp/subtree-extern
echo "/* v2.0 */" > bootstrap.css
git add . && git commit -m "Release v2.0"
git mv bootstrap.css vendor/bootstrap/
git commit -m "chore: v2.0 nach vendor verschoben"
cd -

git fetch subtree-extern
git merge subtree-extern/main -m "chore: Bootstrap v2.0"
cat vendor/bootstrap/bootstrap.css    # → v2.0

# === 4) Update mit merge -s subtree (kein manuelles mv nötig) ===
git reset --hard HEAD~1
git fetch https://github.com/tdangschulz/git-subtree.git \
  main:refs/remotes/extern/bootstrap
git merge -s subtree extern/bootstrap -m "chore: v2.0 (-s subtree)"
cat vendor/bootstrap/bootstrap.css    # → v2.0

# === 5) Änderung zurückgeben ===
echo "/* WebApp-Anpassung */" >> vendor/bootstrap/bootstrap.css
git add vendor/bootstrap/bootstrap.css
git commit -m "fix: An WebApp angepasst"
git subtree split --prefix=vendor/bootstrap -b split-branch

# === 6) Prüfen ===
git log --oneline --graph --all
```

---

## 🔍 Zusammenfassung

| Schritt | Mit `git subtree` (Wrapper) | Ohne `git subtree` (Bordmittel) |
|---|---|---|
| **Import** | `git subtree add --prefix=... <url> main` | `git clone` → `git mv` → `git merge --allow-unrelated-histories` |
| **Update** | `git subtree pull --prefix=... <remote> main` | `git fetch <url>` → `git merge -s subtree` |
| **Zurückgeben** | `git subtree push --prefix=... <url> main` | `git subtree split --prefix=... -b branch` → `git push` |
| **Squash** | `--squash` Flag | `git merge --squash` |

**Die goldene Regel:**
> Einmal etabliert → `git fetch <url> && git merge -s subtree` für jedes Update.
> Der `-s subtree` Merge-Strategy ist immer verfügbar — kein Extra-Paket nötig.

---

## 📚 Weiterführend

- Externes Projekt: <https://github.com/tdangschulz/git-subtree>
- Atlassian Git Subtree Tutorial: <https://www.atlassian.com/git/tutorials/git-subtree>
- [Git Subtree Manpage](https://git-scm.com/docs/git-subtree)
- [`git merge -s subtree`](https://git-scm.com/docs/git-merge#Documentation/git-merge.txt-merge-strategies) — Alternative ohne den Wrapper
- [Submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules) — die verlinkte Alternative
