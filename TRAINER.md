# Git Aufbau — Trainerleitfaden mit Live-Demos 🚀

**2-tägiger Workshop** | Trainer: (eigener Name) | Stand: Juni 2026

Dieser Leitfaden enthält **vollständige, demonstrierbare Beispiele** für jede Session. Jeder Befehl ist mit
einer verständlichen Erklärung versehen — zum Vorlesen, Erklären oder als Merkhilfe.

---

## Vorbereitung vor Tag 1

```bash
# mkdir -p → Erstellt Ordner (auch wenn Elternordner fehlen)
mkdir -p /tmp/git-schulung
cd /tmp/git-schulung

# git init --bare → Erstellt ein reines Repository OHNE Arbeitsverzeichnis
# (Wird nur als zentraler Server zum Pushen/Pullen gebraucht)
git init --bare /tmp/git-schulung/central.git
```

**Hinweis:** Die Teilnehmer brauchen einen Git-Client und (für Remote-Übungen) Zugriff auf GitLab oder ein
gemeinsames Bare-Repo.

---

# Tag 1 — Basics, Branches & Workflows

## 1. Ice Breaker & Vorstellung (08:30 – 09:00)

**Methode:** Trainer + TN stellen sich vor.
Adjektiv-Spiel aus der Folie nutzen.

---

## 2. Wiederholung Git (09:00 – 09:15, 15 Min)

### 🖥️ Live-Demo: Git-Status-Check

**Ziel:** Zeigen wie der Git-Workflow (Working Directory → Staging → Commit) funktioniert.

```bash
# cd → In das Verzeichnis wechseln
cd /tmp/git-schulung

# mkdir -p → Neuen Ordner anlegen (für unser Demo)
mkdir -p recap-demo && cd recap-demo

# git init → Macht aus diesem Ordner ein Git-Repository.
# Ab jetzt wird JEDE Änderung hier von Git überwacht.
git init

# echo "..." > datei → Erstellt eine neue Datei mit Inhalt
echo "# Hallo Git" > README.md

# git status → Zeigt: Welche Dateien sind neu/geändert?
# ROT = ungetrackt/ungeändert, GRÜN = bereit zum Commit
git status

# git add <datei> → Nimmt die Datei in den "Staging-Bereich" (grüne Zone)
# Erst danach "weiß" Git von der Datei
git add README.md

# git commit -m "..." → Macht einen festen Snapshot.
# Der Text in -m ist die Commit-Nachricht (WAS wurde geändert)
git commit -m "Initial commit"

# git log --oneline → Zeigt die Commit-Historie als kompakte Liste
# Jede Zeile = ein Commit mit kurzem Hash + Nachricht
git log --oneline

# echo "..." >> datei → Hängt Text an eine Datei an (>> = anhängen, > = überschreiben)
echo "Zweite Zeile" >> README.md

# git diff → Zeigt UNGESTAGTE Änderungen (was ist anders, aber noch nicht in der grünen Zone)
git diff

# git add + commit in einem (&& = zweiter Befehl läuft nur wenn erster erfolgreich)
git add README.md && git commit -m "Add second line"

# git log --oneline --graph → Zeigt die Historie als ASCII-Grafik
# --graph = Verbindungslinien zwischen Commits
git log --oneline --graph
```

**🗣️ Erklären:** Der Git-Workflow ist immer gleich:
**Arbeitsverzeichnis** (Dateien bearbeiten) → `git add` → **Staging** (grüne Zone) → `git commit` → **Repository** (fest gespeichert)

---

## 3. Arbeiten mit Branches (09:15 – 11:15)

### 3.1 Branches anlegen & wechseln (15 Min)

### 🖥️ Live-Demo: Galaktische Pizza — Branches

**Ziel:** Zeigen wie man Branches erstellt, wechselt und wieder zusammenführt.

```bash
# mkdir + cd → Neues Projekt-Verzeichnis anlegen
cd /tmp/git-schulung
mkdir -p galactic-pizza && cd galactic-pizza

# git init → Aus diesem Ordner ein Git-Repo machen
git init

# Start-Dateien aus der Folie
# cat > datei << 'EOF' ... EOF → Schreibt mehrzeiligen Text in eine Datei
cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="de">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Galaktische Pizza</title>
    <link rel="stylesheet" href="style.css">
  </head>
  <body>
    <header>
        <h1>Willkommen bei Galaktische Pizza!</h1>
        <p id="subtitle">Die beste intergalaktische Pizza für alle Reisenden des Universums!</p>
    </header>
    <main>
    </main>
    <footer>
        <p>© 2123 Galaktische Pizza - Ihre interstellare Geschmacksexplosion</p>
    </footer>
  </body>
</html>
EOF

cat > style.css << 'EOF'
body {
    font-family: 'Arial', sans-serif;
    margin: 0; padding: 0;
    color: #fff; text-align: center;
    background: radial-gradient(circle at 50% 100%, #000428, #2c2c54 80%, #1b2034 100%);
    background-attachment: fixed;
}
h1 {
    color: #ffcc00; font-size: 3rem;
    text-transform: uppercase; letter-spacing: 4px;
    text-shadow: 0px 0px 20px #ffcc00, 0px 0px 40px #ff9900;
    margin-top: 20px;
}
#subtitle { margin-top: 10px; font-size: 1.2rem; color: #a1caf1; text-shadow: 0px 0px 10px #6979f8; }
footer { background: #111; padding: 10px; margin-top: 50px; color: #aaa; font-size: 0.9rem; }
EOF

echo "# Galaktische Pizza" > README.md

# git add . → Nimmt ALLE Dateien im aktuellen Ordner in die grüne Zone (.)
git add .

# git commit -m → Ersten Snapshot machen (Initial-Commit)
git commit -m "Initial commit: Pizza-Website Grundstruktur"

# git branch -a → Zeigt ALLE Branches an (lokal + remote)
# -a = "all". Aktueller Branch hat ein * davor
git branch -a

# git switch -c <name> → Erstellt einen NEUEN Branch UND wechselt sofort dahin
# -c = "create". Wie: git branch <name> + git switch <name>
git switch -c feature/menu

# Menü hinzufügen
# cat >> datei << 'MENU' → Hängt mehrere Zeilen an eine Datei an (>> = anhängen)
cat >> index.html << 'MENU'
    <section id="menu">
        <h2>Unsere Speisekarte</h2>
        <ul>
            <li>🌌 Milchstraßen-Margherita — 12 Credits</li>
            <li>🪐 Saturn-Salami — 15 Credits</li>
            <li>☄️ Asteroid-Ananas (nur im Andromeda-Galaxy) — 18 Credits</li>
        </ul>
    </section>
MENU

git add . && git commit -m "Add menu section with galactic pizzas"

# git switch main → Wechselt ZURÜCK zum main-Branch
git switch main

# git merge feature/menu → Fügt den feature/menu-Branch in main ein
# (= nimmt die Änderungen aus feature/menu und kopiert sie nach main)
git merge feature/menu
# => Fast-Forward: main hatte keine eigenen Commits,
#    also wird main einfach auf die Spitze von feature/menu vorgeschoben

# git branch -d <name> → Löscht den Branch (lokal)
# -d = "delete". Geht nur wenn der Branch schon gemergt wurde
git branch -d feature/menu

# git log --oneline --graph --all → Zeigt die gesamte Historie als Grafik
# --all = ALLE Branches anzeigen, nicht nur den aktuellen
git log --oneline --graph --all
```

**🗣️ Erklären:** `git switch -c` = create + switch in einem Befehl.
Fast-Forward: Wenn main keine eigenen Commits hat, wird main einfach auf feature verschoben —
kein extra Merge-Commit. Wie wenn man einen Zeiger auf einen anderen Punkt setzt.

---

### 3.2 Merge vs. Rebase (60 Min)

### 🖥️ Live-Demo: 3-Way Merge erzeugen

**Ziel:** Zeigen was passiert, wenn BEIDE Branches eigene Commits haben.

