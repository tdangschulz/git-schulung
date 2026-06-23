# Demo 16: Subtree — Externe Projekte einbinden

**Ziel:** Lerne, wie du fremde Repos mit voller History in einen Unterordner deines
Projekts integrierst — **ohne** zusätzliche Tools. Nur Git-Bordmittel.

## Theorie

### Was ist Subtree?

Du kopierst den **vollständigen Inhalt + Historie** eines externen Repos
**in einen Unterordner** deines eigenen Repos. Anders als Submodule
brauchen andere Entwickler keinen Extra-Befehl — alles liegt direkt im Repo.

```
Dein Repo vorher:         Dein Repo nach Subtree-Import:
┌─────────────────┐      ┌──────────────────────────┐
│  app.py          │      │  app.py                   │
│  README.md       │      │  README.md                │
│  src/            │      │  src/                     │
│    main.js       │      │    main.js                │
└─────────────────┘      │  vendor/                  │
                          │    awesome-lib/   ←──┐    │
                          │      lib.js         │    │
                          │      README.md      │    │
                          └──────────────────────┴────┘
                                    Externes Repo
                                    (komplette History)
```

### Warum Subtree statt Submodule?

| Submodule | Subtree |
|---|---|
| Zeiger (Link) auf externen Commit | Echter Inhalt im Repo |
| Extra-Schritt beim Klonen (`--recursive`) | Nichts — alles sofort da |
| Externes Repo separat verwalten | Externes Repo = Teil des eigenen |
| Änderungen im Submodul = eigener Push | Änderungen = normaler Commit im eigenen Repo |

### Warum `merge -s subtree`?

`git merge -s subtree` ist eine **eingebaute Merge-Strategie** von Git.
Sie verschiebt Dateien automatisch in den richtigen Unterordner —
auch ohne dass `git subtree` installiert sein muss.

> `git subtree` ist nur ein Komfort-Wrapper.
> `git merge -s subtree` ist der Motor darunter und immer verfügbar.

---

## 🖥️ Live-Demo

Das externe Projekt liegt auf GitHub:
👉 <https://github.com/tdangschulz/git-subtree>

### Setup

```bash
cd demos/16-subtree-demo/start
git log --oneline --graph --all
ls
```

