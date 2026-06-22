# Git Schulung – 2-Tage Workshop

## Übersicht

**Dauer:** 2 Tage (jeweils ~4-5 Stunden)
**Ziel:** Vom ersten `git init` bis zum sicheren Umgang mit Branches, Merges und Konflikten
**Voraussetzungen:** Git installiert (`git --version` prüfen), Terminal/Git Bash

```
# Installation prüfen
git --version
# Sollte z.B. git version 2.40.0 ausgeben
```

---

## Tag 1: Grundlagen (lokal)

### 1.1 Git initialisieren

```bash
# Projektordner erstellen
mkdir ~/git-workshop
cd ~/git-workshop

# Git-Repo initialisieren
git init
# Ausgabe: Initialized empty Git repository in /home/user/git-workshop/.git/
```

### 1.2 Git konfigurieren

```bash
# Das macht man EINMAL pro Rechner (global)
git config --global user.name "Dein Name"
git config --global user.email "deine@email.de"

# Editor setzen (z.B. Nano, Vim, VS Code)
git config --global core.editor "nano"

# Zeilenumbrüche (Windows vs Linux/Mac)
git config --global core.autocrlf input   # Linux/Mac
# git config --global core.autocrlf true  # Windows

# Konfig anzeigen
git config --list

# Projekt-spezifische Config (nur für dieses Repo)
git config user.name "Workshop User"
```

### 1.3 Erster Commit

```bash
# Datei erstellen
echo "# Mein Projekt" > README.md
echo "node_modules/" > .gitignore
echo "*.log" >> .gitignore

# Status prüfen
git status
# Zeigt: README.md und .gitignore sind "untracked"

# Dateien zum Commit vorbereiten (stagen)
git add README.md
git add .gitignore
# Oder alles auf einmal:
# git add .

# Status nach dem Stagen
git status
# Zeigt: "Changes to be committed"

# Ersten Commit machen
git commit -m "Initial commit: README und .gitignore"

# Log anzeigen
git log
# Oder kompakter:
git log --oneline
```

### 1.4 Änderungen vornehmen

```bash
# README erweitern
echo "" >> README.md
echo "## Installation" >> README.md
echo "npm install" >> README.md

# Status prüfen
git status
# README.md ist jetzt "modified"

# Diff anzeigen (was hat sich geändert?)
git diff

# Stagen und committen
git add README.md
git commit -m "Installationsanleitung hinzugefügt"

# Noch eine Runde
echo "## Nutzung" >> README.md
echo "npm start" >> README.md
git add README.md
git commit -m "Nutzungshinweis hinzugefügt"

# Historie anzeigen
git log --oneline
# Sollte 3 Commits zeigen
```

### 1.5 Dateien löschen/verschieben

```bash
# Datei erstellen und committen
echo "temporary" > temp.txt
git add temp.txt
git commit -m "Temporäre Datei"

# Datei löschen (Git-typisch)
git rm temp.txt
git commit -m "Temp-Datei entfernt"

# Datei verschieben/umbenennen
git mv README.md README_alt.md
git commit -m "README umbenannt"
git mv README_alt.md README.md
git commit -m "README zurück benannt"
```

### 1.6 Änderungen rückgängig machen

```bash
# Ungestagte Änderungen verwerfen
echo "Test" > test.txt
git add test.txt
echo "Überschrieben" > test.txt
git checkout -- test.txt
# test.txt ist wieder der gestagte Inhalt

# Gestagte Änderungen unstagen
echo "neu" > neue-datei.txt
git add neue-datei.txt
git reset HEAD neue-datei.txt
# Datei ist wieder untracked

# Letzten Commit rückgängig machen (Änderungen bleiben im Working Directory)
git commit -m "Falscher Commit"
git reset --soft HEAD~1
# Änderungen sind wieder gestaged – man kann neu committen

# Komplett rückgängig (Änderungen weg!)
# VORSICHT: unwiderruflich!
# git reset --hard HEAD~1

# Oder: revert (sicherer, da neuer Commit)
git commit -m "Noch ein Commit"
git revert HEAD --no-edit
# Erzeugt einen neuen Commit, der die Änderungen rückgängig macht
git log --oneline
```

### 1.7 Branches – Die Basics

**Was ist ein Branch?** Ein Zeiger auf einen bestimmten Commit. Man kann davon abzweigen, ohne den Hauptstrang zu beeinflussen.