```bash
# cd → Ins galactic-pizza Verzeichnis wechseln
cd /tmp/git-schulung/galactic-pizza

# git switch -c → Neuen Branch feature/contact erstellen und wechseln
git switch -c feature/contact

# Im Feature-Branch: Kontaktsektion hinzufügen
cat >> index.html << 'CONTACT'
    <section id="contact">
        <h2>Kontakt</h2>
        <p>Lieferzonen: Mars, Mond, Saturn</p>
        <p>Hyperraum-Telefon: +++-///-1234-5678</p>
    </section>
CONTACT

git add . && git commit -m "Add contact section with delivery zones"

# JETZT: Während feature/contact in Arbeit ist, kommt eine wichtige Änderung in main
git switch main

# sed -i → Ersetzt Text in einer Datei direkt (in-place)
# 's/alter Text/neuer Text/' = suche und ersetze
sed -i 's/© 2123/© 2170/' index.html

git add . && git commit -m "Update copyright year to 2170"

# git log --oneline --graph --all → Zeigt: die beiden Branches sind auseinander gelaufen!
# (Feature hat einen Commit, main hat einen anderen Commit — verschieden!)
git log --oneline --graph --all

# Jetzt feature/contact mergen → 3-Way Merge (weil beide Branches divergiert sind)
git merge feature/contact -m "Merge feature/contact into main"

# Jetzt sieht man: Es gibt einen EXTRA Merge-Commit mit 2 Eltern
git log --oneline --graph --all
```

**🗣️ Erklären:** Weil main UND feature/contact beide neue Commits haben (die Basis ist unterschiedlich),
kann Git keinen Fast-Forward machen. Git erzeugt einen **Merge-Commit** mit zwei Vorgängern
(Eltern). Das nennt man **3-Way Merge** (Basis + Branch A + Branch B).

---

### 🖥️ Live-Demo: Rebase — Historie glattbügeln

**Ziel:** Zeigen wie Rebase eine lineare Historie erzeugt (vs. Merge-Commit).

```bash
# rm -rf → Löscht alten Ordner restlos (für frischen Start)
cd /tmp/git-schulung && rm -rf rebase-demo

# mkdir + cd → Neues Demo-Verzeichnis
mkdir rebase-demo && cd rebase-demo

# git init → Neues Repo
git init

echo "Zeile 1" > datei.txt
git add . && git commit -m "Initial commit"

# Feature-Branch anlegen
git switch -c feature/neu

# 2 Commits im Feature
echo "Feature-Änderung A" >> datei.txt
git add . && git commit -m "Feature commit A"

echo "Feature-Änderung B" >> datei.txt
git add . && git commit -m "Feature commit B"

# Parallel: main hat auch neue Commits
git switch main
echo "Main-Änderung 1" >> datei.txt
git add . && git commit -m "Main commit 1"

# Jetzt: feature/neu ist hinten, main ist vorne.
# Normales Merge würde Merge-Commit erzeugen.
# Rebase = "Setze feature/neu neu auf main drauf"

git switch feature/neu
git log --oneline --graph --all

# git rebase main → Hängt die Feature-Commits HINTER main
# = Nimmt die 2 Feature-Commits weg, holt main nach vorne,
#   setzt die 2 Commits wieder drauf (mit NEUEN Hashes!)
git rebase main

# Ergebnis: feature/neu hängt jetzt an der Spitze von main
# Die Feature-Commits wurden neu geschrieben (neue Hash-Werte!)
git log --oneline --graph --all
```

**🗣️ Erklären:** Rebase = "schneide meine Commits aus, hol den Ziel-Branch nach vorne,
klebe meine Commits wieder drauf". Ergebnis: **lineare Historie**. ABER: Die Commits haben
neue Hashes — das ist wie neue Commits. Deshalb: **Rebase NIE auf öffentlichen Branches!**

---

### 🖥️ Live-Demo: Goldene Regel des Rebasings

**Ziel:** Zeigen was passiert wenn jemand einen geteilten Branch rebased.

```bash
cd /tmp/git-schulung && rm -rf golden-rule && mkdir golden-rule && cd golden-rule

# git init → Starter-Repo
git init
echo "Initial" > file.txt
git add . && git commit -m "Initial"

# git clone <pfad> <ziel> → Kopiert ein komplettes Repo (wie "fork")
# Jeder Entwickler hat sein EIGENES Repo (verteiltes System!)
git clone . /tmp/dev-a-repo
git clone . /tmp/dev-b-repo

# Dev A macht einen Feature-Branch und pushed
cd /tmp/dev-a-repo
git switch -c feature/neu
echo "Dev-A Feature" > feature.txt
git add . && git commit -m "Dev-A feature"

# git push origin feature/neu → Lädt den Branch ins zentrale Repo hoch
# origin = Name des Remote-Repos (meist GitHub/GitLab)
git push origin feature/neu

# Dev B holt den Branch und arbeitet auch drauf
cd /tmp/dev-b-repo

# git fetch → Holt Infos über neue Branches vom Remote (ohne sie zu mergen)
git fetch origin

# git switch feature/neu → Wechselt auf den geholten Branch
git switch feature/neu

echo "Dev-B Ergänzung" >> feature.txt
git add . && git commit -m "Dev-B changes on feature"

# Dev B pushed auch
git push origin feature/neu

# Jetzt: Dev A macht rebase + force push (DAS IST VERBOTEN!)
cd /tmp/dev-a-repo
git switch feature/neu

# git rebase main → Schreibt die lokale History um
git rebase main

# git push --force-with-lease → Erzwingt den Push und ÜBERSCHREIBT
# die History auf dem Remote! Dev-Bs Commits sind weg!
# --force-with-lease ist "sicherer" als --force (prüft ob sich was geändert hat)
git push origin feature/neu --force-with-lease
# => Dev B ist jetzt im Chaos (seine Commits sind weg!)

# Demonstrieren was Dev B sieht
cd /tmp/dev-b-repo

# git fetch → Holt den "neuen" Stand (ohne Dev-Bs Commits)
git fetch origin

# git log → Dev B sieht seine Commits nicht mehr!
git log --oneline --graph --all
# => Dev B's Commits wurden aus der History gelöscht!
```

**🗣️ Erklären:** `git push --force-with-lease` überschreibt die History auf dem Remote.
Andere Entwickler haben dann inkonsistente Repos — ihre Commits sind scheinbar "verschwunden".
**Goldene Regel: Niemals einen öffentlichen/shared Branch rebasen!**
Wenn doch: `git push --force-with-lease` (besser als `--force`, weil es prüft ob jemand
zwischendurch gepusht hat).

---

### 3.3 Stash (10 Min)

### 🖥️ Live-Demo: Arbeitsstand zwischenspeichern

**Ziel:** Zeigen wie man unfertige Arbeit kurz weglegen kann, ohne zu committen.

```bash
cd /tmp/git-schulung/galactic-pizza

# Auf main sein, dann neuen Feature-Branch
git switch main
git switch -c feature/stash-demo

echo "Unfertige Änderung" >> index.html

# git status → Zeigt: "modified: index.html" — da ist was unfertiges
git status

# Oops — dringender Fix in main nötig! Aber der Code ist noch nicht commit-reif.

# git stash -u → Packt ALLE unfertigen Änderungen auf den "Stash-Stack"
# -u = "untracked" — nimmt auch neue Dateien mit (sonst nur getrackte)
# Der Arbeitsordner ist danach wieder sauber!
git stash -u

# git status → Zeigt: "nothing to commit" — alles sauber!
git status

# Fix in main
git switch main
echo "<!-- Security Fix -->" >> index.html
git add . && git commit -m "Hotfix: security header"

# Zurück zum Feature
git switch feature/stash-demo

# git stash list → Zeigt alle gespeicherten Stash-Einträge
# Format: stash@{0}: WIP on feature/stash-demo: <commit-hash> <message>
git stash list

# git stash pop → Nimmt den NEUESTEN Stash-Eintrag und setzt ihn zurück
# = restore + vom Stack löschen (pop = "rausholen und wegwerfen")
git stash pop
# Jetzt ist die unfertige Änderung wieder da!
```

**🗣️ Erklären:** `git stash` = Zwischenablage für unfertige Arbeit.
- `git stash` = nur getrackte Dateien
- `git stash -u` = auch neue/ungetrackte Dateien
- `git stash pop` = wiederherstellen + vom Stack nehmen
- `git stash apply` = wiederherstellen, ABER auf dem Stack lassen (für mehrere Branches)
Der Stack funktioniert wie ein Stapel: `stash@\{0}` ist der neueste.

---

## 4. Git im Team: Workflows (11:15 – 16:30)

### 4.1 Zentraler Workflow (15 Min)

### 🖥️ Live-Demo: Zentraler Workflow mit Konflikt

**Ziel:** Simulieren wie zwei Entwickler parallel arbeiten und Konflikte lösen.

