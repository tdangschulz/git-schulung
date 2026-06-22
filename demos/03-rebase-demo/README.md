## Schnellstart

```bash
# Auspacken
cd /tmp
tar xzf pfad/zu/start.tar.gz
cd start

# Status: README.md auf main, alles committed
# Erster Befehl: Feature-Branch anlegen
git switch -c feature/neu
```

# Rebase Demo

Start: `README.md` enthält "Start".

**Warum verschiedene Dateien?** 
Weil sonst beim Rebase ein Merge-Konflikt entsteht, wenn beide
Branches die gleiche Datei ändern — das lenkt vom eigentlichen
Rebase-Lerneffekt ab. Am Ende gibt's einen Extra-Abschnitt
„Was passiert bei Konflikten?".

## Befehlsablauf

1. **Initial-Commit**
   `git init && git add README.md && git commit -m "Initial commit"`

2. **Feature-Branch anlegen**
   `git switch -c feature/neu`

3. **Zwei Commits im Feature**
   `echo "Feature-Änderung A" > feature.txt`
   `git add . && git commit -m "Feature commit A"`
   `echo "Feature-Änderung B" > utils.txt`
   `git add . && git commit -m "Feature commit B"`

4. **Parallel: main hat auch neue Commits**
   `git switch main`
   `echo "Main-Änderung 1" > main.txt`
   `git add . && git commit -m "Main commit 1"`

5. **History vor Rebase ansehen**
   `git switch feature/neu && git log --oneline --graph --all`

6. **Rebase**
   ```bash
   git rebase main
   ```
   → Die Feature-Commits hängen jetzt hinter main.
   → **Kein Konflikt**, weil feature.txt und utils.txt in main nicht existieren.

