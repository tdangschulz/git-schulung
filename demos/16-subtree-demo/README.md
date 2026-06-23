# Demo 16: Subtree — Externe Projekte einbinden

**Ziel:** Lerne, wie du mit `git subtree` fremde Repos sauber in dein Projekt integrierst — inklusive History und Update-Fluss.

## Theorie

### Was ist Subtree?

Subtree kopiert den **vollständigen Inhalt + Historie** eines externen Repos **in einen Unterordner** deines eigenen Repos. Anders als Submodule brauchen andere Entwickler keinen Extra-Befehl (`git submodule update`) — alles liegt direkt im Repo.

```
Dein Repo vorher:         Dein Repo nach subtree add:
┌─────────────────┐      ┌──────────────────────────┐
│  app.py          │      │  app.py                   │
│  README.md       │      │  README.md                │
│  src/            │      │  src/                     │
│    main.js       │      │    main.js                │
└─────────────────┘      │  vendor/                  │
                          │    awesome-lib/   ←──┐    │
                          │      lib.js         │    │
                          │      README.md      │    │
                          │      .git           │    │
                          └──────────────────────┴────┘
                                    Externes Repo
                                    (komplett + History)
```

### Zwei Varianten

| Befehl | Effekt |
|---|---|
| `git subtree add --prefix=dst <repo> <ref>` | **High-Level**: Kopiert externes Repo nach `dst/` |
| `git merge -s subtree <branch>` | **Low-Level**: Merge-Strategie, die automatisch in Unterordner verschiebt |

Beide machen am Ende dasselbe — `subtree add` ruft intern `merge -s subtree` auf.

### Warum Subtree statt Submodule?

| Submodule | Subtree |
|---|---|
| Zeiger (Link) auf externen Commit | Echter Inhalt im Repo |
| Extra-Schritt beim Klonen (`--recursive`) | Nichts — alles sofort da |
| Externes Repo separat verwalten | Externes Repo = Teil des eigenen |
| Änderungen im Submodul = eigener Push | Änderungen = normaler Commit im eigenen Repo |

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

### Demo A: Externes Projekt per `subtree add` einbinden

**Ziel:** Das externe `git-subtree`-Repo als Unterordner `vendor/bootstrap/` ins eigene Projekt holen.

**Ausgangssituation:**
```bash
ls
# → README.md  app.js  index.html  src/  style.css
#    Kein vendor/! Das Projekt ist noch clean.
```

```bash
git subtree add --prefix=vendor/bootstrap \
  https://github.com/tdangschulz/git-subtree.git main \
  -m "chore: Bootstrap per Subtree eingebunden"
```

**👣 Schritt für Schritt, was Git intern macht:**

| Schritt | Was passiert | Für den User sichtbar? |
|---|---|---|
| **1. Fetch** | Git kontaktiert `https://github.com/tdangschulz/git-subtree.git` und lädt den `main`-Branch in den temporären Cache (`FETCH_HEAD`) | Ja — „git fetch … main" erscheint in der Ausgabe |
| **2. Metadaten anpassen** | Git merkt sich: die Dateien aus dem externen Repo müssen nach `vendor/bootstrap/` verschoben werden (das `--prefix`). Die History bleibt aber **unverändert** erhalten | Nein — passiert im Hintergrund |
| **3. Merge ausführen** | Git führt intern `git merge -s subtree FETCH_HEAD` aus. Die `-s subtree`-Strategie sorgt dafür, dass alle Pfade automatisch um `vendor/bootstrap/` ergänzt werden | Ja — „Merge made by the 'subtree' strategy." |
| **4. Merge-Commit erstellen** | Ein neuer Commit mit **zwei Eltern** entsteht: Eltern 1 = dein vorheriger `main`, Eltern 2 = der letzte Commit des externen Repos (`c3c514f feat: Primary Button`). Die Commit-Message ist dein `-m`-Text | Ja — im `git log` sichtbar |
| **5. Arbeitsverzeichnis aktualisieren** | Der gesamte Inhalt von `git-subtree` liegt jetzt physisch unter `vendor/bootstrap/` | Ja — `ls vendor/bootstrap/` zeigt die Dateien |

---

**🔍 Prüfen Schritt 1: Der Ordner ist da**

```bash
ls vendor/bootstrap/
# → bootstrap.css  grid.css  LICENSE  README.md
```