```bash
cd /tmp/git-schulung && rm -rf central-workflow && mkdir central-workflow && cd central-workflow

# git init --bare → Erstellt ein "nacktes" Repository (nur Git-Daten, kein Arbeitsordner)
# Das ist unser "Server" — hier wird nur gepusht/gepullt
git init --bare central.git

# git clone <quelle> <ziel> → Entwickler A holt sich eine Kopie
git clone central.git dev-a
cd dev-a
echo "Dev A's Arbeit" > datei.txt
git add . && git commit -m "Dev A initial"
git push origin main
cd ..

# Entwickler B klont auch
git clone central.git dev-b

# Dev A pusht zuerst
cd dev-a
echo "Zeile von Dev A" >> datei.txt
git add . && git commit -m "Dev A changes"
git push origin main
cd ..

# Dev B (ohne vorher zu pullen!) pusht auch
cd dev-b
echo "Zeile von Dev B" >> datei.txt
git add . && git commit -m "Dev B changes"
git push origin main
# => FEHLER: rejected! Non-fast-forward!
#    Git sagt: "Es gibt neuere Commits auf dem Remote, die du nicht hast.
#    Zuerst pullen, dann pushen!"
```

**🗣️ Erklären:** Dev B bekommt einen Reject, weil der Remote (central.git) schon einen neueren
Commit hat. Lösung: vor dem Push immer zuerst die aktuellen Änderungen holen.

```bash
cd dev-b

# git pull --rebase → Holt die neuesten Änderungen vom Server
# UND setzt Dev B's Commit obendrauf (rebased statt merge)
# --rebase = "meine Änderungen kommen hinter die geholten"
git pull --rebase origin main
# => Konflikt in datei.txt! Beide haben dieselbe Zeile geändert!

# cat datei.txt → Zeigt die Konflikt-Markierungen
cat datei.txt
# <<<<<<< HEAD     ← MEINE lokalen Änderungen (nach dem Rebase)
# Zeile von Dev A
# =======          ← Trenner
# Zeile von Dev B  ← DEREN Remote-Änderungen
# >>>>>>> Dev B changes

# Konflikt lösen (beide Zeilen behalten — hier ist kein Widerspruch)
cat > datei.txt << 'EOF'
Dev A's Arbeit
Zeile von Dev A
Zeile von Dev B
EOF

# git add → Konflikt als gelöst markieren
git add datei.txt

# git rebase --continue → Rebase fortsetzen
# (Git öffnet einen Editor für die Commit-Nachricht — einfach speichern)
git rebase --continue

# git push → Jetzt klappt es, weil wir die aktuellen Änderungen haben
git push origin main
```

**🗣️ Erklären:** Der Konflikt entsteht, weil beide Entwickler die SELBE Zeile in derselben Datei
geändert haben. Git weiß nicht, welche Version richtig ist — der Mensch muss entscheiden.
Die Konflikt-Markierungen (`<<<<<<<`, `=======`, `>>>>>>>`) zeigen beide Versionen.

---

### 4.2 Feature-Branch-Workflow (35 Min)

### 🖥️ Live-Demo: Feature-Branch + Pull Request

**Ziel:** Zeigen wie Features isoliert entwickelt und via PR gemergt werden.

```bash
cd /tmp/git-schulung && rm -rf feature-workflow && mkdir feature-workflow && cd feature-workflow

# Zentrales Repo + Clone
git init --bare central.git
git clone central.git team-repo
cd team-repo

echo "main" > README.md
git add . && git commit -m "Initial"
git push origin main

# Feature: Dark Mode
# git switch -c → Neuen Branch für das Feature
git switch -c feature/dark-mode
echo "/* Dark Mode Styles */" > dark.css
echo "body { background: #000; }" >> dark.css
git add . && git commit -m "Add dark mode CSS file"

# git push origin feature/dark-mode → Feature-Branch hochladen
# (auf dem Remote entsteht ein neuer Branch)
git push origin feature/dark-mode
# => Jetzt kann ein Pull Request (PR) erstellt werden!

# === Code Review (simuliert) ===
# "LGTM, aber bitte Klasse auf body begrenzen"
echo "body.dark-mode { background: #000; }" > dark.css
git add . && git commit -m "Fix: scope dark-mode to body.dark-mode class"
git push origin feature/dark-mode
# === PR approved ===

# git switch main → Zurück zum Haupt-Branch
git switch main

# git merge --no-ff feature/dark-mode → Merge mit GARANTIERTEM Merge-Commit
# --no-ff = "no fast-forward" → Erzwingt einen Merge-Commit, auch wenn FF möglich wäre
# So sieht man später: "Hier wurde ein Feature-Branch gemergt"
git merge --no-ff feature/dark-mode -m "Merge PR #1: Dark Mode"

# Branch lokal löschen (der Branch ist gemergt, wir brauchen ihn nicht mehr)
git branch -d feature/dark-mode

# Branch AUCH auf dem Remote löschen
# git push origin -d = "delete remote branch"
git push origin -d feature/dark-mode

# git log → Zeigt: Merge-Commit sichtbar in der Historie
git log --oneline --graph --all
```

**🗣️ Erklären:** `--no-ff` = "no fast-forward". Normalerweise macht Git bei linearen Branches
einen Fast-Forward (kein Merge-Commit). Mit `--no-ff` erzwingen wir einen Merge-Commit,
damit die Historie zeigt: "Hier wurde ein Feature fertiggestellt und gemergt".

---

### 4.3 Gitflow-Workflow (35 Min)

### 🖥️ Live-Demo: Gitflow-Komplettdurchlauf

**Ziel:** Den kompletten Gitflow-Zyklus einmal durchspielen.

```bash
cd /tmp/git-schulung && rm -rf gitflow-demo && mkdir gitflow-demo && cd gitflow-demo
git init

# === Phase 1: Initiales Setup ===
echo "v1.0" > version.txt
git add . && git commit -m "Initial project setup"

# git tag <name> → Markiert diesen Commit als Version 1.0.0
# Ein Tag ist wie ein Lesezeichen: "Hier war Release v1.0.0"
git tag v1.0.0

# git switch -c develop → Erstellt den develop-Branch (vom main ausgehend)
# Develop ist der "Arbeits-Branch" — hier landen alle Features zuerst
git switch -c develop

# === Phase 2: Feature-Entwicklung ===
# git switch -c feature/login → Neues Feature von develop ausgehend
git switch -c feature/login
echo "login.py" > login.py
git add . && git commit -m "Add login feature"

# Fertiges Feature zurück nach develop mergen
git switch develop
git merge feature/login -m "Merge feature/login into develop"

# === Phase 3: Release-Vorbereitung ===
# release/1.1.0 von develop — hier wird nur noch stabilisiert!
git switch -c release/1.1.0 develop
echo "v1.1.0" > version.txt  # Version erhöhen
git add . && git commit -m "Bump version to 1.1.0"

# Release in main mergen (mit --no-ff, damit man den Release sieht)
git switch main
git merge --no-ff release/1.1.0 -m "Merge release/1.1.0 into main"
git tag v1.1.0  # Release taggen!

# === Phase 4: Hotfix (dringender Bug in Produktion!) ===
# hotfix/crash-fix VOM main aus (weil es in Produktion akut ist)
git switch -c hotfix/crash-fix main
echo "crash-fix applied" > hotfix.txt
git add . && git commit -m "Fix critical crash in production"

# Hotfix in main mergen
git switch main
git merge --no-ff hotfix/crash-fix -m "Merge hotfix/crash-fix into main"
git tag v1.1.1  # Patch-Version!

# Hotfix AUCH in develop mergen (sonst ist der Bug im nächsten Release wieder drin!)
git switch develop
git merge --no-ff hotfix/crash-fix -m "Merge hotfix/crash-fix into develop"

# git log --decorate → Zeigt Branch-Namen und Tags in der Grafik
git log --oneline --graph --all --decorate
```

**🗣️ Erklären:** Gitflow hat 5 Branch-Typen:
| Branch | Basis | Zweck |
|---|---|---|
| `main` | — | Produktion, immer release-ready |
| `develop` | main | Integration, hier landen alle Features |
| `feature/*` | develop | Ein neues Feature (wird nach develop gemergt) |
| `release/*` | develop | Release-Vorbereitung (wird nach main + develop gemergt) |
| `hotfix/*` | main | Dringender Bugfix (wird nach main + develop gemergt) |

---

### 4.4 Tagging (10 Min)

### 🖥️ Live-Demo: Tags setzen und verwalten

**Ziel:** Zeigen wie man Versionen markiert und wiederfindet.

