# Merge-Strategien & Merge-Optionen

**Zwei Ebenen, die man nicht verwechseln darf:**

1. **Merge-Strategien** (`-s`) — Wie Git den Merge technisch durchführt
2. **Merge-Optionen/Flags** (`--no-ff`, `--squash`, etc.) — Wie Git das Ergebnis verbucht

## Schnellstart

```bash
# Auspacken
cd /tmp
tar xzf pfad/zu/start.tar.gz
cd start

# Status: 3 Branches (main + feature-a + feature-b + feature-c)
git log --oneline --graph --all
```

---

# Teil 1: Merge-Strategien (`git merge -s <strategie>`)

Die Strategie bestimmt, **WIE** Git zwei (oder mehr) Snapshots
zusammenführt.

## Die Vier Strategien

### 1. recursive — Der Standard (Default)

```bash
git merge -s recursive <branch>
# oder einfach (recursive ist default):
git merge <branch>
```

**Was passiert:**
1. Finde den gemeinsamen Vorfahren (Merge Base)
2. 3-Way-Merge: Base ↔ HEAD ↔ Anderer Branch
3. Bei mehreren möglichen Bases → rekursiv zusammenführen
4. Ergebnis = Merge-Commit (bei divergierender History)

**Optionen** (über `-X`):
| Option | Wirkung |
|---|---|
| `-Xours` | Bei Konflikt: unsere Version nehmen |
| `-Xtheirs` | Bei Konflikt: deren Version nehmen |
| `-Xpatience` | Präziserer Diff (langsamer) |
| `-Xdiff-algorithm=histogram` | Noch präziser |

👉 **Für 99% der Fälle ist `git merge` = `git merge -s recursive`**

---

### 2. resolve — Die einfache Alternative

```bash
git merge -s resolve <branch>
```

**Der Unterschied:** Nutzt NUR EINEN Merge Base (kein rekursives
Zusammenführen). Älter, simpler, findet aber auch weniger Konflikte.

**Wann?** Praktisch nie nötig. Historisch für pathologische
Criss-Cross-Fälle, die recursive nicht packt.

---

### 3. octopus — Viele Branches auf einmal

```bash
git merge -s octopus <branch1> <branch2> <branch3> ...
```

**Das Besondere:** Merged MEHR ALS ZWEI Branches in EINEM Befehl.
Erzeugt einen Merge-Commit mit × Eltern.

**⚠️ Kann KEINE Konflikte lösen!** Schlägt fehl, sobald sich
Branches in die Quere kommen.

**Wann?** Mehrere unabhängige Topic-Branches bündeln (Release).
Nur wenn alle konfliktfrei sind.

---

### 4. ours — Unser Code gewinnt immer

```bash
git merge -s ours <branch>
```

**Kein normales Mergen!** Der Merge wird aufgezeichnet (neuer Commit,
anderer Branch als Vorfahre), aber der **gesamte Inhalt bleibt = HEAD**.

**Wann?** Einen Branch als „erledigt/tot" markieren ohne seinen
Code zu übernehmen.

---

### ⚠️ Wichtige Verwechslungsgefahr!

```
-s ours  = Strategie: GANZER anderer Branch verworfen
-X ours  = Option für recursive: NUR bei Konflikten unsere Version
```

```bash
# RIESIGER Unterschied:
git merge -s ours feature-b      # feature-b's Code KOMPLETT ignoriert
git merge -X ours feature-b      # feature-b's Code ÜBERNOMMEN, nur Konflikt = unsere
```

---

# Teil 2: Merge-Optionen/Flags (`--no-ff`, `--squash`, `--ff-only`)

Die Flags bestimmen, **WIE** das Ergebnis in der History aussieht.

> **Strategie + Option = vollständige Kontrolle**
> `git merge -s recursive --no-ff feature/branch`

### Alle drei Flags im Vergleich

```bash
# Voraussetzung: main + feature haben divergierende History
# main:     A---B---C
#                \
# feature:         D---E
```

**`--no-ff`** — Erzwungener Merge-Commit (auch wenn FF möglich)
```bash
git merge --no-ff feature -m "Feature gemergt"
```
```
main:     A---B---C---F (Merge-Commit)
                \     /
feature:         D---E
```
✅ Sichtbar, wann ein Feature reinkam
✅ PRs, Releases, Meilensteine

**`--ff-only`** — Nur Fast-Forward, sonst abbrechen
```bash
git merge --ff-only feature
# Wenn main parallel Commits hat → Fehler!
```
```
main:     A---B---C---D---E  (nur bei linearem Vorsprung)
```
✅ Saubere lineare History
❌ Schlägt fehl bei divergierenden Branches

**`--squash`** — Alle Commits in einen packen
```bash
git merge --squash feature
git commit -m "Feature in einem Commit"
```
```
main:     A---B---C---S (Squash-Commit)
```
✅ Ein Commit = ein Feature
❌ Keine Branch-History, Verlust der Zwischen-Commits

