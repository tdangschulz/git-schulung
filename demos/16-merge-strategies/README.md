# Merge-Strategien (`-s`): Recursive, Resolve, Octopus, Ours

**📍 Wichtig:** Das hier sind die vier Git Merge-Strategien (gesteuert via `-s`).
Sie sind NICHT zu verwechseln mit Merge-Optionen wie `--no-ff`, `--squash` oder `--ff-only`.

## Schnellstart

```bash
# Start-Repo holen (Pfad anpassen):
cd /tmp
tar xzf pfad/zu/start.tar.gz
cd start

# Fertig! Alle Branches sind vorbereitet.
# Direkt loslegen mit:
git log --oneline --graph --all
# → Siehst du main, feature-a, feature-b und feature-c?
```

---

## 📖 Theorie: Die vier Strategien

### 1. recursive — Der Standard (Default)

```bash
git merge -s recursive <branch>
# oder einfach (recursive ist default):
git merge <branch>
```

**Was passiert:**
1. Finde den gemeinsamen Vorfahren (Merge Base)
2. Berechne 3-Way-Merge: Base ↔ HEAD ↔ Anderer Branch
3. Bei mehreren Merge Bases (Criss-Cross) → merge diese zuerst rekursiv
4. Erzeuge Merge-Commit (bei divergierender History)

**Algorithmus-Optionen** (über `-X`):
- `-Xpatience` — Langsamerer, aber detailgenauerer Diff
- `-Xdiff-algorithm=histogram` — Noch präziser
- `-Xours` — Bei Konflikt: unsere Version nehmen
- `-Xtheirs` — Bei Konflikt: deren Version nehmen

**Für Trainer:** Das ist der Standard, der **immer** läuft wenn du
einfach `git merge` machst (und kein Fast-Forward möglich ist). Er ist
der ausgereifteste und sicherste — für 99% der Fälle perfekt.

---

### 2. resolve — Die einfache Alternative

```bash
git merge -s resolve <branch>
```

**Unterschied zu recursive:**
- Nutzt NUR EINEN Merge Base (kein rekursives Zusammenführen)
- Älterer Algorithmus, weniger intelligent
- Erzeugt seltener Konflikte als recursive (weil simpler)
- Kann aber Konflikte übersehen, die recursive findet

**Wann nehmen?**
- Sehr selten nötig; wurde früher für Criss-Cross-Merges empfohlen
- Wenn recursive zu viele Merge Bases findet und ewig braucht
- Legacy aus den frühen Git-Tagen (heute kaum noch relevant)

**Für Trainer:** Zeigen, dass es existiert, aber klar machen:
recursive ist fast immer die bessere Wahl. Resolve ist
der Notnagel für pathologische Criss-Cross-Fälle.

---

### 3. octopus — Viele Branches auf einmal

```bash
git merge -s octopus <branch1> <branch2> <branch3> ...
# Mindestens 3 Branches — bei 2 macht recursive
```

**Was passiert:**
- Merged MEHR ALS ZWEI Branches in einem Befehl
- Erzeugt EINEN Merge-Commit mit MEHREREN Eltern
- **Kann KEINE Konflikte lösen!** Schlägt fehl bei Konflikten
- Funktioniert nur wenn sich alle Änderungen sauber überlappen