```bash
# Branches anzeigen
git branch
# * master (oder * main – der Stern zeigt den aktuellen Branch)

# Neuen Branch erstellen
git branch feature/login

# Alle Branches
git branch -a

# Branch wechseln
git checkout feature/login
# Oder moderner:
git switch feature/login

# In einem Branch arbeiten
echo "const login = () => {}" > login.js
git add login.js
git commit -m "Login-Funktion hinzugefügt"

# Log mit Branch-Anzeige
git log --oneline --graph --all
```

### 1.8 Schnellübung Tag 1

```bash
# 1. Neues Repo in ~/git-uebung
mkdir ~/git-uebung && cd ~/git-uebung && git init

# 2. index.html mit Grundgerüst
echo "<!DOCTYPE html><html><head><title>Test</title></head><body>Hallo</body></html>" > index.html
git add index.html && git commit -m "HTML Grundgerüst"

# 3. style.css
echo "body { color: red; }" > style.css
git add style.css && git commit -m "CSS hinzugefügt"

# 4. Branch für neue Feature
git checkout -b feature/header
echo "<header>Navigation</header>" >> index.html
git add index.html && git commit -m "Header hinzugefügt"

# 5. Zurück zu main, ändere Farbe
git checkout main
echo "body { color: blue; }" > style.css
git add style.css && git commit -m "Farbe auf blau geändert"

# 6. Zeige Graphen
git log --oneline --graph --all
```

---

## Tag 2: Zusammenarbeit & Merge

### 2.1 Branches mergen

```bash
# Ausgangssituation: main + feature/login
cd ~/git-workshop
git log --oneline --graph --all

# Feature in main mergen
git checkout main
git merge feature/login
# Wenn kein Konflikt: Fast-Forward-Merge (main wurde einfach vorgezogen)

# Oder mit --no-ff (erzwingt Merge-Commit)
git merge --no-ff feature/login -m "Feature-Login gemergt"
git log --oneline --graph --all
```

### 2.2 Merge-Konflikte erzeugen & lösen

```bash
# === KONFLIKT VORBEREITEN ===

# Auf main: config-Datei
git checkout main
echo '{"version": "1.0"}' > config.json
git add config.json && git commit -m "Config v1.0"

# Branch feature/darkmode
git checkout -b feature/darkmode
echo '{"version": "1.0", "theme": "dark"}' > config.json
git add config.json && git commit -m "Darkmode-Theme hinzugefügt"

# Auf main: andere Änderung an config.json
git checkout main
echo '{"version": "1.1"}' > config.json
git add config.json && git commit -m "Config auf v1.1"

# === KONFLIKT AUSLÖSEN ===
git merge feature/darkmode
# Ausgabe: CONFLICT (content): Merge conflict in config.json
# Automatic merge failed; fix conflicts and then commit the result.

# === KONFLIKT LÖSEN ===
cat config.json
# <<<<<<< HEAD
# {"version": "1.1"}
# =======
# {"version": "1.0", "theme": "dark"}
# >>>>>>> feature/darkmode

# Manuell bearbeiten – gewünschten Inhalt lassen:
# {"version": "1.1", "theme": "dark"}

# Nach dem Fix:
git add config.json
git commit -m "Merge feature/darkmode – Konflikt gelöst"
git log --oneline --graph --all
```

### 2.3 Rebase — Die Grundlagen

**Merge vs Rebase:**
- `merge` = "Ich nehme deine Änderungen und meine"
- `rebase` = "Ich setze meine Commits oben drauf" (linearere Historie)

```bash
# Rebase vorbereiten
git checkout main
echo "// Start" > app.js
git add app.js && git commit -m "App initial"

git checkout -b feature/api
echo "// API-Client" > api.js
git add api.js && git commit -m "API-Client"

# Währenddessen auf main:
git checkout main
echo "// Config" > config.js
git add config.js && git commit -m "Config hinzugefügt"

# Jetzt rebase: feature/api auf main setzen
git checkout feature/api
git rebase main
# feature/api-Commits sind jetzt neu auf main draufgesetzt

git log --oneline --graph --all
# Viel sauberer als Merge!
```

### 2.4 Rebase-Konflikt lösen