**`--no-commit`** (Bonus) — Merge vorbereiten ohne zu committen
```bash
git merge --no-commit feature
# Jetzt kannst du den Merge-Inhalt ändern, testen, anpassen
git commit -m "Feature gemergt"
```

---

### Vergleich: Wann was?

| Flag | Merge-Commit | History | Wann nehmen? |
|---|---|---|---|
| `--no-ff` | Ja (erzwungen) | Sichtbar | Features, Releases |
| `--squash` | Standard-Commit | Linear | Kleine Fixes, Feature-Bündel |
| `--ff-only` | Nein | Linear | Nur bei sauberer Basis |
| (nichts) | Ja (bei Divergenz) | Gemischt | Default — Standard-Merge |

---

# 🖥️ Live-Demos

## Setup

```bash
cd /tmp/git-schulung
rm -rf merge-strategies && mkdir merge-strategies && cd merge-strategies
git init
```

```bash
# ====== MAIN ======
echo "main: Projekt gestartet" > README.md
git add . && git commit -m "Initial commit"

# ====== FEATURE A ======
git checkout -b feature-a
echo "login: Funktion" > login.txt
git add . && git commit -m "feat: Login"

# ====== FEATURE B ======
git checkout main
git checkout -b feature-b
echo "theme: Darkmode" > theme.txt
git add . && git commit -m "feat: Darkmode"

# ====== FEATURE C ======
git checkout main
git checkout -b feature-c
echo "api: Client" > api.txt
git add . && git commit -m "feat: API-Client"

# ====== MAIN parallel ======
git checkout main
echo "main: Config" > config.txt
git add . && git commit -m "chore: Config"

git log --oneline --graph --all
# → 3 Feature-Branches + main mit eigenem Commit
```

---

### Demo A: recursive (Default)

```bash
# Feature-A mergen — recursive läuft automatisch
git checkout main
git merge feature-a -m "Merge feature-a (recursive)"

git log --oneline --graph --all
ls -la  # login.txt ist da
```

**Mit `-X` Optionen testen:**
```bash
# Zurücksetzen und Konflikt provozieren
git reset --hard HEAD~1  # Merge rückgängig

# Main ändert login.txt
echo "main: Login-Seite" > login.txt
git add . && git commit -m "Main-Änderung an login.txt"

git checkout feature-a
echo "feature-a: Login anders" > login.txt
git add . && git commit -m "Feature-Änderung an login.txt"

git checkout main

# -X ours: bei Konflikt unsere Version nehmen
git merge -X ours feature-a -m "Merge feature-a (ours bei Konflikt)"
cat login.txt  # => "main: Login-Seite"

# -X theirs: bei Konflikt deren Version nehmen
git reset --hard HEAD~1
git merge -X theirs feature-a -m "Merge feature-a (theirs bei Konflikt)"
cat login.txt  # => "feature-a: Login anders"
```

**🗣️ Erklären:** `recursive` ist der Standard — immer aktiv wenn
du `git merge` machst. Mit `-X` steuerst du die Konflikt-Auflösung.

---

### Demo B: resolve

```bash
# Frisches Mini-Repo
mkdir -p demo-resolve && cd demo-resolve
git init
echo "base" > base.txt
git add . && git commit -m "Initial"

git checkout -b branch-x
echo "x" > base.txt && git add . && git commit -m "X"

git checkout main
git checkout -b branch-y
echo "y" > base.txt && git add . && git commit -m "Y"

git checkout main

# resolve — bei einfachen Merges kein Unterschied sichtbar
git merge -s resolve branch-x -m "Merge branch-x (resolve)"
git log --oneline --graph --all
```

**🗣️ Erklären:** `resolve` ist älter und simpler. Bei einfachen
Merges siehst du keinen Unterschied. Nur bei Criss-Cross-Historie
(selten) zeigt sich der Unterschied zu recursive.

---

### Demo C: octopus

```bash
cd /tmp/git-schulung/merge-strategies

# Octopus: ALLE Features in EINEM Merge
git checkout main
git merge -s octopus feature-a feature-b feature-c \
  -m "Octopus: alle Features in einem Merge"

git log --oneline --graph --all
# → EIN Merge-Commit mit 3 Eltern!
ls -la  # Alle Dateien da
```

**Crash-Test: Octopus kann keine Konflikte!**
```bash
git checkout main && git reset --hard HEAD~4

# feature-a und feature-b ändern gleiche Datei
git checkout feature-a
echo "feature-a exclusive" > conflict.txt
git add . && git commit -m "feature-a: conflict.txt"

git checkout feature-b
echo "feature-b exclusive" > conflict.txt
git add . && git commit -m "feature-b: conflict.txt"

git checkout main
git merge -s octopus feature-a feature-b 2>&1 || echo "❌ Octopus failed!"

# Lösung: einzeln mergen
git merge --abort
git merge feature-a -m "feature-a einzeln"
git merge feature-b -m "feature-b einzeln"
```

**🗣️ Erklären:** Octopus ist cool, scheitert aber sobald
sich Branches überlappen. Dann einzeln mergen.

---

### Demo D: ours