7. **History nach Rebase**
   `git log --oneline --graph --all`
   → Achtung: Die Hashes der Feature-Commits haben sich geändert!
   → [Siehe Erklärung unten →](#-warum-ändern-sich-die-hashes)

8. **Merge-Vergleich**
   Mach dasselbe Szenario nochmal und merge statt rebase.
   Welchen Unterschied siehst du in der History?

---

### 🔬 Warum ändern sich die Hashes?

Der Hash eines Commits ist der SHA-1 von ALLEN Metadaten, nicht nur
vom Inhalt. Ein Commit-Objekt ist im Rohformat:

```
commit 230\0
┌─────────────────────────────────────────┐
│ tree 7c9b5a1d...                        │ ← Verzeichnis-Snapshot
│ parent abc1234def...                    │ ← VORHERIGER COMMIT 🔥
│ author Max <max@x> 1719000000 +0200     │
│ committer Max <max@x> 1719000000 +0200  │
│                                         │
│ Feature commit B                        │ ← Nachricht
└─────────────────────────────────────────┘
```

**Vor dem Rebase:**
```
main:     A---B
              \
feature:         C---D
                    ^
                  parent von D = C
                  SHA-1(C + Inhalt + parent=A + Metadaten) = abc123...
```

**Nach dem Rebase:**
```
main:     A---B
              \
feature:         C'---D'
                    ^
                  parent von D' = C'
                  (C' hat neuen Parent = B statt A!)
                  SHA-1(C' + Inhalt + parent=B + Metadaten) = def456... ← ANDERER HASH!
```

**Deshalb ändert sich der Hash: Weil sich der PARENT geändert hat.**

| Was ändert sich beim Rebase? | Alte Hash | Neue Hash |
|---|---|---|
| Datei-Inhalt | ✅ gleich | ✅ gleich |
| Tree-Hash | ✅ gleich | ✅ gleich |
| **Parent-Hash** | **alt (A)** | **neu (B = Spitze von main)** |
| Autor | ✅ gleich | ✅ gleich |
| Nachricht | ✅ gleich | ✅ gleich |
| **SHA-1 Gesamt** | **abc123...** | **def456...** ❗ |

**Konkretes Beispiel:**

```bash
# Vor Rebase — Commits zeigen:
# C = 3a1b2c (Feature commit A, parent = A)
# D = 9f8e7d (Feature commit B, parent = C)

# Nach Rebase:
# C' = 7f6e5d (Inhalt von C, aber parent = B [Spitze von main]!)
# D' = 4c3b2a (Inhalt von D, aber parent = C')
```

Jeder Commit ist wie ein Tintenfisch, der den vorherigen festhält.
Wenn sich der festgehaltene Arm ändert, ist der ganze Tintenfisch
ein anderer.

**Live die Änderung nachvollziehen:**

```bash
# Vor dem Rebase: Hashes notieren
git switch feature/neu
git log --oneline
git rev-parse HEAD~1 HEAD  # → alte Hashes

# Rebase ausführen
git rebase main

# Nach dem Rebase: Neue Hashes!
git log --oneline
# → Gleiche Commit-Nachrichten, aber ANDERE Hashes!

# Direkter Beweis: Parent hat sich geändert
git cat-file -p HEAD
# → zeigt den neuen Parent (Spitze von main, nicht mehr den alten Base)
```

**Praxis-Konsequenz:**

```bash
# Warum du niemals gepushte Commits rebasen darfst:
#
# Kollege A pushed feature nach origin:
#   origin:  C---D  (Hashes: abc... / def...)
#
# Kollege B pulled: hat lokal C und D mit abc... / def...
#
# Kollege A rebased: C'---D' (neue Hashes: 111... / 222...)
#   push --force: origin hat jetzt 111... / 222...
#
# Kollege B macht git pull:
#   → Git denkt: "C und D sind anders als 111' und 222'..."
#   → Merge-Chaos! Doppelte Commits, Konflikte!
#
# Lösung: Nur lokale, UNGEPUSHTE Commits rebasen!
```

---

### 🔬 Rebase vs. Merge: Was passiert mit den Hashes?

#### Merge: Hashes bleiben GLEICH

```bash
# Ausgangssituation (beide Branches haben divergiert):
# main:     A---B
#              \
# feature:         C---D

# git merge feature (von main aus):
git checkout main
git merge feature -m "Merge feature"
```

```
main:     A---B---M (Merge-Commit)
              \   /
feature:         C---D
                     ^
                   C und D sind UNVERÄNDERT!
                   Ihre Parent-Kette C → A bleibt intakt.
                   SHA-1(C) = abc123... (vorher und nachher GLEICH)
                   SHA-1(D) = def456... (vorher und nachher GLEICH)
```

**Warum?** Merge erzeugt einen **NEUEN** Merge-Commit (M), der beide
Eltern referenziert. Die originalen Commits C und D werden **nicht
angetastet** — sie leben friedlich auf ihrem Branch weiter.

```
Merge-Commit M:
┌─────────────────────────────────────────┐
│ tree xyz123...                          │
│ parent B ← Erster Parent (HEAD = main)  │
│ parent D ← Zweiter Parent (feature)     │ ← NEU!
│ author Max <max@x> ...                  │
│ Merge feature                           │
└─────────────────────────────────────────┘
```

**C und D sind im Log sichtbar:**
```bash
git log --oneline --graph --all
# → *   M Merge feature
# → |\
# → | * D Feature commit B  ← Selber Hash wie vorher!
# → | * C Feature commit A  ← Selber Hash wie vorher!
# → * B Main commit 1
# → * A Initial commit
```

#### Rebase: Hashes werden NEU

```bash
# Gleiche Ausgangssituation:
# main:     A---B
#              \
# feature:         C---D

# git rebase main (von feature aus):
git checkout feature
git rebase main
```

```
main:     A---B
              \
feature:         C'---D'
                     ^
                   C' hat NEUEN Parent (B statt A)!
                   D' hat NEUEN Parent (C' statt C)!
                   SHA-1(C') = 111aaa... (ANDERER Hash als C!)
                   SHA-1(D') = 222bbb... (ANDERER Hash als D!)
```

**Warum?** Rebase SCHNEIDET die Commits C und D ab und SETZT sie
neu auf B. Weil der Parent sich ändert, ändert sich der SHA-1-Hash.

```
# Vor Rebase:
# C = commit 210\0tree e69de... parent A author ... Feature commit A
# D = commit 210\0tree f1a2b... parent C author ... Feature commit B

# Nach Rebase:
# C' = commit 210\0tree e69de... parent B author ... Feature commit A
#                                             ^^^^^^ ANDERS!
# D' = commit 210\0tree f1a2b... parent C' author ... Feature commit B
#                                             ^^^^^^^ ANDERS!
```

#### Die drei Unterschiede auf einen Blick

| Aspekt | Merge | Rebase |
|---|---|---|
| Original-Commits bleiben | ✅ Ja, unverändert | ❌ Nein, werden kopiert |
| Alte Hashes gültig | ✅ Ja | ❌ Nein, neue Hashes |
| History | 🔀 Verzweigt (Merge-Commit) | 📏 Linear (kein Knoten) |
| Parent-Kette | C→A (unverändert) | C'→B (neu verknüpft) |
| Neue Objekte | 1 Merge-Commit + Tree | 2 neue Commit-Objekte + Trees |

#### Live-Vergleich nachvollziehen

```bash
# === Szenario aufsetzen ===
cd /tmp/git-schulung
rm -rf merge-vs-rebase && mkdir merge-vs-rebase && cd merge-vs-rebase
git init

# Gemeinsame Basis
echo "start" > file.txt
git add . && git commit -m "Initial"  # A

# Feature-Branch mit 2 Commits
git checkout -b feature
sleep 1  # Sicherstellen, dass Timestamp anders ist
echo "Feature A" > feature.txt
git add . && git commit -m "Feature A"  # C
echo "Feature B" > utils.txt
git add . && git commit -m "Feature B"  # D

# Main parallel weiter
git checkout main
echo "Main Änderung" > main.txt
git add . && git commit -m "Main commit"  # B

echo ""
echo "=== Alte Hashes notieren ==="
git log --oneline --all

# === MERGE-Versuch ===
echo ""
echo "=== MERGE: Hashes bleiben ==="
git checkout feature
FEATURE_HASHES_BEFORE=$(git log --oneline --format=%h)
echo "Feature-Hashes VOR Merge: $FEATURE_HASHES_BEFORE"
git checkout main
git merge feature -m "Merge feature" --no-edit
git log --oneline --graph --all
echo ""
echo "Feature-Hashes NACH Merge:"
git log --oneline main ^main^1 --format=%h
# → Selbe Hashes wie vorher!

# === REBASE-Versuch (frisches Szenario) ===
cd /tmp/git-schulung
rm -rf rebase-vergleich && mkdir rebase-vergleich && cd rebase-vergleich
git init
echo "start" > file.txt
git add . && git commit -m "Initial"  # A
git checkout -b feature
echo "Feature A" > feature.txt
git add . && git commit -m "Feature A"  # C
echo "Feature B" > utils.txt
git add . && git commit -m "Feature B"  # D
git checkout main
echo "Main Änderung" > main.txt
git add . && git commit -m "Main commit"  # B

echo ""
echo "=== REBASE: Hashes ändern sich ==="
git checkout feature
FEATURE_HASHES_BEFORE=$(git log --oneline --format=%h)
echo "Feature-Hashes VOR Rebase: $FEATURE_HASHES_BEFORE"
git rebase main
echo "Feature-Hashes NACH Rebase:"
git log --oneline --format=%h
# → ANDERE Hashes!
```

#### 🧠 Merksatz

> **Merge bewahrt die alten Commits + Hashes. Rebase schreibt die Geschichte neu.**
>
> Merge fügt einen neuen Knoten hinzu (plus Eltern).
> Rebase schneidet die alten Commits ab und erzeugt neue mit neuen Eltern.
>
> Deshalb:
> - Merge = sicher für öffentliche Branches (Hashes bleiben, alle happy)
> - Rebase = nur für lokale/ungepushte Branches (niemand hat die alten Hashes)

---

### 🧪 Was passiert, wenn BEIDE Branches die GLEICHE Datei ändern?

Im ursprünglichen Demo-Setup haben beide Branches an `datei.txt`
angehängt. Beim Rebase kommt es dann zum **Merge-Konflikt**:

```bash
# Setup
echo "Zeile 1" > datei.txt
git add . && git commit -m "Initial"

git checkout -b feature
echo "Feature-Änderung A" >> datei.txt
git add . && git commit -m "Feature commit A"
echo "Feature-Änderung B" >> datei.txt
git add . && git commit -m "Feature commit B"

git checkout main
echo "Main-Änderung 1" >> datei.txt
git add . && git commit -m "Main commit 1"

git checkout feature
git rebase main
# → CONFLICT! Beide haben datei.txt geändert!
```

**Warum?** Der erste Feature-Commit hat „Feature-Änderung A" **nach**
„Zeile 1" angehängt. Main hat aber „Main-Änderung 1" **dazwischen**
geschoben. Jetzt passt der Patch-Kontext nicht mehr — Git weiß nicht,
wo die Feature-Änderung hinsoll.

**Lösung bei Konflikten während Rebase:**

```bash
# 1. Konflikt lösen (datei.txt manuell editieren)
echo "Zeile 1" > datei.txt
echo "Main-Änderung 1" >> datei.txt
echo "Feature-Änderung A" >> datei.txt
echo "Feature-Änderung B" >> datei.txt

# 2. Stagen
git add datei.txt

# 3. Weiter machen
git rebase --continue
# → Git wendet den NÄCHSTEN Commit an (hier: Feature commit B)
```

**Nochmal Konflikt?** Dann für jeden Feature-Commit einzeln wiederholen.

**Oder abbrechen:**
```bash
git rebase --abort
```

---

## ⚠️ Typische Praxisprobleme

**❗ Hashes ändern sich beim Rebase:** Die Commits sehen gleich aus, haben aber neue Hashes.
→ Das ist kein Bug, sondern gewollt! Der Parent hat sich geändert.

**❗ Rebase abbrechen:** `git rebase --abort` — alles wie vorher. Keine Panik!

**❗ Auf gepushte Commits rebasen:** Schon geteilte Commits rebasen = andere haben Chaos.
→ Goldene Regel: Nie rebasen was auf dem Remote liegt und von anderen gezogen wurde.

**❗ Merge-Konflikt während Rebase:** Ein Commit kann nicht sauber angewendet werden.
→ Konflikt lösen, `git add datei.txt`, `git rebase --continue`

**❗ Rebase statt Merge:** `git rebase main` macht dich zum Diktator der Geschichte.
→ Deine Commits werden neu geschrieben — niemand sonst sollte sie haben!