**Wann nehmen?**
- Mehrere unabhängige Topic-Branches gleichzeitig integrieren
- Release-Bündelung („alle Features in einen Commit")
- Continuous Integration: mehrere fertige PRs bündeln

**⚠️ Voraussetzung:** Alle Branches müssen sich konfliktfrei mergen lassen.
Sonst musst du die konfliktreichen Branches separat mergen.

**Für Trainer:** Ein seltener, aber cooler Spezial-Fall. Zeigen,
dass Git auch mehr als 2 Eltern verwalten kann — die History
ist dann ein echter Graph mit mehreren Verzweigungen.

---

### 4. ours — Unser Code gewinnt immer

```bash
git merge -s ours <branch>
```

**Was passiert:**
- Der Merge wird aufgezeichnet (neuer Commit mit 2 Eltern)
- Aber der gesamte Inhalt bleibt = der von HEAD (unserem Branch)
- Der andere Branch wird **verworfen**, aber als Vorfahre verknüpft

**⚠️ Nicht verwechseln mit `-Xours`:** 
- `merge -s ours` → Strategie: GANZER Code vom anderen wird ignoriert
- `merge -X ours` → Option für recursive: Nur bei Konflikten unsere Version

**Wann nehmen?**
- Einen Branch als „erledigt" markieren ohne seinen Code zu übernehmen
- Eine veraltete Feature-Fork als tot erklären
- Alten Staging-Branch mit main synchronisieren, ohne alte Änderungen zu riskieren
- Einen Branch an die History anbinden, den man nie wieder braucht

**Für Trainer:** Der Klassiker für „wir haben das Feature neu geschrieben,
der alte Branch ist tot, aber ich will die Verknüpfung in der History."

---

## 🖥️ Live-Demo: Alle Strategien ausprobieren

```bash
cd /tmp/git-schulung
rm -rf merge-strategies-demo && mkdir merge-strategies-demo && cd merge-strategies-demo
git init
```

### Setup: Main + 3 Feature-Branches

```bash
# ====== MAIN ======
echo "main: Projekt gestartet" > README.md
git add . && git commit -m "Initial commit"

# ====== FEATURE A (einfach) ======
git checkout -b feature-a
echo "feature-a: Login-Funktion" > login.txt
git add . && git commit -m "feat: Login hinzugefügt"

# ====== FEATURE B (einfach) ======
git checkout main
git checkout -b feature-b
echo "feature-b: Darkmode" > theme.txt
git add . && git commit -m "feat: Darkmode hinzugefügt"

# ====== FEATURE C (einfach) ======
git checkout main
git checkout -b feature-c
echo "feature-c: API-Client" > api.txt
git add . && git commit -m "feat: API-Client hinzugefügt"

# ====== MAIN parallel weiter ======
git checkout main
echo "main: Config-Datei" > config.txt
git add . && git commit -m "chore: Config hinzugefügt"

# Graph checken
git log --oneline --graph --all
# Sollte main (2 Commits) + 3 Feature-Branches zeigen
```

---

### Demo 1: recursive (Default)

```bash
cd /tmp/git-schulung/merge-strategies-demo

# Feature-A in main mergen — recursive ist automatisch aktiv
git checkout main
git merge feature-a -m "Merge feature-a via recursive"

# Graph: Merge-Commit mit 2 Eltern
git log --oneline --graph --all
echo "---"

# Jetzt main.txt und login.txt existieren
ls -la
echo "---"

# Option -X ours/theirs demonstrieren:
# Dafür nochmal zurücksetzen und Konflikt provozieren
git reset --hard HEAD~1  # Einen Schritt zurück (Merge rückgängig)

# Main ändert login.txt
echo "main: Login-Seite" > login.txt
git add . && git commit -m "Main-Änderung an login.txt"

# feature-a hat auch login.txt
git checkout feature-a
echo "feature-a: Login anders" > login.txt
git add . && git commit -m "Feature-Änderung an login.txt"

# Jetzt Merge mit -X ours (unsere Version bei Konflikt)
git checkout main
git merge -X ours feature-a -m "Merge feature-a (ours bei Konflikt)"
cat login.txt  # => "main: Login-Seite" (unsere Version)
```

**🗣️ Erklären:** `recursive` macht immer einen sauberen 3-Way-Merge.
Mit `-X` kann man bei Konflikten steuern, welche Seite gewinnt.
Das ist NICHT dasselbe wie `-s ours`!

---

### Demo 2: resolve

```bash
cd /tmp/git-schulung/merge-strategies-demo

# Reset zum Initial-Zustand (2 Commits auf main, 3 Features)
# Dafür frisches Setup schneller — neues Mini-Repo:
mkdir -p demo-resolve && cd demo-resolve
git init

# Gemeinsamer Start
echo "base" > base.txt
git add . && git commit -m "Initial"

# Zwei parallele Branches
git checkout -b branch-x
echo "x: Änderung" > base.txt
git add . && git commit -m "X ändert base"

git checkout main
git checkout -b branch-y
echo "y: Änderung" > base.txt
git add . && git commit -m "Y ändert base"

git checkout main

# resolve vs recursive — Ergebnis ist identisch
echo "--- MERGE mit resolve ---"
git merge -s resolve branch-x -m "Merge branch-x (resolve)"
git log --oneline --graph --all
```

**🗣️ Erklären:** `resolve` ist historisch. Bei einfachen Merges
siehst du keinen Unterschied zu `recursive`. Der Unterschied liegt
in Criss-Cross-Situationen (mehrere Merge Bases) — da kann
`recursive` Konflikte besser auflösen, weil es die Bases
rekursiv zusammenführt.

---

### Demo 3: octopus

```bash
cd /tmp/git-schulung/merge-strategies-demo

# octopus: 3+ Branches in EINEM Merge-Commit
git checkout main
git merge -s octopus feature-a feature-b feature-c -m "Octopus: alle Features auf einmal"

# Graph zeigt: EIN Merge-Commit mit 3 Eltern!
git log --oneline --graph --all

echo "---"
ls -la
# Alle Dateien sind da: login.txt, theme.txt, api.txt, config.txt, README.md
```

**🗣️ Erklären:** Der Octopus-Merge ist perfekt wenn mehrere
Branches unabhängig voneinander sind und sich nicht in die
Quere kommen. Erzeugt einen Merge-Commit mit × Eltern.

**⚠️ Crashing test — Octopus kann keine Konflikte!**

```bash
cd /tmp/git-schulung/merge-strategies-demo

# Reset
git checkout main && git reset --hard HEAD~1

# Konflikt erzeugen: feature-a und feature-b ändern gleiche Datei
git checkout feature-a
echo "exklusiv: feature-a" > gemeinsam.txt
git add . && git commit -m "feature-a erzeugt gemeinsam.txt"

git checkout feature-b
echo "exklusiv: feature-b" > gemeinsam.txt
git add . && git commit -m "feature-b erzeugt gemeinsam.txt"

# Octopus scheitert!
git checkout main
git merge -s octopus feature-a feature-b 2>&1 || echo "❌ Octopus failed — kann keine Konflikte lösen!"

# Lösung: Konfliktreiche Branches einzeln mergen (mit recursive)
git merge -s recursive feature-a -m "feature-a einzeln gemerged"
git merge -s recursive feature-b -m "feature-b einzeln gemerged"
```

**🗣️ Erklären:** Octopus funktioniert NUR wenn alle Branches
konfliktfrei sind. Bei Konflikten sofort `merge --abort` und
einzeln mergen.

---

### Demo 4: ours

```bash
cd /tmp/git-schulung/merge-strategies-demo

# Reset: zurück zum letzten sauberen Stand
# (nach octopus-Demo — main hat beide Features)
# Für Klarheit: neues Mini-Demo
mkdir -p demo-ours && cd demo-ours
git init

# Situation: Altes Feature (veraltet), neues Feature
echo "Main-Projekt" > README.md
git add . && git commit -m "Initial"

git checkout -b feature-alt
echo "ALTER Code — nicht mehr aktuell" > alt.txt
git add . && git commit -m "Altes Feature"

git checkout main
git checkout -b feature-neu
echo "NEUER Code — aktuell" > neu.txt
git add . && git commit -m "Neues Feature"

git checkout main
echo "Main Config" > config.txt
git add . && git commit -m "Main Config"

# Jetzt: feature-alt soll MARKIERT werden (nicht übernommen)
git merge -s ours feature-alt -m "Merge feature-alt (ours) — tot erklärt"

# Prüfen: alt.txt existiert NICHT!
ls -la

# Aber im Log ist feature-alt als Vorfahre sichtbar
git log --oneline --graph --all
echo "---"

# Dagegen: normales recursive würden den Code übernehmen
git merge feature-neu -m "Merge feature-neu (recursive)"
ls -la  # neu.txt ist da
```

**🗣️ Erklären:** `-s ours` ist kein "böser" Befehl. Es sagt nicht
"unser Code ist besser", sondern "wir wollen den Merge historisch
festhalten, aber den anderen Code nicht". Klassiker: Ein Branch
mit veralteten Experimenten wird so als "erledigt" markiert.

---

## 🔍 Vergleichstabelle

| Strategie | Befehl | Max Branches | Konflikte | Merge-Commit | Wann? |
|---|---|---|---|---|---|
| **recursive** | `merge -s recursive` (default) | 2 | ✅ Wird gelöst | ✅ Ja | Standard — immer |
| **resolve** | `merge -s resolve` | 2 | ✅ Wird gelöst | ✅ Ja | Legacy/Notnagel |
| **octopus** | `merge -s octopus` | 3+ | ❌ Schlägt fehl | ✅ Ja (× Eltern) | Mehrere Feature-Branches bündeln |
| **ours** | `merge -s ours` | 2 | ✅ Ignoriert anderen | ✅ Ja | Branch als tot markieren |

### 👉 Die Merkregel

- **99% der Zeit: recursive** (einfach `git merge` — das ist schon recursive)
- **Selten nötig: octopus** für mehrere Branches auf einmal
- **Extrem selten: resolve** — historisch, nur in pathologischen Fällen
- **Spezialfall: ours** — Branch historisch verknüpfen ohne Code zu übernehmen

### ⚠️ Nicht verwechseln!

- `merge -s ours` = **Strategie**: anderer Code komplett verworfen
- `merge -X ours` = **Option für recursive**: bei Konflikten unsere Seite nehmen
- `merge -X theirs` = **Option für recursive**: bei Konflikten deren Seite nehmen

```bash
# Großer Unterschied:
git merge -s ours feature-b        # feature-b's Code KOMPLETT ignoriert
git merge -X ours feature-b        # feature-b's Code ÜBERNOMMEN, nur bei Konflikt: unsere Version
```

---

## 🧪 Trainer-Erklärung für Teilnehmer

**Einstieg:** 
> "Ihr kennt `git merge` — dahinter steckt eine Strategie namens `recursive`.
> Es gibt aber drei weitere. Zwei davon (resolve, octopus) sind Spezialwerkzeuge,
> die dritte (ours) ist ein nützlicher Trick für den Werkzeugkasten."

**recursive erklären:**
> "Stell dir vor, du willst zwei Versionen einer Geschichte zusammenführen.
> Du suchst die letzte gemeinsame Szene (= Merge Base), dann schaust du,
> was in beiden Versionen passiert ist, und fügst es zusammen.
> Genau das macht Git — und bei mehreren möglichen Basisszenen
> macht es das rekursiv (= wiederholt), daher der Name."

**octopus erklären:**
> "Git kann nicht nur 2, sondern beliebig viele Branches in einem
> Merge-Commit zusammenführen. Der Graph sieht dann aus wie
> ein Kraken — daher der Name. Aber Vorsicht: Octopus kann keine
> Konflikte lösen. Funktioniert nur, wenn alles sauber zusammenpasst."

**ours erklären:**
> "Manchmal willst du einen Branch als 'erledigt' markieren,
> ohne seinen Code zu übernehmen. Sagt: 'Ja, ich hab den Branch gesehen,
> aber ich will nix davon.' Der Merge wird aufgezeichnet, der Code ignoriert."

---

## 🛠️ Was ist mit den anderen Strategien?

Git hat noch zwei weitere Strategien, die hier nicht vertieft werden:

- **`subtree`** — Zum Einbinden von Unterprojekten mit eigener Git-History
  (ähnlich Submodules, aber anders). Sehr speziell, braucht eigene Demo.
- **`ort`** — Seit Git 2.33 (2021) der **neue Standard**. Ist eine
  Rust-Neuimplementierung von `recursive`. Verhalten ist identisch,
  aber viel schneller und weniger Bugs. Wenn du `git merge` machst,
  läuft heute eigentlich `ort`, nicht mehr `recursive`.
  Du musst nix ändern — es ist einfach der bessere Unterbau.

---

## ⚠️ Typische Praxisprobleme

**❗ `-s ours` mit `-X ours` verwechseln:**
→ `-s ours` = kompletter Branch verworfen (falsch wenn du den Code willst!)
→ `-X ours` = nur Konflikte mit unserer Version lösen (meist das, was gemeint ist)

**❗ Octopus mit Konflikten:**
→ `git merge -s octopus` schlägt fehl, wenn sich Branches in die Quere kommen
→ Dann: `git merge --abort` und einzeln mergen

**❗ Octopus vergessen beim `merge --abort`:**
→ Octopus scheitert sofort → du bist noch im Merge-Modus → `merge --abort` nötig

**❗ `-s resolve` für moderne Repos:**
→ Es gibt fast keinen Grund mehr für resolve. Einfach beim default (ort/recursive) bleiben.

---

## 🔄 Wiederherstellung

```bash
# Reset nach fehlgeschlagenem Octopus
git merge --abort

# Merge rückgängig machen (letzten Commit)
git reset --hard ORIG_HEAD
```