```bash
cd /tmp/git-schulung/gitflow-demo

# git tag → Listet ALLE Tags auf
git tag

# git tag -l "v1.0*" → Listet Tags die mit "v1.0" beginnen (-l = "list" mit Muster)
git tag -l "v1.0*"

# git tag -a <name> -m "..." → Erstellt einen ANNOTIERTEN Tag
# -a = "annotated". Speichert: Autor, Datum, Nachricht
# (vs. Lightweight-Tags, die nur ein Zeiger sind — wie ein Branch der sich nie bewegt)
git tag -a v2.0.0 -m "Major release: new UI overhaul"

# Tags pushen:
# git push origin --tags → Lädt ALLE Tags hoch, die noch nicht auf dem Remote sind
# Auskommentiert — nur zur Info
# git push origin --tags

# git checkout <tag> → Wechselt zu einem Tag (Read-only!)
git checkout v1.0.0
# => "Detached HEAD"! Man ist nicht auf einem Branch, sondern direkt auf einem Commit.
#    Hier NIE committen — Änderungen gehen sonst verloren!
#    Lösung: git switch -c neuer-branch (wenn man doch was ändern will)
```

**🗣️ Erklären:** Tags sind wie Branches, die sich nie bewegen. **Annotierte Tags** (`-a`)
sind vollwertige Objekte mit Autor + Datum — immer für Releases nehmen.
**Lightweight Tags** sind nur Zeiger — gut für private Markierungen.
Nach `git checkout <tag>` ist man im **Detached HEAD** — man sieht den Stand, kann aber
nicht committen (ohne vorher einen Branch zu erstellen).

---

### 4.5 Trunk-based Development (15 Min)

### 🖥️ Live-Demo: Trunk-based mit Feature Flags

**Ziel:** Zeigen wie man ohne lange Branches auskommt (Feature-Flags + kurze Branches).

```bash
cd /tmp/git-schulung && rm -rf trunk-demo && mkdir trunk-demo && cd trunk-demo
git init

echo "print('App started')" > app.py
git add . && git commit -m "Initial app"

# Feature mit Feature-Flag (statt langem Branch)
# Ein Feature-Flag ist eine Konfigurations-Variable, die Code AN- oder AUSSCHALTET
echo "NEW_FEATURE_ENABLED = False" > config.py
git add . && git commit -m "Add feature flag config"

# Feature-Code ist schon auf main, aber deaktiviert
cat >> app.py << 'EOF'
import config
if config.NEW_FEATURE_ENABLED:
    print("🚀 New feature is LIVE!")
else:
    print("🔄 Old code path")
EOF
git add . && git commit -m "Add new feature behind feature flag (disabled)"

# Aktivieren (nur den Wert von False auf True ändern)
# sed -i → Ersetzt "False" durch "True" in der Datei
sed -i 's/NEW_FEATURE_ENABLED = False/NEW_FEATURE_ENABLED = True/' config.py
git add . && git commit -m "Enable new feature via feature flag"
```

**🗣️ Erklären:** Trunk-based Development = Alle arbeiten auf main (oder einem kurzen Branch
für max. 1-2 Tage). Neue Features werden hinter **Feature-Flags** versteckt (Variablen
die Code an-/ausschalten). Vorteile: kein Code Freeze, keine komplizierten Merges,
immer release-ready. Nachteil: erfordert Disziplin und CI/CD.

---

### 4.6 Workflow-Übung (14:30 – 16:00, 90 Min)

Die TN sollen in Gruppen einen eigenen Workflow entwerfen (Folie 34-35).
Danach: "Workflows in der Praxis" (Folie 46). — Siehe separates Übungs-Set.

---

### 4.7 Best Practices + Commit-Stilkunde (16:00 – 16:30)

### 🖥️ Live-Demo: Gute vs. schlechte Commit-Nachrichten

**Ziel:** Zeigen wie professionelle Commit-Nachrichten aussehen.

```bash
cd /tmp/git-schulung && rm -rf commit-style && mkdir commit-style && cd commit-style
git init

# ❌ SCHLECHT: "fix" / "update" / "changes" sagen GAR NICHTS
echo "fix" > file.txt
git add . && git commit -m "update"

# ✅ GUT: "Add JWT-based authentication"
# Subject: max 50 Zeichen, Imperativ ("Add", nicht "Added" oder "Adding")
# Leerzeile
# Body: WARUM wurde die Änderung gemacht (nicht WAS — das sieht man im Diff)
# Footer: Issue-ID für Ticket-System
echo "function authenticate(user, password) { ... }" > auth.py
git add . && git commit -m "Add JWT-based authentication

The new authentication system uses JWT tokens to improve security
and reduce database load on every request.

Related to #F1337"

# git add -p → Interaktives Staging: Zeigt Änderungen Häppchen für Häppchen
# Man kann mit y/n/s einzeln auswählen, was man committen will
# Perfekt um z.B. Debug-Logs vom eigentlichen Code zu trennen
echo "console.log('debug')" >> auth.py
git add -p
# => Drücke 'y' um die Zeile zu stagen, 'n' um sie auszulassen
git commit -m "Remove debug logging"
```

**🗣️ Erklären:**
- **Subject (Betreff):** max. 50 Zeichen, Imperativ ("Add", "Fix", "Remove")
- **Body (Text):** WARUM, nicht WAS (das WAS sieht man im Diff)
- **Footer:** Issue-ID oder Breaking-Change-Hinweis
- `git add -p` = "patch mode" — zeigt jede einzelne Änderung und fragt:
  mit `y` (ja), `n` (nein), `s` (splitten) — so macht man atomare Commits

---

# Tag 2 — Fortgeschrittene Techniken & Praxis

## 1. Wiederholung Tag 1 (08:30 – 08:45, 15 Min)

Kurze Runde: Jeder TN nennt ein Learning von Tag 1. Trainer fasst zusammen.

---

## 2. Fortgeschrittenes Mergen (08:45 – 10:15, 90 Min)

### 2.1 Merge-Strategien

### 🖥️ Live-Demo: Merge-Strategien im Vergleich

**Ziel:** Die verschiedenen Merge-Strategien (`-s` Flag) zeigen.

```bash
cd /tmp/git-schulung && rm -rf merge-strategies && mkdir merge-strategies && cd merge-strategies
git init

echo "start" > file.txt
git add . && git commit -m "Initial"

# Zwei parallele Feature-Branches
git switch -c feature-1
echo "feature-1 change" >> file.txt
git add . && git commit -m "Feature 1 commit"

git switch main
git switch -c feature-2
echo "feature-2 change" >> file.txt
git add . && git commit -m "Feature 2 commit"

# STRATEGIE 1: Recursive (DEFAULT)
# git merge -s recursive → Standard, arbeitet mit 2 Heads
# Automatischer 3-Way Merge, erzeugt Merge-Commit bei Divergenz
git switch main
git merge --no-edit feature-1
git log --oneline --graph --all
echo "---"

# STRATEGIE 2: Ours
# git merge -s ours → "Unser Code gewinnt, egal was der andere hat"
# Der andere Branch wird mit dem Merge-Commit verknüpft, aber SEIN Code ignoriert
# Nützlich: wenn man einen Branch "historisch verknüpfen" will ohne den Code
git checkout -B test-ours main
git merge -s ours feature-2 --no-edit
cat file.txt  # => Enthält NUR feature-1 change, feature-2 wird ignoriert!
```

**🗣️ Erklären:** `git merge -s <strategie>`:
- `recursive` = Standard. Automatischer Merge, Konflikte bei divergierenden Änderungen
- `ours` = Unser Code gewinnt immer. Der andere Branch wird "eingebucht" aber sein Code verworfen
- `octopus` = Für mehr als 2 Branches gleichzeitig
- `subtree` = Für integration externer Projekte mit eigener History

---

### 2.2 Merge-Konflikte & Lösungsstrategien

### 🖥️ Live-Demo: Konflikt provozieren und lösen

**Ziel:** Einen echten Konflikt erzeugen und alle Lösungswege zeigen.