```bash
# Frisches Mini-Repo
mkdir -p demo-ours && cd demo-ours
git init

echo "Projekt" > README.md
git add . && git commit -m "Initial"

git checkout -b feature-alt
echo "ALTER Code — veraltet" > alt.txt
git add . && git commit -m "Altes Feature"

git checkout main
git checkout -b feature-neu
echo "NEUER Code" > neu.txt
git add . && git commit -m "Neues Feature"

git checkout main
echo "Config" > config.txt
git add . && git commit -m "Config"

# feature-alt als "tot" markieren — Code verwerfen
git merge -s ours feature-alt -m "Merge feature-alt (tot)"

ls -la  # alt.txt fehlt!
git log --oneline --graph --all
# Aber feature-alt ist in der History sichtbar

# normales recursive: Code wird übernommen
git merge feature-neu -m "Merge feature-neu (recursive)"
ls -la  # neu.txt ist da
```

**🗣️ Erklären:** `-s ours` ist kein böser Merge — es sagt
„ich hab den Branch gesehen, will den Code aber nicht".
Klassiker für veraltete Experimente.

---

### Demo E: --no-ff vs --squash vs --ff-only

```bash
cd /tmp/git-schulung/merge-strategies
git checkout main && git reset --hard HEAD~1

# --no-ff: Erzwungener Merge-Commit
git merge --no-ff feature-a -m "Merge feature-a (--no-ff)"
git log --oneline --graph --all
# → Merge-Commit auch wenn FF möglich

git reset --hard HEAD~1

# --squash: Alles in einen Commit gepackt
git merge --squash feature-a
git status  # Changes are staged
git commit -m "Feature-A als Squash-Commit"
git log --oneline --graph --all
# → Flache History, Branch-Info weg

git reset --hard HEAD~1

# --ff-only: Nur linearer Vorsprung erlaubt
git merge --ff-only feature-a  # Klappt (feature-a ist voraus)
git log --oneline --graph --all

# Jetzt mit parallel entwickeltem main:
git reset --hard HEAD~1
# Main hat eigenen Commit
echo "main change" >> config.txt
git add . && git commit -m "Main change"
git merge --ff-only feature-a  # ❌ Fehler!
```

---

# 🔍 Vollständige Vergleichstabelle

## Merge-Strategien (`-s`)

| Strategie | Befehl | Max Branches | Konflikte | Merge-Commit | Wann? |
|---|---|---|---|---|---|
| **recursive** | `merge` (Default) | 2 | ✅ Wird gelöst | ✅ Ja | **Standard** |
| **resolve** | `merge -s resolve` | 2 | ✅ Wird gelöst | ✅ Ja | Legacy/Notnagel |
| **octopus** | `merge -s octopus` | 3+ | ❌ Schlägt fehl | ✅ Ja (× Eltern) | Branches bündeln |
| **ours** | `merge -s ours` | 2 | ✅ Ignoriert anderen | ✅ Ja | Branch als tot markieren |

## Merge-Optionen/Flags (`--`)

| Flag | Strategie | Merge-Commit | Wann? |
|---|---|---|---|
| **`--no-ff`** | beliebig | ✅ Erzwungen | Features sichtbar machen |
| **`--ff-only`** | beliebig | ❌ | Lineare History erzwingen |
| **`--squash`** | beliebig | ❌ (normaler Commit) | Feature in einen Commit |
| (nichts) | recursive | ✅/❌ je nach Situation | Normaler Merge |

---

# ⚠️ Typische Praxisprobleme

**❗ `-s ours` vs `-X ours` verwechseln:**
→ `-s ours` = kompletter Branch verworfen (wenn du den Code willst → falsch!)
→ `-X ours` = nur Konflikte mit unserer Version (meist das, was gemeint ist)

**❗ Octopus mit Konflikten:**
→ `git merge -s octopus` schlägt sofort fehl → `git merge --abort` → einzeln mergen

**❗ `--squash` vergessen hinterher zu committen:**
→ `--squash` staged nur! `git commit -m "..."` nicht vergessen.

**❗ `--ff-only` schlägt fehl weil main parallel weiterentwickelt wurde:**
→ Feature-Branch vorher rebasen: `git rebase main`, dann `git merge --ff-only`

---

# 🔄 Wiederherstellung

```bash
# Merge rückgängig
git reset --hard ORIG_HEAD

# Octopus-Abbruch
git merge --abort

# Reflog für verlorene Commits
git reflog
```

---

# 🧠 Für Trainer: Der rote Faden

**Teilnehmern klarmachen:**

1. **„Strategie" = WIE** der Merge rechnet (recursive, resolve, octopus, ours)
2. **„Flag" = WIE** das Ergebnis in der History aussieht (`--no-ff`, `--squash`)
3. **Beides kombinierbar:** `git merge -s recursive --no-ff feature/branch`

**Die wichtigste Botschaft:**
> `git merge` ohne Angabe = `-s recursive` = der beste Algorithmus.
> Die anderen (resolve, octopus, ours) sind Spezialfälle für seltene Situationen.
> Die Flags `--no-ff`, `--squash`, `--ff-only` nutzt man dagegen täglich.