Alle Dateien des externen Repos liegen jetzt **physisch** in deinem Projekt.

---

**🔍 Prüfen Schritt 2: Der Merge-Commit im Log**

```bash
git log --oneline --graph --all
```

```
*   1234567 chore: Bootstrap per Subtree eingebunden      ← NEU: Merge-Commit
|\\
| * c3c514f feat: Primary Button                          ← externe History
| * c7ef15b feat: Grid-System
| * c94b50e feat: Button-Styles
| * 6119724 chore: Lizenz hinzugefügt
| * b5c3180 Initial commit: Bootstrap v1.0
*
* eb110ab feat: Basis-Stylesheet                          ← deine eigenen Commits
* c2ab766 feat: Version-Modul
* fc6200b feat: Hello-Funktion
* 373f871 feat: JavaScript-Grundstruktur
* f858d9e Initial commit: WebApp-Setup
```

**Wichtig:** Die 5 Bootstrap-Commits (`b5c3180` → `c3c514f`) sind **nicht** in deinem Repo passiert. Sie wurden vom externen Repo übernommen. Die Pfeile `|` und `\\` zeigen, dass der Merge-Commit zwei Eltern hat.

---

**🔍 Prüfen Schritt 3: History einzelner Dateien**

```bash
git log --oneline vendor/bootstrap/bootstrap.css
# → Zeigt NUR die Commits, die bootstrap.css betreffen:
#   c3c514f feat: Primary Button
#   c94b50e feat: Button-Styles
#   b5c3180 Initial commit: Bootstrap v1.0
```

Git trackt jede Datei einzeln — auch über Repo-Grenzen hinweg.

---

**🗣️ Zu erklären:**

> **„Externes Projekt lokal verfügbar machen — alle Dateien liegen physisch im Repo, kein Submodule-Update nötig beim Klonen."**

---

### Demo B: Updates vom externen Projekt ziehen

**Ziel:** Eine neue Version des externen Projekts (v2.0) einspielen — so wie du später `git pull` machen würdest, um Updates einer Library zu bekommen.

**Voraussetzung:** Ein neuer Commit muss im externen Repo existieren.

**Variante — Commit ins echte GitHub-Repo pushen:**

Öffne <https://github.com/tdangschulz/git-subtree> im Browser, editiere `bootstrap.css` und ersetze `v1.2` durch `v2.0`.

**Oder lokal (braucht kein Internet):**
```bash
git clone https://github.com/tdangschulz/git-subtree.git /tmp/git-subtree
cd /tmp/git-subtree
echo "/*! Bootstrap v2.0 */" > bootstrap.css
git add . && git commit -m "Release v2.0"
git push origin main
cd -
```

**Jetzt das Update einspielen:**

```bash
git subtree pull --prefix=vendor/bootstrap \
  https://github.com/tdangschulz/git-subtree.git main \
  -m "chore: Bootstrap auf v2.0 aktualisiert"
```

---

**👣 Schritt für Schritt, was Git intern macht:**

| Schritt | Was passiert | Für den User sichtbar? |
|---|---|---|
| **1. Fetch** | Wie bei `git fetch`: Git lädt die neue Historie vom externen Repo. Der neue Commit (v2.0) landet im lokalen Cache | Ja — „From https://github.com/…" |
| **2. Merge-Base suchen** | Git sucht den **gemeinsamen Vorfahren** zwischen der aktuellen `vendor/bootstrap/` und dem externen `main`. In unserem Fall: der letzte Merge-Commit aus Demo A | Nein |
| **3. 3-Wege-Merge** | Git vergleicht drei Versionen:
   - **Base:** Der letzte gemeinsame Stand (Bootstrap v1.2)
   - **Ours:** Dein aktuelles `vendor/bootstrap/` (v1.2, unverändert)
   - **Theirs:** Der neue externe Commit (v2.0)
   Da du keine lokalen Änderungen hattest, ist das ein **Clean Fast-Forward** | Ja — „Merge made by the 'subtree' strategy." |
| **4. Neuer Merge-Commit** | Ein weiterer Merge-Commit entsteht. Eltern 1 = dein alter `main`, Eltern 2 = der v2.0 Commit | Ja |
| **5. vendor/ aktualisieren** | `vendor/bootstrap/bootstrap.css` enthält jetzt „Bootstrap v2.0" | Ja |

---

**🔍 Prüfen:**

```bash
cat vendor/bootstrap/bootstrap.css
# → /*! Bootstrap v2.0 */
```