```bash
cd /tmp/git-schulung && rm -rf conflict-demo && mkdir conflict-demo && cd conflict-demo
git init

echo "color = blue" > config.txt
git add . && git commit -m "Initial config"

# Feature-Branch: Rot
git switch -c feature/change-color
echo "color = red" > config.txt
git add . && git commit -m "Change color to red"

# Main: Grün (parallel!)
git switch main
echo "color = green" > config.txt
git add . && git commit -m "Change color to green"

# Merge => KONFLIKT! Beide haben dieselbe Zeile geändert
git merge feature/change-color

# Konflikt anzeigen
cat config.txt
# <<<<<<< HEAD          ← MEIN Branch (main, "green")
# color = green
# =======               ← Trennung
# color = red           ← DEREN Branch (feature/change-color)
# >>>>>>> feature/change-color

# LÖSUNG 1: Automatisch "unsere" Seite nehmen (-Xours)
# git merge --abort → Bricht den Merge ab (alles zurück)
git merge --abort

# git merge -Xours → "Beim Konflikt nimm automatisch UNSERE Version"
# -X = "extended option" (merge-Strategie-Tuning, nicht -s)
git merge -Xours feature/change-color --no-edit
cat config.txt  # => "color = green"

# LÖSUNG 2: Manuell lösen (der sauberste Weg)
git reset --hard HEAD~1  # Gehe einen Commit zurück (Merge rückgängig)
git merge --no-edit feature/change-color || true

# Manuell: Neue Farbe "purple" — der Kompromiss
cat > config.txt << 'EOF'
color = purple
EOF

# git add → Konflikt als gelöst markieren
git add config.txt

# git commit → Merge-Commit abschließen (kein --no-edit nötig, Nachricht steht schon)
git commit --no-edit
```

**🗣️ Erklären:** Drei Wege einen Konflikt zu lösen:
1. `-Xours` = Automatisch UNSERE Version nehmen (schnell, aber manchmal falsch)
2. `-Xtheirs` = Automatisch DEREN Version nehmen
3. **Manuell** = Datei editieren, beide Versionen zusammenführen, `git add + git commit`
   (Das ist der richtige Weg! Nur ein Mensch weiß, was fachlich richtig ist.)

---

### 🖥️ Live-Demo: diff3 für bessere Konflikt-Übersicht

**Ziel:** Mit diff3 sieht man den gemeinsamen Vorfahren — das macht Konflikte leichter lösbar.

```bash
cd /tmp/git-schulung && rm -rf diff3-demo && mkdir diff3-demo && cd diff3-demo
git init

echo "background = white" > theme.txt
echo "font = sans-serif" >> theme.txt
echo "size = 14px" >> theme.txt
git add . && git commit -m "Initial theme"

# Feature: Dark (black)
git switch -c feature/dark
# sed -i = Ersetze "white" durch "black" in der Datei
sed -i 's/background = white/background = black/' theme.txt
git add . && git commit -m "Dark mode"

# Main: Sepia (sepia)
git switch main
sed -i 's/background = white/background = sepia/' theme.txt
git add . && git commit -m "Sepia mode"

# Merge => Konflikt (beide haben "white" geändert)
git merge feature/dark || true

# git checkout --conflict=diff3 → Zeigt den Konflikt MIT dem gemeinsamen Vorfahren
# Normal: <<<< HEAD | ==== | >>>> other
# Mit diff3: <<<< HEAD | |||| ANCESTOR | ==== | >>>> other
# Ancestor = der Stand VOR beiden Änderungen — das ist die "dritte Version" (= diff3)
git checkout --conflict=diff3 theme.txt
cat theme.txt
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# background = sepia          ← MAIN (HEAD)
# ||||||||||||||||||||||||||||||||||||||||||||||||
# background = white          ← GEMEINSAMER VORFAHR! (vor beiden Änderungen)
# ================================================
# background = black           ← FEATURE (theirs)
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> feature/dark
```

**🗣️ Erklären:** Der gemeinsame Vorfahre (`||||||`) zeigt WAS ursprünglich da stand —
also was beide Versionen geändert haben. Das macht die Entscheidung viel einfacher!
Man kann `git config --global merge.conflictstyle diff3` setzen, damit das immer
so angezeigt wird.

---

### 2.3 git rerere — Automatische Konfliktlösung

### 🖥️ Live-Demo: rerere einrichten & testen

**Ziel:** Zeigen wie Git sich Konflikt-Lösungen merken kann.

```bash
cd /tmp/git-schulung && rm -rf rerere-demo && mkdir rerere-demo && cd rerere-demo
git init

# rerere aktivieren (einmalig pro Repo oder global)
# git config = Einstellung setzen (lokal = nur dieses Repo, --global = für alle Repos)
# rerere.enabled true = "reuse recorded resolution" — Konfliktlösungen wiederverwenden
git config rerere.enabled true

echo "value = original" > data.txt
git add . && git commit -m "Initial"

git switch -c branch-a
echo "value = a-change" > data.txt
git add . && git commit -m "Branch A changes"

git switch main
git switch -c branch-b
echo "value = b-change" > data.txt
git add . && git commit -m "Branch B changes"

# Erster Merge-Versuch => Konflikt
git switch main
git merge branch-a --no-edit || true
git merge branch-b --no-edit || true

# Manuell lösen
echo "value = resolved" > data.txt
git add data.txt
git merge --continue --no-edit

# git rerere status → Zeigt: rerere hat die Lösung gespeichert!
git rerere status

# Jetzt: Reset (2 Schritte zurück = beide Merges rückgängig)
git reset --hard HEAD~2

# Konflikt wiederholen — OHNE manuelles Lösen!
git merge branch-a --no-edit || true
git merge branch-b --no-edit || true

# cat → rerere hat automatisch "resolved" angewendet!
cat data.txt  # => value = resolved
```

**🗣️ Erklären:** **rerere** = "reuse recorded resolution". Git speichert Konflikt-Lösungen
im Ordner `.git/rr-cache`. Wenn der GLEICHE Konflikt wieder auftritt, wird die gespeicherte
Lösung automatisch angewendet. Gold wert bei:
- Langen Rebase-Sessions (gleicher Konflikt bei jedem Rebase-Schritt)
- CI/CD mit wiederholten Merges
- Cherry-Pick-Serien

---

## 3. Git Hooks (10:15 – 10:45)

### 🖥️ Live-Demo: commit-msg Hook — Commit-Nachricht validieren

**Ziel:** Einen Hook bauen, der schlechte Commit-Nachrichten ablehnt.

```bash
cd /tmp/git-schulung && rm -rf hooks-demo && mkdir hooks-demo && cd hooks-demo
git init

# .git/hooks/ → Hier liegen die Hooks (versteckter Ordner)
# Ein Hook ist ein SKRIPT, das Git automatisch bei bestimmten Aktionen ausführt
# Der Dateiname bestimmt, WANN der Hook läuft (commit-msg = vor dem Commit-Speichern)

# cat > datei → Schreibt das Hook-Skript
cat > .git/hooks/commit-msg << 'HOOK'
#!/bin/bash
# $1 = Erster Parameter = die Commit-Nachrichten-Datei
COMMIT_MSG_FILE="$1"
MESSAGE=$(cat "$COMMIT_MSG_FILE")
KEYWORD='(FEAT|FIX|DOCS|STYLE|REFACTOR|TEST): '

# grep -qE = Sucht nach dem Muster, -q = leise (nur Exit-Code), -E = Regex
# if ! = wenn das Muster NICHT gefunden wurde...
if ! echo "$MESSAGE" | grep -qE "$KEYWORD"; then
    echo "-------"
    echo "$MESSAGE"
    echo "-------"
    echo "Abgelehnt: Commit-Nachricht muss mit einem gültigen Keyword beginnen!"
    echo "Erlaubt: FEAT, FIX, DOCS, STYLE, REFACTOR, TEST"
    exit 1  # Exit-Code 1 = Fehler → Git bricht den Commit ab!
fi
HOOK

# chmod +x → Macht die Datei AUSFÜHRBAR (nötig für jeden Hook!)
chmod +x .git/hooks/commit-msg

# TEST: Schlechte Commit-Nachricht → sollte abgelehnt werden
echo "test" > test.txt
git add test.txt
git commit -m "update"
# => Hook lehnt ab: "Abgelehnt: Commit-Nachricht muss mit einem gültigen Keyword beginnen!"

# TEST: Gute Commit-Nachricht → sollte durchgehen
git commit -m "FIX: update test file"
# => Hook akzeptiert
```

**🗣️ Erklären:** Hooks sind Skripte in `.git/hooks/`. Der Dateiname bestimmt den Zeitpunkt:
- `pre-commit` = VOR dem Commit (Code-Checks, Linter)
- `commit-msg` = NACH Eingabe der Nachricht (Validierung)
- `post-commit` = NACH erfolgreichem Commit (Benachrichtigung)
- `pre-push` = VOR dem Push (Tests, keine Debug-Logs)
- `post-merge` = NACH einem Merge

Ein Hook muss:
1. Ausführbar sein (`chmod +x`)
2. Exit-Code 0 = Erfolg, Exit-Code 1 = Abbruch

Hooks werden NICHT automatisch geteilt — sie liegen nur lokal!

---

### 🖥️ Live-Demo: post-commit Hook — Commit-Log schreiben