Du siehst das Hauptprojekt („WebApp") — **kein vendor/-Ordner**.
Alles noch clean. Jetzt wird Schritt für Schritt aufgebaut.

---

### Demo A: Externes Projekt per Subtree einbinden

**Ziel:** Das externe `git-subtree`-Repo als Unterordner `vendor/bootstrap/`
ins eigene Projekt holen — mit **vollständiger History**.

**Ansatz:** Wir klonen das externe Repo, verschieben den Inhalt in den
gewünschten Unterordner, und mergen es dann per `git merge` herein.

**Ausgangssituation:**
```bash
ls
# → README.md  app.js  index.html  src/  style.css
#    Kein vendor/! Das Projekt ist noch clean.
```

---

**Schritt 1: Externes Repo klonen und vorbereiten**

```bash
git clone https://github.com/tdangschulz/git-subtree.git /tmp/subtree-extern
cd /tmp/subtree-extern
git log --oneline
# → Siehst du die 5 Bootstrap-Commits
```

**Schritt 2: Inhalt in vendor/bootstrap/ verschieben**

Jetzt der entscheidende Schritt: Der gesamte Inhalt wandert in den
Unterordner, in dem er später im Hauptprojekt liegen soll.

```bash
mkdir -p vendor
git mv bootstrap.css grid.css LICENSE README.md vendor/bootstrap/
git commit -m "chore: Bootstrap nach vendor/bootstrap/ verschoben"
```

**Was passiert?**
- Ein neuer Commit entsteht, der ALLE vorherigen Commits als Eltern hat
- Jeder einzelne Commit der Bootstrap-History bleibt **erhalten**
- Zusätzlich gibt es jetzt den „Move"-Commit ganz oben

```bash
git log --oneline --graph --all
# * abc1234 chore: Bootstrap nach vendor/bootstrap/ verschoben   ← NEU
# * c3c514f feat: Primary Button                                 ← alte History
# * c7ef15b feat: Grid-System                                    ← bleibt erhalten
# * c94b50e feat: Button-Styles
# * 6119724 chore: Lizenz hinzugefügt
# * b5c3180 Initial commit: Bootstrap v1.0
```

---

**Schritt 3: Externes Repo als Remote einbinden und mergen**

```bash
cd -   # zurück ins Hauptprojekt

git remote add subtree-extern /tmp/subtree-extern
git fetch subtree-extern
```

Jetzt kommt der Merge:

```bash
git merge subtree-extern/main --allow-unrelated-histories \
  -m "chore: Bootstrap per Subtree eingebunden"
```

**👣 Schritt für Schritt, was Git intern macht:**

| Schritt | Was passiert | Sichtbar? |
|---|---|---|
| **1. Remote anlegen** | `subtree-extern` zeigt auf `/tmp/subtree-extern` | Nein |
| **2. Fetch** | Lädt alle Commits (5 originale + 1 Move) in den Cache | Ja — „Fetching subtree-extern" |
| **3. Merge** | `git merge --allow-unrelated-histories` verbindet die beiden getrennten Historien | Ja — „Merge made by the 'ort' strategy." |
| **4. Merge-Commit** | Ein Commit mit **zwei Eltern**: Eltern 1 = dein `main`, Eltern 2 = der Move-Commit aus `subtree-extern` | Ja |
| **5. vendor/ befüllen** | `vendor/bootstrap/` enthält jetzt alle Bootstrap-Dateien | Ja — `ls vendor/bootstrap/` |

**Warum `--allow-unrelated-histories`?**
Weil das Hauptprojekt und das externe Repo **keinen gemeinsamen
Vorfahren** haben. Normalerweise verweigert Git den Merge.
Mit dem Flag sagst du: „Ist OK, ich will die trotzdem zusammenführen."

---

**🔍 Prüfen Schritt 1: Der Ordner ist da**

```bash
ls vendor/bootstrap/
# → bootstrap.css  grid.css  LICENSE  README.md
```

**🔍 Prüfen Schritt 2: Der Merge-Commit im Log**

```bash
git log --oneline --graph --all
```

```
*   1234567 chore: Bootstrap per Subtree eingebunden    ← NEU: Merge-Commit
|\
| * abc1234 chore: Bootstrap nach vendor verschoben     ← Move-Commit
| * c3c514f feat: Primary Button                        ← originale History
| * c7ef15b feat: Grid-System
| * c94b50e feat: Button-Styles
| * 6119724 chore: Lizenz hinzugefügt
| * b5c3180 Initial commit: Bootstrap v1.0
*
* eb110ab feat: Basis-Stylesheet                        ← deine eigenen Commits
* c2ab766 feat: Version-Modul
* fc6200b feat: Hello-Funktion
* 373f871 feat: JavaScript-Grundstruktur
* f858d9e Initial commit: WebApp-Setup
```

**Wichtig:** Die 5 Bootstrap-Commits sind original aus dem externen Repo.
Der Merge-Commit verbindet die beiden Welten.

**🔍 Prüfen Schritt 3: History einzelner Dateien**

```bash
git log --oneline vendor/bootstrap/bootstrap.css
# → Zeigt NUR die Commits, die bootstrap.css betreffen:
#   abc1234 chore: Bootstrap nach vendor verschoben
#   c3c514f feat: Primary Button
#   c94b50e feat: Button-Styles
#   b5c3180 Initial commit: Bootstrap v1.0
```

Git trackt jede Datei einzeln — auch über Repo-Grenzen hinweg.

---

**🗣️ Zu erklären:**

> **Das ist der klassische Subtree-Workflow: externes Repo klonen → in Unterordner
> verschieben → als Remote einbinden → mergen. Alle Dateien liegen physisch im Repo,
> kein Submodule-Update nötig beim Klonen.**

---

### Demo B: Updates vom externen Projekt ziehen

**Ziel:** Eine neue Version (v2.0) einspielen.

**Voraussetzung:** Neuer Commit im externen Repo.

**Variante A — Auf GitHub (Internet):**
Öffne <https://github.com/tdangschulz/git-subtree>,
editiere `bootstrap.css`, ersetze `v1.2` durch `v2.0`, commit.

**Variante B — Lokal (kein Internet nötig):**
```bash
cd /tmp/subtree-extern
git pull https://github.com/tdangschulz/git-subtree.git main
```

---

**Jetzt den Move-Commit neu aufsetzen und mergen:**

```bash
cd /tmp/subtree-extern

# Dateien in vendor/ verschieben (wie bei Demo A, Schritt 2)
git mv bootstrap.css vendor/bootstrap/
git commit -m "chore: v2.0 nach vendor verschoben"

cd -   # zurück ins Hauptprojekt

git fetch subtree-extern
git merge subtree-extern/main -m "chore: Bootstrap auf v2.0 aktualisiert"
```

**Was passiert intern?**

| Schritt | Was passiert |
|---|---|
| **1. Pull** | Holt den neuen v2.0 Commit ins externe Repo |
| **2. Move-Commit** | Neuer Commit: „v2.0 nach vendor verschoben" |
| **3. Fetch** | Lädt den neuen Move-Commit ins Hauptprojekt |
| **4. Merge** | Git merged: Base = vorheriger Merge, Ours = vendor/, Theirs = neuer Move-Commit |
| **5. Fast-Forward** | Da du vendor/ nicht lokal geändert hast, geht das clean durch |

---

**🔍 Prüfen:**

```bash
cat vendor/bootstrap/bootstrap.css
# → /*! Bootstrap v2.0 */
```

```bash
git log --oneline --graph --all
# → Wieder ein Merge-Commit:
#   chore: Bootstrap auf v2.0 aktualisiert
#     gefolgt von: chore: v2.0 nach vendor verschoben
#     gefolgt von: Release v2.0 (vom externen Repo)
```

---

**🗣️ Zu erklären:**

> **Jedes Update = einmal extern pullen, einmal verschieben, einmal mergen.
> Präzise, kontrolliert, ohne versteckte Magie.**

---

### Demo C: Low-Level mit `git merge -s subtree`

**Ziel:** Dasselbe Update mit **weniger Schritten** — die `-s subtree`-Strategie
erledigt das Verschieben automatisch.

**Zurücksetzen auf Stand nach Demo A:**
```bash
git reset --hard HEAD~1
# Entfernt den Update-Merge aus Demo B.
# vendor/bootstrap/ ist wieder auf v1.2
```

---

**Schritt 1: Externes Repo fetchen**

Statt das externe Repo separat zu pflegen, fetchen wir direkt:

```bash
git fetch https://github.com/tdangschulz/git-subtree.git main:refs/remotes/extern/bootstrap
```

**Was passiert?**

| Teil | Bedeutung |
|---|---|
| `git fetch <url> main:<dst>` | Holt `main` des externen Repos |
| `refs/remotes/extern/bootstrap` | Speichert als Remote-Branch `extern/bootstrap` |

**Prüfen:**
```bash
git branch -a
# → remotes/extern/bootstrap  ← fertig zum Mergen
```

---

**Schritt 2: Merge mit Subtree-Strategie**

Jetzt der entscheidende Unterschied zu Demo B:

```bash
git merge -s subtree extern/bootstrap -m "chore: Bootstrap v2.0"
```

**Ohne** `-s subtree` würde das scheitern — die Dateien liegen im externen
Repo im Root, nicht in `vendor/bootstrap/`.

**Mit** `-s subtree` passiert das:

| Schritt | Was passiert |
|---|---|
| **1. Merge-Base finden** | Git sucht den gemeinsamen Vorfahren = Merge-Commit aus Demo A |
| **2. `-s subtree` aktivieren** | Git erkennt: „Dieser Branch wurde schonmal subtree-gemergt. Der Zielordner ist `vendor/bootstrap/`." |
| **3. Pfade umbiegen** | Alle Dateien aus `extern/bootstrap` werden automatisch nach `vendor/bootstrap/` umgeleitet |
| **4. Merge-Commit** | Wie in Demo B: ein Merge-Commit mit zwei Eltern |

**Das ist der Clou:** Kein externes Zwischen-Repo, kein manuelles
Verschieben. Git macht alles automatisch.

---

**🔍 Prüfen:**

```bash
cat vendor/bootstrap/bootstrap.css
# → /*! Bootstrap v2.0 */
```

```bash
git log --oneline --graph --all
# → Merge-Commit + der originale v2.0 Commit aus dem externen Repo
```

---

**🗣️ Zu erklären:**

> **`git fetch <url> + git merge -s subtree` ersetzen `git subtree pull` komplett.
> Die `-s subtree`-Strategie ist in Git eingebaut — kein Extra-Paket nötig.**

> **Merke:** Einmal per Subtree etabliert → danach reicht
> `git fetch <extern> && git merge -s subtree` für jedes Update.

---

### Demo D: Was passiert OHNE `-s subtree`?

**Ziel:** Verstehen, warum `-s subtree` notwendig ist.

**Zurücksetzen:**
```bash
git reset --hard HEAD~1
```

**Merge OHNE Subtree-Strategie:**
```bash
git fetch https://github.com/tdangschulz/git-subtree.git main:refs/remotes/extern/bootstrap-ohne

git merge extern/bootstrap-ohne -m "Merge ohne subtree"
ls
# → bootstrap.css liegt im ROOT!  ← FALSCH!
```

**Aufräumen:**
```bash
git reset --hard ORIG_HEAD
```

> **🗣️ Erklären:** Ohne `-s subtree` landet der externe Inhalt da, wo er
> im externen Repo lag — im Root. Mit `-s subtree` wandert er automatisch
> in den vorgesehenen Unterordner.

---

### Demo E: Subtree ohne volle History (Squash-Variante)

**Ziel:** Externes Projekt einbinden, aber die History zusammenfassen.

```bash
cd /tmp/subtree-extern
git log --oneline
# → 5 originale Commits + 1 Move-Commit
cd -

# Statt Merge → Squash-Merge
git merge --squash --allow-unrelated-histories subtree-extern/main
git commit -m "chore: Bootstrap eingebunden (gesquasht)"

git log --oneline vendor/bootstrap/
# → Nur ein Commit: "chore: Bootstrap eingebunden (gesquasht)"
```

**Vergleich zur vollen History:**
```bash
git reset --hard HEAD~1

# Volle History
git merge subtree-extern/main --allow-unrelated-histories \
  -m "chore: Bootstrap eingebunden (volle History)"

git log --oneline vendor/bootstrap/
# → ALLE 6 Commits sichtbar (5 originale + 1 Move)
```

> **🗣️ Erklären:** Squash = History weggeworfen → platzsparend, aber
> man verliert die Nachvollziehbarkeit. Gute Wahl für große, stabile
> Libraries wo die History unwichtig ist.

---

### Vollständige Demo (alles in einem Durchlauf)

```bash
# === Setup ===
cd demos/16-subtree-demo/start
ls                                   # kein vendor/ - clean

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

# === 3) Update ===
cd /tmp/subtree-extern
echo "/* v2.0 */" > bootstrap.css
git add . && git commit -m "Release v2.0"
git mv bootstrap.css vendor/bootstrap/
git commit -m "chore: v2.0 nach vendor verschoben"
cd -

git fetch subtree-extern
git merge subtree-extern/main -m "chore: Bootstrap v2.0"

# === 4) Git-Bordmittel: merge -s subtree ===
git reset --hard HEAD~1
git fetch https://github.com/tdangschulz/git-subtree.git \
  main:refs/remotes/extern/bootstrap
git merge -s subtree extern/bootstrap -m "chore: v2.0 (-s subtree)"

# === 5) Prüfen ===
git log --oneline --graph --all
cat vendor/bootstrap/bootstrap.css    # v2.0
```

---

## 🔍 Zusammenfassung

| Befehl | Wirkung |
|---|---|
| `git clone <extern> + git mv + git commit` | Externes Repo in Unterordner-Struktur bringen |
| `git remote add + git fetch + git merge --allow-unrelated-histories` | **Erstmaliger Import** mit voller History |
| `git fetch + git merge -s subtree` | **Updates** (ab dem 2. Mal, ohne manuelles Verschieben) |
| `git merge --squash + git commit` | Externe History in einen Commit packen |

**Die goldene Regel:**
> **Einmal per Subtree etabliert → danach reicht
> `git fetch <url> <branch> && git merge -s subtree` für jedes Update.**

---

## 📚 Weiterführend

- Externes Projekt für diese Demo: <https://github.com/tdangschulz/git-subtree>
- [`git-merge-subtree`](https://git-scm.com/docs/git-merge#Documentation/git-merge.txt-merge-strategies) in der Git-Manpage
- Submodule: `git submodule add <repo> <pfad>` — alternative, verlinkte Lösung
