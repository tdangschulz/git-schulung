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

```bash
git subtree add --prefix=vendor/bootstrap \
  https://github.com/tdangschulz/git-subtree.git main \
  -m "chore: Bootstrap per Subtree eingebunden"
```

**Was passiert?**
1. Der gesamte Inhalt von `git-subtree` wird nach `vendor/bootstrap/` kopiert
2. Ein Merge-Commit wird erzeugt
3. Die komplette History des externen Projekts bleibt erhalten

**Prüfen:**
```bash
ls vendor/bootstrap/           # Alle Bootstrap-Dateien
git log --oneline --graph --all  # Merge-Commit sichtbar
git log --oneline vendor/bootstrap/bootstrap.css  # Volle Bootstrap-History!
```

> **🗣️ Erklären:** Andere klonen dein Repo → `vendor/bootstrap/` ist sofort da.
> Kein `git submodule update` nötig. Alle Dateien sind "echt" im Repo.

---

### Demo B: Updates vom externen Projekt ziehen

Mach einen neuen Commit im externen Repo auf GitHub und pull ihn rein:

```bash
# Neues Release im externen Repo (z.B. auf GitHub UI oder lokal klonen)
# Release v2.0 auf main pushen …

# Update ins Hauptprojekt holen
git subtree pull --prefix=vendor/bootstrap \
  https://github.com/tdangschulz/git-subtree.git main \
  -m "chore: Bootstrap auf v2.0 aktualisiert"
```

**Prüfen:**
```bash
cat vendor/bootstrap/bootstrap.css   # Zeigt v2.0
git log --oneline vendor/bootstrap/  # Neue Version sichtbar
```

> **🗣️ Erklären:** `subtree pull` = `fetch + merge -s subtree`.
> Die History bleibt erhalten — du siehst genau, wann aktualisiert wurde.

---

### Demo C: Low-Level — `git merge -s subtree`

Mach dasselbe nochmal, aber **ohne** das `subtree`-Kommando:

```bash
# Zurücksetzen auf den Stand vor Demo B
git reset --hard HEAD~1

# Fetch vom externen Repo
git fetch https://github.com/tdangschulz/git-subtree.git main:refs/remotes/extern/bootstrap

# Merge MIT subtree-Strategie
git merge -s subtree --allow-unrelated-histories \
  extern/bootstrap -m "chore: Bootstrap v2.0 (merge -s subtree)"
```

**Vergleiche das Log:**
```bash
git log --oneline --graph --all
```

> **🗣️ Erklären:** `git subtree` ist nur ein Wrapper für `fetch + merge -s subtree`.
> Das `-s subtree` sorgt dafür, dass Git die Dateien automatisch nach
> `vendor/bootstrap/` verschiebt — obwohl sie im externen Repo im Root lagen.

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