**Ziel:** Einen Hook der automatisch Daten sammelt.

```bash
cd /tmp/git-schulung/hooks-demo

cat > .git/hooks/post-commit << 'HOOK'
#!/bin/bash
# $(git rev-parse --show-toplevel) = Gibt den Repo-Root-Ordner aus
# (funktioniert von überall im Repo)
LOG_FILE="$(git rev-parse --show-toplevel)/commit-history.txt"

# >> → Hängt an die Datei an (statt zu überschreiben)
echo "=== Commit $(date) ===" >> "$LOG_FILE"
echo "Hash:   $(git rev-parse HEAD)" >> "$LOG_FILE"

# git log -1 = Letzten Commit anzeigen
# --format='%an <%ae>' = Autor-Name und Email
echo "Author: $(git log -1 --format='%an <%ae>')" >> "$LOG_FILE"
echo "Date:   $(git log -1 --format='%ad')" >> "$LOG_FILE"
echo "Nachricht:" >> "$LOG_FILE"

# %B = Gesamte Commit-Nachricht (Body + Footer)
git log -1 --format='%B' >> "$LOG_FILE"
echo "" >> "$LOG_FILE"
echo "Gespeichert in: $LOG_FILE"
HOOK
chmod +x .git/hooks/post-commit

# Testen
echo "Hook test" > test2.txt
git add test2.txt
git commit -m "FEAT: test post-commit hook"

# cat → Zeigt die automatisch geschriebene Log-Datei
cat commit-history.txt
```

---

### 🖥️ Live-Demo: pre-push Hook — keine Debug-Logs pushen

```bash
cat > .git/hooks/pre-push << 'HOOK'
#!/bin/bash
echo "🔍 Checke auf Debug-Logs..."

# git diff --cached = Zeigt was im Staging-Bereich ist (kommt in den nächsten Push)
# grep -q = Sucht nach konsolen.log, debugger, oder print(
if git diff --cached | grep -q "console\.log\|debugger\|print("; then
    echo "❌ Debug-Anweisungen gefunden! Push abgelehnt."
    exit 1
fi
echo "✅ Alles sauber, push erlaubt."
HOOK
chmod +x .git/hooks/pre-push
```

**🗣️ Erklären:** Hooks werden nicht automatisch geteilt, weil sie in `.git/hooks/` liegen
(das `.git/`-Verzeichnis wird nicht versioniert). **Team-Lösung:**
1. Hooks im Repo unter `scripts/hooks/` versionieren
2. Mit `git config --global init.templatedir` automatisch verteilen
3. Oder via `husky` (npm), `pre-commit` (Python) — Tools die Hooks teamweit verwalten

---

## 4. Git Aliase (10:45 – 11:00)

### 🖥️ Live-Demo: Aliase einrichten

**Ziel:** Zeigen wie man sich das Leben mit Kurzbefehlen erleichtert.

```bash
cd /tmp/git-schulung && rm -rf alias-demo && mkdir alias-demo && cd alias-demo
git init

# git config --global → EINSTELLUNG global setzen (für ALLE Repos, in ~/.gitconfig)
# alias.co = "co" als Alias für "checkout"
# Jetzt: git co statt git checkout
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.st status
git config --global alias.ci commit

# Alias mit Parametern (kein ! — reiner Git-Befehl)
# fancy-log = ein kompletter Git-Befehl als Alias
git config --global alias.fancy-log "log --oneline --graph --decorate --all"

# Alias für letzten Commit
git config --global alias.last "log -1 HEAD"

# Branch-Löschen (schneller)
git config --global alias.del "branch -D"

# SHELL-ALIAS mit ! (Ausrufezeichen = Shell-Befehl, nicht Git-Befehl)
# Entfernt alle lokal gemergten Branches
git config --global alias.cleanup "! git branch --merged | grep -v \\* | xargs -n 1 git branch -d"

# SHELL-ALIAS: Alles adden + committen in einem Befehl
# ! = Git führt das als Shell-Script aus
git config --global alias.ac "! git add -A && git commit -m"

# Meta-Alias: Alle Aliase auflisten
git config --global alias.alias "! git config --get-regexp ^alias\\. | sed -e s/^alias\\.// -e s/\\ /\\ =\\ /"

# Demo
git config --global alias.alias  # Zeigt alle Aliase

echo "Hello" > readme.md
git add readme.md
git ac "FEAT: initial commit"   # = git add -A && git commit -m "..."
git fancy-log                    # = log --oneline --graph --decorate --all
```

**🗣️ Erklären:** Zwei Arten von Aliassen:
1. **Einfach** (kein `!`): `git config --global alias.co checkout` → `git co`
   Git-interne Befehle, Parameter werden automatisch angehängt
2. **Shell-Alias** (mit `!`): `git config --global alias.ac "! git add -A && git commit -m"`
   Beliebiges Shell-Script — kann mehrere Befehle, Pipes, Schleifen
   Achtung: Shell-Aliase sind mächtig, aber auch gefährlich!

Aliase liegen in `~/.gitconfig` unter `[alias]`.

---

## 5. CI/CD (11:00 – 12:00)

### 🖥️ Live-Demo: .gitlab-ci.yml erstellen

**Ziel:** Eine einfache GitLab-Pipeline mit Stages erstellen und verstehen.

```bash
cd /tmp/git-schulung && rm -rf cicd-demo && mkdir cicd-demo && cd cicd-demo
git init

# .gitlab-ci.yml = GitLab-Konfigurationsdatei (muss im ROOT des Repos liegen)
# GitLab liest diese Datei bei jedem Push und führt die Pipeline aus
cat > .gitlab-ci.yml << 'YAML'
# stages = Die REIHENFOLGE der Pipeline-Schritte
# Jeder Stage läuft NACH dem vorherigen (bei Fehler: Abbruch)
stages:
  - initialize
  - info
  - finish

# before_script → Läuft VOR JEDEM Job (z.B. Abhängigkeiten installieren)
before_script:
  - echo "Pipeline gestartet für $CI_PROJECT_NAME"
  - echo "Branch: $CI_COMMIT_BRANCH"

# Ein Job = "initialize" im Stage "initialize"
initialize:
  stage: initialize
  script:     # Was der Job ausführt
    - echo "=== INITIALIZE ==="
    - echo "Projekt: $CI_PROJECT_NAME"
    - echo "Branch: $CI_COMMIT_BRANCH"
    - echo "Pipeline-ID: $CI_PIPELINE_ID"

info:
  stage: info
  script:
    - echo "=== INFO ==="
    - echo "Commit: $CI_COMMIT_SHORT_SHA"
    - echo "Autor: $GITLAB_USER_NAME"
    - echo "Nachricht: $CI_COMMIT_MESSAGE"

finish:
  stage: finish
  script:
    - echo "=== FINISH ==="
    - echo "✅ Pipeline erfolgreich abgeschlossen!"
YAML

git add .gitlab-ci.yml
git commit -m "FEAT: add GitLab CI/CD pipeline with info stages"

# Echtes Beispiel mit Build + Test + Deploy
cat > .gitlab-ci-full.yml << 'YAML'
stages:
  - build     # 1. Kompilieren/Bauen
  - test      # 2. Tests ausführen
  - deploy    # 3. Nur bei Erfolg ausliefern

variables:    # Globale Variablen für alle Jobs
  APP_NAME: galactic-pizza
  DOCKER_IMAGE: registry.example.com/$APP_NAME

build-job:
  stage: build
  script:
    - echo "Building $APP_NAME..."
    - mkdir -p dist/
    - echo "Build output" > dist/app.bundle.js
  artifacts:  # Gibt Dateien zwischen Jobs weiter
    paths:
      - dist/

test-job:
  stage: test
  script:
    - echo "Running unit tests..."
    - echo "✓ All 42 tests passed"
    - echo "Running linting..."
    - echo "✓ No linting errors"

deploy-job:
  stage: deploy
  script:
    - echo "Deploying $APP_NAME to production..."
    - echo "Deployed successfully"
  only:       # Nur ausführen wenn...
    - main    # ...der Branch "main" ist
YAML
```

**🗣️ Erklären:** Jeder Job läuft in einer eigenen isolierten Umgebung (Container).
`artifacts` = Datenweitergabe zwischen Jobs (z.B. Build-Ergebnis → Test → Deploy).
`only: main` = Dieser Job läuft nur bei Commits auf main (nicht auf Feature-Branches).

---

## 6. Praxisprobleme (13:00 – 16:00)

### 6.1 cherry-pick

### 🖥️ Live-Demo: Einzelnen Commit übernehmen