```bash
git log --oneline vendor/bootstrap/
# → Zeigt jetzt auch den neuen v2.0 Commit aus dem externen Repo
```

```bash
git log --oneline --graph --all
# → Wieder ein Merge-Commit, diesmal mit zwei Commits mehr:
#   - chore: Bootstrap auf v2.0 aktualisiert  (dein Merge)
#   - Release v2.0                             (extern)
```

---

**🗣️ Zu erklären:**

> **„`subtree pull` ist nur `git fetch` + `git merge -s subtree`. Genau wie `git pull` = `git fetch` + `git merge`, nur mit Subtree-Strategie.**"

---

### Demo C: Low-Level — `git merge -s subtree`

**Ziel:** Dasselbe wie Demo B, aber **ohne** den `git subtree`-Wrapper.
Du siehst: `git subtree` ist nur ein Komfortbefehl für `git fetch` + `git merge -s subtree`.

**Ausgangssituation:** Mach Demo A und B rückgängig, um bei einem sauberen Stand zu starten (nur WebApp + Bootstrap v1.0 via subtree add):

```bash
git reset --hard HEAD~1
# Entfernt den Merge-Commit aus Demo B.
# vendor/bootstrap/ ist wieder auf v1.2
```

---

**Schritt 1: Fetch — das externe Repo lokal verfügbar machen**

Ohne `git subtree pull` müssen wir das externe Repo selbst fetchen:

```bash
git fetch https://github.com/tdangschulz/git-subtree.git main:refs/remotes/extern/bootstrap
```

**Was passiert?**

| Teil | Bedeutung |
|---|---|
| `git fetch <url> <src>:<dst>` | Holt den `main`-Branch des externen Repos |
| `refs/remotes/extern/bootstrap` | Speichert ihn als Remote-Tracking-Branch `extern/bootstrap` (ein lokaler Alias) |

**Prüfen:**
```bash
git branch -a
# → remotes/extern/bootstrap  ← der neue Remote-Branch
```

---

**Schritt 2: Merge mit Subtree-Strategie**

```bash
git merge -s subtree \
  extern/bootstrap -m "chore: Bootstrap v2.0 (merge -s subtree)"
```

**Was passiert Schritt für Schritt:**

| Schritt | Was passiert |
|---|---|
| **1. Merge-Base** | Git findet automatisch den gemeinsamen Vorfahren: den Subtree-Merge-Commit aus Demo A. Kein `--allow-unrelated-histories` nötig |
| **2. `-s subtree`** | Sagt Git: „Beim Mergen verschiebe alle Dateien aus `extern/bootstrap` automatisch in den Subtree-Pfad, den Git aus dem letzten Subtree-Merge kennt" (= `vendor/bootstrap/`) |
| **3. Merge-Commit** | Wie in Demo B: ein Merge-Commit mit zwei Eltern |

**Ohne `-s subtree`** würden die Bootstrap-Dateien im Root landen (siehe Demo E).

---

**🔍 Prüfen — gleiches Ergebnis wie Demo B:**

```bash
git log --oneline --graph --all
# → Selbe Struktur wie nach Demo B:
#   Einen Merge-Commit, dahinter den v2.0 Commit
```

```bash
cat vendor/bootstrap/bootstrap.css
# → /*! Bootstrap v2.0 */
```

---

**🗣️ Zu erklären:**

> **„`git subtree add/pull` sind Wrapper. Intern machen sie genau das hier: `git fetch` + `git merge -s subtree`. Der einzige Zusatz von `subtree` ist die `--prefix`-Verwaltung — Git merkt sich, in welchen Ordner die Dateien gehören, und wendet das bei jedem Subtree-Merge automatisch an.**"

---

### Demo D: Eigene Änderungen ans externe Projekt zurückgeben

Du hast Bootstrap in deinem Projekt angepasst und willst die Änderung
ins originale Repo zurückspielen:

```bash
# Änderung in vendor/bootstrap/ vornehmen
echo "/* Angepasst für WebApp */" >> vendor/bootstrap/bootstrap.css
git add vendor/bootstrap/
git commit -m "fix: Bootstrap an WebApp angepasst"

# Änderungen ans externe Repo zurückgeben
git subtree push --prefix=vendor/bootstrap \
  https://github.com/tdangschulz/git-subtree.git main
```

