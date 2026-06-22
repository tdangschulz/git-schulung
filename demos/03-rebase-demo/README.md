## Schnellstart

```bash
# Auspacken
cd /tmp
tar xzf pfad/zu/start.tar.gz
cd start

# Status: datei.txt mit "Zeile 1", auf main, alles committed
# Erster Befehl: Feature-Branch anlegen
git switch -c feature/neu
```

# Rebase Demo

Start: `datei.txt` enthält "Zeile 1".

## Befehlsablauf

1. **Initial-Commit**
   `git init && git add datei.txt && git commit -m "Initial commit"`

2. **Feature-Branch anlegen**
   `git switch -c feature/neu`

3. **Zwei Commits im Feature**
   `echo "Feature-Änderung A" >> datei.txt`
   `git add . && git commit -m "Feature commit A"`
   `echo "Feature-Änderung B" >> datei.txt`
   `git add . && git commit -m "Feature commit B"`

4. **Parallel: main hat auch neue Commits**
   `git switch main`
   `echo "Main-Änderung 1" >> datei.txt`
   `git add . && git commit -m "Main commit 1"`

5. **History vor Rebase ansehen**
   `git switch feature/neu && git log --oneline --graph --all`

6. **Rebase**
   `git rebase main`
   → Die Feature-Commits hängen jetzt hinter main.

7. **History nach Rebase**
   `git log --oneline --graph --all`
   → Achtung: Die Hashes der Feature-Commits haben sich geändert! Warum?

8. **Optional: Merge-Vergleich**
   Mach dasselbe Szenario nochmal und merge statt rebase.
   Welchen Unterschied siehst du in der History?

### 🔬 Warum ändern sich die Hashes?

Der Hash eines Commits ist der SHA-1 von ALLEN Metadaten, nicht nur
vom Inhalt. Ein Commit-Objekt ist im Rohformat:

```
commit 230\0
┌─────────────────────────────────────────┐
│ tree 7c9b5a1d...                        │ ← Verzeichnis-Snapshot |
│ parent abc1234def...                    │ ← VORHERIGER COMMIT 🔥 |
│ author Max <max@x> 1719000000 +0200     │                        |
│ committer Max <max@x> 1719000000 +0200  │                        |
│                                         │                        |
│ Feature commit B                        │ ← Nachricht            |
└─────────────────────────────────────────┘
```

**Vor dem Rebase:**
```
main:     A---B
              \
feature:         C---D
                    ^
                  parent von D = C
                  SHA-1(C + Inhalt + parent=B + Metadaten) = abc123...
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
| **Parent-Hash** | **alt (vor main)** | **neu (Spitze von main)** |
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

## ⚠️ Typische Praxisprobleme

**❗ Rebase abbrechen:** \`git rebase --abort\` — alles wie vorher. Keine Panik!

**❗ Auf gepushte Commits rebasen:** Schon geteilte Commits rebasen = andere haben Chaos.
→ Goldene Regel: Nie rebasen was auf dem Remote liegt und von anderen gezogen wurde.

**❗ Merge-Konflikt während Rebase:** Ein Commit kann nicht sauber angewendet werden.
→ Konflikt lösen, \`git add datei.txt\`, \`git rebase --continue\`
