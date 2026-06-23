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

### Der Weg zum Ziel

`git subtree` ist der Komfort-Wrapper für den ersten Import.
Für Updates reicht danach: `git merge -s subtree`.

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



### Updates vom externen Projekt ziehen

Nach dem ersten Import (egal ob Variante 1 oder 2) ist der Workflow für Updates identisch.

**Update vorbereiten und einspielen:**

Öffne <https://github.com/tdangschulz/git-subtree> im Browser,
editiere `bootstrap.css` (ersetze `v1.2` durch `v2.0`) und committe.

Dann Update ziehen:

```bash
git subtree pull --prefix=vendor/bootstrap bootstrap main --squash \
  -m "chore: Bootstrap auf v2.0 aktualisiert"
```

**Oder per `merge -s subtree` (auch ohne `git subtree`-Paket):**

```bash
git fetch https://github.com/tdangschulz/git-subtree.git \
  main:refs/remotes/extern/bootstrap
git merge -s subtree extern/bootstrap -m "chore: Bootstrap v2.0"
```

Der `-s subtree` Merge-Strategy erkennt den Zielordner automatisch — kein manuelles `git mv` nötig.

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

`git subtree split` extrahiert die Commits aus `vendor/bootstrap/`
und erzeugt daraus einen Branch, der aussieht, als wären die Änderungen
direkt im externen Repo entstanden. So kannst du dann pushen:

```bash
git subtree split --prefix=vendor/bootstrap -b split-branch
git push https://github.com/tdangschulz/git-subtree.git split-branch:main
```

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

**Squash vs. volle History im Vergleich:**
- Mit `--squash` beim `git subtree add`: ein Commit, kompakt
- Ohne `--squash`: alle originalen Commits des externen Repos bleiben erhalten

---

### Git Aliases — Befehle abkürzen

Damit du nicht jedes Mal den ganzen `git subtree ...`-Befehl tippen musst:

```bash
git config --global alias.bootstrap-add '!git subtree add --prefix=vendor/bootstrap https://github.com/tdangschulz/git-subtree.git main --squash -m "chore: Bootstrap eingebunden"'
git config --global alias.bootstrap-pull '!git subtree pull --prefix=vendor/bootstrap https://github.com/tdangschulz/git-subtree.git main --squash -m "chore: Bootstrap aktualisiert"'
git config --global alias.bootstrap-push '!git subtree push --prefix=vendor/bootstrap https://github.com/tdangschulz/git-subtree.git main'
```

Danach reicht:

```bash
git bootstrap-add      # = git subtree add ... (einmalig)
git bootstrap-pull     # = git subtree pull ... (Updates)
git bootstrap-push     # = git subtree push ... (zurückgeben)
```

> Der `--global`-Flag speichert die Aliase in `~/.gitconfig`.
> Mit `git config --global --edit` kannst du sie jederzeit anpassen.

---

### Vollständige Demo (alles in einem Durchlauf)

```bash
# === Setup ===
cd demos/16-subtree-demo/start
ls                                   # kein vendor/

# === 1) Remote hinzufügen und Subtree importieren ===
git remote add bootstrap https://github.com/tdangschulz/git-subtree.git
git subtree add --prefix=vendor/bootstrap bootstrap main --squash \
  -m "chore: Bootstrap eingebunden"
ls vendor/bootstrap/

# === 2) Update ===
git subtree pull --prefix=vendor/bootstrap bootstrap main --squash \
  -m "chore: Bootstrap v2.0"
cat vendor/bootstrap/bootstrap.css

# === 3) Oder Update mit merge -s subtree (ohne git subtree-Paket) ===
git reset --hard HEAD~1
git fetch https://github.com/tdangschulz/git-subtree.git \
  main:refs/remotes/extern/bootstrap
git merge -s subtree extern/bootstrap -m "chore: v2.0 (-s subtree)"
cat vendor/bootstrap/bootstrap.css    # → v2.0

# === 4) Änderung zurückgeben ===
echo "/* WebApp-Anpassung */" >> vendor/bootstrap/bootstrap.css
git add vendor/bootstrap/bootstrap.css
git commit -m "fix: An WebApp angepasst"
git subtree split --prefix=vendor/bootstrap -b split-branch

# === 5) Prüfen ===
git log --oneline --graph --all
```

---

## 🔍 Zusammenfassung

| Befehl | Wirkung |
|---|---|
| `git remote add <name> <url>` | Externes Repo als Remote eintragen |
| `git subtree add --prefix=<ordner> <remote> <branch> --squash` | **Erstmaliger Import** |
| `git subtree pull --prefix=<ordner> <remote> <branch> --squash` | **Updates** |
| `git fetch <url> && git merge -s subtree` | **Updates ohne git subtree** |
| `git subtree split --prefix=<ordner> -b <branch>` | **Zurückgeben** (Contributing Back) |

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