> **🗣️ Erklären:** `subtree push` splittet die History aus dem Unterordner
> und erzeugt entsprechende Commits im externen Repo. So bleibt der
> Zusammenhang erhalten.

---

### Demo E: Was passiert OHNE `-s subtree`?

**Wichtig zu verstehen:** Ohne die Subtree-Strategie landen die Dateien
im Root statt im gewünschten Ordner!

```bash
# Neues externes Projekt (ohne subtree-Strategie!)
git fetch https://github.com/tdangschulz/git-subtree.git main:refs/remotes/extern/bootstrap-ohne

git merge --allow-unrelated-histories \
  extern/bootstrap-ohne -m "Merge ohne subtree"

ls           # bootstrap.css liegt im ROOT!
```

**Aufräumen:**
```bash
git reset --hard ORIG_HEAD
```

> **🗣️ Erklären:** `-s subtree` erkennt: "Die Dateien kamen aus einem separaten
> Repo — ich verschieb sie automatisch in den passenden Ordner."
> Ohne dieses Flag landen sie stumpf im aktuellen Verzeichnis.

---

### Demo F: Subtree mit `--squash`

Manchmal willst du nicht die ganze 5-Commit-History importieren:

```bash
# Squash-Variante
git subtree add --prefix=vendor/bootstrap --squash \
  https://github.com/tdangschulz/git-subtree.git main \
  -m "chore: Bootstrap (gesquasht)"

git log --oneline vendor/bootstrap/
# → Nur ein Commit: "chore: Bootstrap (gesquasht)"
```

**Vergleich zur vollen History:**
```bash
git reset --hard HEAD~1

# Ohne --squash:
git subtree add --prefix=vendor/bootstrap \
  https://github.com/tdangschulz/git-subtree.git main \
  -m "chore: Bootstrap (volle History)"

git log --oneline vendor/bootstrap/
# → ALLE Bootstrap-Commits sichtbar
```

> **🗣️ Erklären:** `--squash` = History vom externen Projekt in einen
> Commit zusammengefasst. Sauberer, aber du verlierst die Zwischenschritte.
> Gut für große, stabile Libraries. Volle History bei kleinen Projekten
> oder wenn du die Entwicklung nachvollziehen willst.

---

### Vollständige Demo (alles in einem Durchlauf)

```bash
# === Setup ===
cd demos/16-subtree-demo/start
ls  # kein vendor/ - alles noch clean

# === 1) Subtree einbinden ===
git subtree add --prefix=vendor/bootstrap \
  https://github.com/tdangschulz/git-subtree.git main \
  -m "chore: Bootstrap eingebunden"

# === 2) Update pullen ===
git subtree pull --prefix=vendor/bootstrap \
  https://github.com/tdangschulz/git-subtree.git main \
  -m "chore: Bootstrap auf v2.0"

# === 3) Eigene Änderung + Push zurück ===
echo "/* WebApp-Anpassung */" >> vendor/bootstrap/bootstrap.css
git add vendor/bootstrap/
git commit -m "fix: An WebApp angepasst"

git subtree push --prefix=vendor/bootstrap \
  https://github.com/tdangschulz/git-subtree.git main

# === 4) Prüfen ===
git log --oneline --graph --all
```

---

## 🔍 Zusammenfassung

| Befehl | Wirkung |
|---|---|
| `git subtree add --prefix=<dir> <repo> <ref>` | Externes Repo einbinden |
| `git subtree pull --prefix=<dir> <repo> <ref>` | Updates vom externen Repo holen |
| `git subtree push --prefix=<dir> <repo> <ref>` | Eigene Änderungen zurückgeben |
| `git merge -s subtree <branch>` | Low-Level: Merge mit automatischer Verschiebung |
| `--squash` | Externe History in einen Commit packen |

**Die goldene Regel:**
> `git subtree` = `git fetch + git merge -s subtree` + automatisierte Pfad-Verschiebung.

---

## 📚 Weiterführend

- Externes Projekt für diese Demo: <https://github.com/tdangschulz/git-subtree>
- `git subtree` ist kein Built-in-Befehl — steckt in `git-contrib` und ist bei den meisten Distributionen vorinstalliert
- [`git-merge-subtree`](https://git-scm.com/docs/git-merge#Documentation/git-merge.txt-merge-strategies) in der Git-Manpage
- Submodule: `git submodule add <repo> <pfad>` — alternative, verlinkte Lösung