**Ziel:** Zeigen wie man NUR einen bestimmten Commit in einen anderen Branch kopiert.

```bash
cd /tmp/git-schulung && rm -rf cherry-demo && mkdir cherry-demo && cd cherry-demo
git init

echo "v1" > app.py
git add . && git commit -m "Initial commit"

# Feature-Branch mit 3 Commits
git switch -c feature/awesome
echo "Haupt-Feature" > main_feature.py
git add . && git commit -m "FEAT: main awesome feature"
echo "Kleiner Bugfix" > bugfix.py
git add . && git commit -m "FIX: critical bug in login"
echo "Weiteres Feature" > extra.py
git add . && git commit -m "FEAT: extra fancy feature"

git switch main

# git cherry-pick <hash> → Kopiert NUR den Bugfix-Commit nach main
# (ohne die anderen beiden Feature-Commits mitzunehmen)
# <commit-hash-von-bugfix> = den Hash des bugfix-Commits nehmen (siehe git log)
git cherry-pick <commit-hash-von-bugfix>
# => Nur bugfix.py ist jetzt auf main! Der Rest von feature/awesome nicht.
```

**🗣️ Erklären:** `git cherry-pick` = "Kirschen pflücken". Nimmt einen EINZELNEN Commit
und wendet ihn im aktuellen Branch an. Der Original-Commit bleibt wo er war.
**Wann?**
- Einen Bugfix in den Release-Branch holen (aber nicht das halbfertige Feature)
- Einen dringenden Security-Fix aus develop in main übernehmen
- Einen Commit in einen älteren Release-Branch portieren (Backport)

---

### 6.2 Git Bisect

### 🖥️ Live-Demo: Bug-Suche mit git bisect

**Ziel:** Zeigen wie man in 10 Schritten den Schuldigen unter 1000 Commits findet.

```bash
cd /tmp/git-schulung && rm -rf bisect-demo && mkdir bisect-demo && cd bisect-demo
git init

# 10 Commits erzeugen — einer davon (Nr. 7) enthält einen Bug
for i in $(seq 1 10); do
    if [ "$i" -eq 7 ]; then
        # for-Schleife: i=1 bis 10; bei i=7 = Bug eingefügt
        echo "version $i" > app.py
        echo "result = 'BUGGY'" >> app.py  # Zeile mit dem Bug
    else
        echo "version $i" > app.py
        echo "result = 0" >> app.py
    fi
    git add . && git commit -m "FEAT: version $i"
done

# Test-Skript: Prüft ob der Bug da ist
# exit 0 = Bug NICHT da (GUT)
# exit 1 = Bug da (SCHLECHT)
cat > test.sh << 'SCRIPT'
#!/bin/bash
if grep -q "BUGGY" app.py; then
    exit 1  # schlecht (Bug gefunden)
fi
exit 0     # gut (kein Bug)
SCRIPT
chmod +x test.sh

# git bisect start → Startet die binäre Suche
git bisect start

# git bisect bad <commit> → "Dieser Commit ist SCHLECHT (Bug ist da)"
git bisect bad HEAD  # HEAD = aktuellster Commit = Version 10 = Bug!

# git bisect good <commit> → "Dieser Commit war noch GUT (kein Bug)"
git bisect good HEAD~10  # Version 1 = noch kein Bug

# git bisect run <script> → Automatisch testen (ohne manuelles Prüfen!)
# Git checkt einen Commit nach dem anderen aus und testet
# Findet in ~log₂(10) ≈ 4 Schritten den Bug-Commit!
git bisect run ./test.sh
# => Output: "first bad commit: <hash> FEAT: version 7"

# git bisect reset → Beendet die Suche und geht zurück zum ursprünglichen Stand
git bisect reset
```

**🗣️ Erklären:** `git bisect` = **Binäre Suche** durch die Commit-Historie.
Bei 1000 Commits braucht man nur ~10 Schritte (`log₂(1000) ≈ 10`).
**Manuell:** `git bisect good` / `git bisect bad` nach jedem Test.
**Automatisch:** `git bisect run ./test.sh` — das Script muss 0 (gut) oder 1 (schlecht) zurückgeben.
Perfekt für: "Letzte Woche lief's noch, jetzt nicht — welcher Commit hats kaputt gemacht?"

---

### 6.3 Submodules

### 🥾 Live-Demo: Externes Projekt einbinden

**Ziel:** Zeigen wie man eine externe Bibliothek als Submodul einbindet.

```bash
cd /tmp/git-schulung && rm -rf submodule-demo && mkdir submodule-demo && cd submodule-demo

# Zwei separate Repos: eine Library + eine App
# git init --bare → Reine Server-Repos (wie auf GitHub)
git init --bare lib.git
git init --bare app.git

# Library befüllen
git clone lib.git lib
cd lib
echo "def helper(): pass" > helpers.py
git add . && git commit -m "Initial library"
git push origin main  # Library auf den "Server" pushen
cd ..

# App mit Submodul (Bibliothek als Unterordner einbinden)
git clone app.git app
cd app

# git submodule add <repo-url> <pfad> → Bindet das lib-Repo als Submodul ein
# Das Submodul ist ein "Repo im Repo" — zeigt auf einen bestimmten Commit der Library
git submodule add ../lib.git lib/helpers
# => Erzeugt: .gitmodules (Konfiguration) + lib/helpers (zeigt auf library)

git commit -m "FEAT: add helpers as submodule"
git push origin main
cd ..

# PROBLEM: Jemand klont die App neu
git clone app.git app-clone
cd app-clone

# ls → lib/helpers existiert, ist aber LEER!
# (Git hat nur den Ordner erstellt, aber den Inhalt nicht geholt)
ls lib/helpers/

# git submodule init → Aktiviert die Submodule (liest .gitmodules)
git submodule init

# git submodule update → Holt den Inhalt der Submodule
# Lädt den commitierten Stand aus dem verlinkten Repo
git submodule update
ls lib/helpers/  # => helpers.py ist jetzt da!
```

**Besser:** Beim Klonen gleich alle Submodule mitnehmen:
```bash
git clone --recurse-submodules <url>
# --recurse-submodules = Klon + submodule init + submodule update in einem
```

**🗣️ Erklären:** Submodule = "Repo im Repo". Die App zeigt auf einen BESTIMMTEN Commit
der Library (nicht auf "latest"). So bleibt der Build reproduzierbar.
- `.gitmodules` = Konfiguration (welches Repo, wohin)
- Die App "merkt" sich, welcher Library-Commit gerade passt
- `git submodule update` = holt den richtigen Stand
- **Wichtig:** Wenn jemand die Library updated, muss auch die App den neuen Commit zeigen!

---

### 6.4 subtree — Projekt aufteilen

### 🖥️ Live-Demo: Teilbaum extrahieren

**Ziel:** Zeigen wie man einen Ordner aus einem Monorepo in ein eigenes Repo auskoppelt.

```bash
cd /tmp/git-schulung && rm -rf subtree-demo && mkdir subtree-demo && cd subtree-demo
git init

# Ein großes Projekt (Monorepo) mit mehreren Ordnern
mkdir -p src/shared utils docs
echo "shared code" > src/shared/core.py
echo "utils" > utils/helpers.py
echo "docs" > docs/guide.md
echo "main app" > main.py
git add . && git commit -m "Initial monorepo"

# git subtree split → Extrahiert NUR den Ordner src/shared in einen neuen Branch
# --prefix=src/shared = Welcher Ordner?
# -b extract-shared = Neuer Branch-Name für die extrahierten Commits
# Das Ergebnis: Der Branch extract-shared enthält NUR die Datei src/shared/core.py
# (mit vollständiger Commit-Historie!)
git subtree split --prefix=src/shared -b extract-shared

git switch extract-shared
ls  # => NUR core.py, ohne den Rest!
# Jetzt könnte man: git remote add origin <neues-repo>
#                  git push origin extract-shared:main
# → Das neue Repo hat dann die Dateien AUS src/shared + deren Historie
```

**🗣️ Erklären:** `git subtree split` = Extrahiert einen Teilbaum MIT voller Historie.
Anders als Submodule: der extrahierte Code ist eigenständig.
Alternativ: `git filter-repo` (mächtiger, aber muss installiert werden).

---

### 6.5 Repository Recovery — revert / reset

### 🖥️ Live-Demo: reset vs. revert

**Ziel:** Den Unterschied zwischen "History umschreiben" und "History erhalten" zeigen.