```bash
# Konflikt provozieren
git checkout main
echo "const COLOR = 'red';" > styles.js
git add styles.js && git commit -m "Farbe rot"

git checkout -b feature/neue-farbe
echo "const COLOR = 'blue';" > styles.js
git add styles.js && git commit -m "Farbe blau"

git checkout main
echo "const COLOR = 'green';" > styles.js
git add styles.js && git commit -m "Farbe grün"

# Rebase mit Konflikt
git checkout feature/neue-farbe
git rebase main
# CONFLICT in styles.js

# Datei fixen (gewünschte Farbe wählen)
echo "const COLOR = 'blue';" > styles.js
git add styles.js
git rebase --continue
# Kein -m nötig – Rebase übernimmt die Commit-Message
```

### 2.5 Rebase Deep Dive — Wie es wirklich funktioniert

#### 🧠 Was passiert beim Rebase intern?

Rebase ist kein magisches „Bäume umstecken". Intern macht Git für JEDEN
Commit auf deinem Branch Folgendes:

1. **Finde den gemeinsamen Vorfahren** (Merge Base) der beiden Branches
2. **Sammle alle Commits** seit diesem Vorfahren auf deinem Branch
3. **Setze den Branch-Pointer** auf die Spitze des Ziel-Branches
4. **Spiele jeden gesammelten Commit einzeln neu ein** (cherry-pick)

```bash
# Ausgangssituation:
# main:     A---B---C
#                \
# feature:         D---E

# git rebase main (von feature aus) macht:
# 1. Merge-Base = B
# 2. Sammelt: D, E
# 3. Setzt feature auf C (Spitze von main)
# 4. Spielt D' und E' neu ein (neue Hashes!)
#
# Ergebnis:
# main:     A---B---C
#                   \
# feature:            D'---E'
```

⚠️ **Wichtig:** Die neu eingespielten Commits (D', E') haben **neue Hashes**,
obwohl der Inhalt identisch ist. Das ist der Grund, warum man **niemals**
Commits rebasen soll, die andere bereits haben (siehe Golden Rule).

---

#### 🔄 Interaktives Rebase (`rebase -i`)

Mit `git rebase -i` kann man Commits umschreiben: umsortieren, löschen,
verschmelzen oder Nachrichten ändern.

```bash
# Die letzten 3 Commits bearbeiten
git rebase -i HEAD~3

# Öffnet einen Editor mit:
# pick abc1234 Erster Commit
# pick def5678 Zweiter Commit
# pick 7890abc Dritter Commit
#
# Mögliche Befehle:
# pick    = Commit behalten (default)
# reword  = Nur die Commit-Nachricht ändern
# edit    = Commit-Inhalt ändern
# squash  = Mit vorherigem Commit verschmelzen
# fixup   = Wie squash, aber Nachricht verwerfen
# drop    = Commit löschen
#
# Beispiel: Zwei Commits zusammenführen:
# pick abc1234 Erster Commit
# squash def5678 Zweiter Commit  ← wird in ersten gemerged
# pick 7890abc Dritter Commit
```

**Häufigste Anwendung: letzte Commit-Nachricht ändern**

```bash
# Noch schneller als rebase -i:
git commit --amend -m "Neue Nachricht"
# Ändert den letzten Commit (erzeugt neuen Hash!)
```

---

#### 🎯 Rebase vs. Merge — Wann was?

| Situation | Merge | Rebase |
|---|---|---|
| Feature-Branch lokal | ❌ | ✅ Saubere Historie |
| Feature-Branch öffentlich (PR) | ✅ Sichtbar | ❌ Niemals! |
| main auf den neuesten Stand bringen | ✅ | ✅ (`pull --rebase`) |
| Mehrere Commits zusammenfassen | ❌ | ✅ (`rebase -i squash`) |
| Große Teams, viele Branches | ✅ Klar | ⚠️ Nur mit Disziplin |

**Faustregel:**
- **Rebase lokal, merge öffentlich**
- Wenn du der Einzige auf einem Branch bist → rebase ruhig
- Wenn jemand anders den Branch hat → nie rebasen (zerstörst deren History)
- Für `git pull` → `git pull --rebase` ist oft besser als `git pull` (kein lästiger
  Merge-Commit beim Aktualisieren)

---

#### 🚨 Die Goldene Regel des Rebase

> **Rebase niemals Commits, die bereits auf einem öffentlichen Remote liegen
> und von anderen genutzt werden!**

**Warum?**
- Rebase schreibt History um (neue Hashes)
- Andere haben die alten Hashes lokal
- Chaos: Merge-Konflikte, doppelte Commits, "Geister-Commits"

**✅ Erlaubt:**
- Deine lokalen, noch nicht gepushten Commits
- Deinen eigenen Feature-Branch vor dem PR
- Commits in einem PR-Branch (solange du allein dran arbeitest)

**❌ Verboten:**
- `main` oder `dev` auf einem Remote
- Branches, an denen andere mitarbeiten
- Bereits gepushte Commits (außer dir gehört der Branch allein und
  du weisst, was du tust)

```bash
# SICHER: Nur lokale Commits vor dem ersten Push
# ...committen, committen, committen...
git rebase -i HEAD~3  # Noch lokal, kein Problem

# UNSICHER: Bereits gepushte Commits rebasen
# git push  ← schon passiert
# ...
# git rebase main  ← JETZT HAST DU EIN PROBLEM
# git push --force-with-lease  ← Überschreibt Remote, andere hassen dich
```

---

#### 🛟 Rebase-Abbruch & Wiederherstellung

**Rebase mittendrin abbrechen:**
```bash
git rebase --abort
# Alles wieder wie vor dem Rebase
```

**Rebase war erfolgreich, aber das Ergebnis gefällt nicht:**
```bash
# Mit Reflog den alten Stand finden
git reflog
# Finde den Commit VOR dem Rebase (z.B. abc1234)
git reset --hard abc1234
# Alles zurückgesetzt
```

**Rebase mit Konflikt überspringen (ein Commit auslassen):**
```bash
git rebase --skip
# Nächsten Commit überspringen (Vorsicht: Inhalt geht verloren!)
```

---

#### 💡 Advanced: `pull --rebase` als Standard

```bash
# Globalen Default setzen (empfohlen):
git config --global pull.rebase true

# Dann reicht:
git pull
# = git fetch + git rebase (statt git merge)
# Keine nervigen Merge-Commits beim Pull mehr!

# Einmalig:
git pull --rebase
```

---

#### 🖥️ Trainer-Live-Demo: Interactive Rebase

**Ziel:** Zeigen wie man Commits mit `rebase -i` verschmelzen kann.

```bash
cd /tmp/git-schulung
mkdir -p demo-rebase && cd demo-rebase
git init

# Mehrere Kleinschritte als einzelne Commits
echo "# Start" > index.html
git add index.html && git commit -m "html datei erstellt"
echo "<body>" >> index.html
git add index.html && git commit -m "body tag"
echo "<h1>Titel</h1>" >> index.html
git add index.html && git commit -m "titel"
echo "<p>Text</p>" >> index.html
git add index.html && git commit -m "paragraph"

# Historie: 4 Commits, die eigentlich ein logischer Schritt sind

git log --oneline
# Alle 4 Commits zu einem verschmelzen:
git rebase -i --root
# Ersten Commit auf "pick" lassen, restliche auf "fixup"
# Nach Speichern: Nur noch 1 Commit

git log --oneline
# Viel sauberer!
```

**🗣️ Erklären:** `rebase -i` ist das Schweizer Taschenmesser für
Commit-Historie. Am häufigsten genutzt um "hab vergessen was einzubauen"
Commits zu verschmelzen, bevor man einen PR aufmacht.

---

### 2.7 Stash – Änderungen zwischenspeichern

```bash
# Aktuelle Änderungen weglegen
echo "unfertig" >> README.md
git stash
# Working Directory ist wieder clean

# Stash-Liste
git stash list

# Stash wiederholen
echo "noch was" >> README.md
git stash push -m "Mein Stash mit Nachricht"

# Stash wieder anwenden (ohne zu löschen)
git stash apply stash@{0}

# Stash anwenden + löschen
git stash pop

# Stash löschen
git stash drop stash@{0}

# Alles leeren
git stash clear
```

### 2.8 Remote-Repos (GitHub/GitLab)

```bash
# Remote hinzufügen
git remote add origin https://github.com/dein-user/git-workshop.git

# Remotes anzeigen
git remote -v

# Pushen
git push -u origin main
# -u = upstream setzen (danach reicht "git push")

# Branches pushen
git push origin feature/login

# Von Remote holen
git pull
# = git fetch + git merge

# Oder: nur fetch (holt Infos, merged nicht)
git fetch
git log --oneline --graph --all

# Pull mit Rebase statt Merge
git pull --rebase
# Oder als Default:
git config --global pull.rebase true
```

### 2.9 .gitignore vertiefen