```bash
cd /tmp/git-schulung && rm -rf recovery-demo && mkdir recovery-demo && cd recovery-demo
git init

echo "v1" > datei.txt
git add . && git commit -m "v1"
echo "v2" >> datei.txt
git add . && git commit -m "v2"
echo "v3 BUG" >> datei.txt
git add . && git commit -m "v3 with bug"
echo "v4" >> datei.txt
git add . && git commit -m "v4"

# VARIANTE 1: git revert (SICHER — auch wenn bereits gepusht!)
# git revert HEAD~1 → Macht den vorletzten Commit rückgängig
# (erzeugt einen NEUEN Commit, der die Änderungen des ursprünglichen rückgängig macht)
# Die History bleibt erhalten — ideal für gemeinsam genutzte Branches!
git revert HEAD~1 --no-edit
cat datei.txt  # v3 "BUG" ist weg, v4 bleibt!

# VARIANTE 2: git reset (GEFÄHRLICH bei gepushten Branches)
# git reset --hard → Setzt den Branch auf einen früheren Stand ZURÜCK
# --hard = Arbeitsverzeichnis + Staging + History = alles weg!
# Die Commits sind lokal gelöscht — wenn schon gepusht, sind andere inkonsistent!
git reset --hard HEAD~2
cat datei.txt  # NUR v1, v2 — v3 und v4 wurden gelöscht!
```

**🗣️ Erklären — Entscheidungsmatrix:**

| Situation | Befehl | Wirkung |
|---|---|---|
| **Nicht gepusht** | `git reset --hard HEAD~1` | Commit lokal entfernen ✅ |
| **Bereits gepusht** | `git revert HEAD~1` | Neuer Commit, History bleibt ✅ |
| Nur im Staging | `git restore --staged file` | Aus der grünen Zone nehmen |
| Ungestagte Änderungen | `git restore file` | Änderungen verwerfen |
| Falscher Branch committed | `git reset HEAD~1 && git stash && git switch richtig && git stash pop` | |

**Merke:** Wenn andere den Branch haben → `revert`. Nur wenn du der Einzige bist → `reset`.

---

### 6.6 replace — Commit-Historie umschreiben (fortgeschritten)

### 🖥️ Live-Demo: git replace

**Ziel:** Zeigen wie man einen Commit durch einen anderen ersetzt (lokal).

```bash
cd /tmp/git-schulung && rm -rf replace-demo && mkdir replace-demo && cd replace-demo
git init

echo "public API key = abc123" > config.php
git add . && git commit -m "FEAT: initial config (with secret!)"

echo "real code" > app.php
git add . && git commit -m "FEAT: real app code"

# OH SHIT! API-Key committed!
# Lösung: Einen NEUEN Commit machen, der den API-Key entfernt
# und diesen Commit DANN den originalen ERSETZEN lassen

# Zuerst: geheimen API-Key entfernen
# git switch -c fix-secret HEAD~1 → Erstelle Branch auf dem vorletzten Commit
# (ein Commit VOR dem problematischen — da wo "config.php" erstellt wurde)
git switch -c fix-secret HEAD~1

# Jetzt die Datei ohne API-Key
echo "public API key = [REMOVED]" > config.php
git add . && git commit -m "FIX: remove hardcoded API key"

# git replace <original> <ersatz> → Sag Git: "Sieh diesen Commit stattdessen"
# Git ersetzt den originalen Commit (mit API-Key) durch den neuen (ohne API-Key)
# IN DER ANZEIGE! Die eigentlichen Commits bleiben unverändert.
git replace HEAD~1 <hash-des-neuen-fix-commits>

# Jetzt → Sieht aus als wäre API-Key nie committed worden!
git log --oneline --graph --all
```

**⚠️ Achtung:** `git replace` ist **lokal**. Andere Entwickler sehen den Replace nicht
(wenn sie nicht `git fetch --recurse-submodules origin "refs/replace/*:refs/replace/*"` machen).
Für **permanente** History-Umschreibung: `git filter-repo` (entfernt den API-Key wirklich).

**Besserer Workflow für versehentlich gepushte Secrets:**
1. `git filter-repo` (löscht die Datei aus der gesamten History)
2. **UND SOFORT** den API-Key auf dem Server rotieren (neuen Key erzeugen)!

---

## 7. Tagesabschluss (16:00 – 16:30)

- Jeder TN: 3 Key-Takeaways
- Feedback-Runde

---

# Anhang: Cheat Sheet für Trainer

## Befehlsreferenz — Kurz erklärt

```
git init         → Macht aus einem Ordner ein Git-Repository
git clone <url>  → Kopiert ein komplettes Repo (wie "Fork" + "Download")
git add <datei>  → Nimmt eine Datei in die "grüne Zone" (Staging)
git commit -m "" → Macht einen festen Snapshot aller gestagten Dateien
git status       → Zeigt: was ist neu? was ist geändert? was ist in der grünen Zone?
git diff         → Zeigt UNGESTAGTE Änderungen (was ist anders?)
git log          → Zeigt die Commit-Historie
git log --oneline --graph → Historie als Baum-Grafik
git branch       → Listet Branches auf
git switch <b>   → Wechselt zu einem Branch
git switch -c <b>→ Erstellt einen neuen Branch UND wechselt dahin
git merge <b>    → Fügt einen Branch in den aktuellen ein
git rebase <b>   → Setzt Commits neu auf einen anderen Branch auf
git stash        → Legt Änderungen kurz weg (für Kontextwechsel)
git stash pop    → Holt die wegelegten Änderungen zurück
git tag <name>   → Markiert einen Commit als Version/Release
git cherry-pick <hash> → Kopiert NUR diesen einen Commit hierher
git bisect       → Findet per binärer Suche den Commit der den Bug eingebaut hat
git revert <hash>→ Macht einen Commit rückgängig (mit neuem Commit)
git reset        → Setzt den Branch zurück (lokal! Gefährlich wenn gepusht!)
git submodule add → Bindet ein externes Repo als Unterordner ein
git subtree split → Extrahiert einen Ordner als eigenes Repo (mit Historie)
```

## Schnelle Repos für Demos erstellen

```bash
# Bash-Funktion für den Trainer: Legt sofort ein frisches Repo an
quick_repo() {
    local dir="${1:-demo}"
    rm -rf "$dir" && mkdir "$dir" && cd "$dir"
    git init
    echo "# Demo" > README.md
    git add . && git commit -m "Initial commit"
}
```

## Demo-Konflikte reproduzierbar machen

Immer mit `rm -rf` + frischem `git init` arbeiten, nie auf einem bestehenden Repo!
So hat jeder TN den gleichen Startpunkt.

## Timeline-Übersicht

| Zeit | Tag 1 | Tag 2 |
|------|-------|-------|
| 08:30 | Vorstellung | Recap Tag 1 |
| 09:00 | Git Recap | Fortgeschr. Mergen |
| 09:15 | Branches | (Fortsetzung) |
| 10:15 | — | Pause |
| 10:30 | — | Git Hooks |
| 10:45 | Merge vs. Rebase | Git Aliase |
| 11:15 | Workflows | CI/CD |
| 12:00 | Mittag | Mittag |
| 13:00 | Workflows (Fortsetzung) | Praxisprobleme |
| 14:00 | Workflows Praxis | Praxis (Fortsetzung) |
| 14:30 | Workflows Praxis | Praxis (Fortsetzung) |
| 15:30 | Best Practices | Praxis (Fortsetzung) |
| 16:00 | Zusammenfassung | Zusammenfassung |
| 16:30 | Ende | Ende |

---

*Viel Erfolg bei der Schulung! 🚀*


---

## 📦 Beispiel-Projekte zum Durchspielen

Jedes Projekt enthält mehrere Branches/Szenarien — einfach entpacken und loslegen:

| Projekt | Beschreibung | Szenarien |
|---------|-------------|-----------|
| **merge-strategies-beispiel.tar.gz** | 🌌 Starport 42 | FF-Merge, 3-Way, Konflikt, Rebase, Cherry-Pick |
| **reset-recovery-beispiel.tar.gz** | 🔄 Taschenrechner | reset --soft/mixed/hard, revert, reflog, restore |
| **rebase-interactive-beispiel.tar.gz** | ✏️ Reiseblog | squash, fixup, reword, reorder, drop, edit, autosquash |
| **hooks-automation-beispiel.tar.gz** | 🔗 Python-App | pre-commit, commit-msg, pre-push, post-commit, post-merge |

Jedes `.tar.gz` enthält ein fertiges Git-Repo. Einfach:
```bash
tar xzf beispiel.tar.gz
cd beispiel
git log --oneline --graph --all --decorate
# Dann die Szenario-Anweisungen im Terminal-Output folgen
```