```bash
# Beispiel .gitignore
cat > .gitignore << 'EOF'
# Build-Artifakte
dist/
build/
*.zip

# Abhängigkeiten
node_modules/
vendor/
.pnp.*

# IDE/Editor
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
*.log
npm-debug.log*

# Umgebungsvariablen
.env
.env.local

# Credentials
credentials.json
*.pem
EOF

# .gitignore testen
echo "SECRET=***" > .env
git status
# .env wird NICHT angezeigt!
```

### 2.10 Tags

```bash
# Leichten Tag (nur Name)
git tag v1.0.0

# Annotierten Tag (mit Nachricht)
git tag -a v1.1.0 -m "Release 1.1.0 – Login-Feature"

# Tags anzeigen
git tag

# Tag pushen
git push origin v1.0.0
git push origin --tags  # Alle Tags

# Zu Tag wechseln (read-only)
git checkout v1.0.0
```

### 2.11 Cherry-Pick (einzelne Commits übernehmen)

```bash
# Einen bestimmten Commit in den aktuellen Branch holen
git checkout main
git cherry-pick abc1234  # Hash des gewünschten Commits

# Mehrere Commits
git cherry-pick abc1234 def5678
```

### 2.12 Git Workflows – Überblick

**GitHub Flow (einfach):**
```
main → feature-branch → PR → merge
```

**Git Flow (strukturiert):**
```
main ← develop ← feature/hotfix/release
```

```bash
# Beispiel GitHub Flow
git checkout -b feature/neues-feature
# ... arbeiten, committen ...
git push origin feature/neues-feature
# Auf GitHub: Pull Request erstellen → review → merge
git checkout main
git pull
```

### 2.13 Abschlussübung – Der komplette Workflow

```bash
mkdir ~/git-finale && cd ~/git-finale && git init
git add . && git commit -m "initial commit"

# Teamwork-Simulation:
# Person A: Feature 1
git checkout -b feature/todo-liste
echo "- Einkaufen" > todo.md
git add todo.md && git commit -m "Todo-Liste angelegt"

git checkout main
git merge feature/todo-liste

# Person B: Feature 2
git checkout -b feature/kalender
echo "Kalender-Funktion" > kalender.md
git add kalender.md && git commit -m "Kalender-Feature"

git checkout main
git merge feature/kalender

# Person A & B arbeiten an gleicher Datei -> Konflikt
git checkout -b feature/users
echo "User: Alice" > users.txt
git add users.txt && git commit -m "Alice hinzugefügt"

git checkout main
git checkout -b feature/users-v2
echo "User: Bob" > users.txt
git add users.txt && git commit -m "Bob hinzugefügt"

git checkout main
git merge feature/users
git merge feature/users-v2
# Konflikt! -> lösen

# Fertig!
git log --oneline --graph --all
```

---

## Spickzettel (Cheat Sheet)

| Befehl | Wirkung |
|---|---|
| `git init` | Neues Repo erstellen |
| `git add <datei>` | Datei zum Commit vormerken (stagen) |
| `git commit -m "msg"` | Commit erstellen |
| `git status` | Aktuellen Zustand anzeigen |
| `git log --oneline --graph` | Historie als Graph |
| `git diff` | Ungestagte Änderungen zeigen |
| `git branch <name>` | Branch erstellen |
| `git switch <name>` | Branch wechseln |
| `git checkout -b <name>` | Branch erstellen & wechseln |
| `git merge <branch>` | Branch in aktuellen mergen |
| `git rebase <branch>` | Commits auf anderen Branch setzen |
| `git stash` | Änderungen weglegen |
| `git stash pop` | Stash wieder anwenden |
| `git cherry-pick <hash>` | Einzelnen Commit übernehmen |
| `git reset --soft HEAD~1` | Letzten Commit rückgängig (Änderungen bleiben) |
| `git revert HEAD` | Commit per neuem Commit rückgängig |
| `git remote add origin <url>` | Remote hinzufügen |
| `git push -u origin main` | Zum Remote hochladen |
| `git pull` | Vom Remote holen & mergen |

---

## Merksätze

- **git init = Start** (einmal pro Projekt)
- **git add + git commit = Foto machen** (Momentaufnahme)
- **git branch = Paralleluniversum** (risikofrei experimentieren)
- **git merge = Universum wieder zusammenführen**
- **git rebase = Geschichte neu schreiben** (linearer, aber gefährlicher)
- **Vor git push --force immer dreimal nachdenken!**
- **git log ist dein Freund** (vor allem `--oneline --graph --all`)
- **Bei Konflikten: Ruhe bewahren, Datei editieren, add + commit**
