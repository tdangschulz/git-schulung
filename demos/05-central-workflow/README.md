## Schnellstart

```bash
# Auspacken
cd /tmp
tar xzf pfad/zu/start.tar.gz
cd start

# Status: datei.txt mit "Dev A's Arbeit", auf main, Remote zeigt auf ../central.git
# central.git existiert im selben Ordner wie start/
# Erster Befehl: Repo initialisieren und pushen
cd /tmp/central-workflow && git push origin main
```

# Central Workflow

Demo des zentralen Workflows mit einem gemeinsamen main-Branch.

Start: `datei.txt` mit "Dev A's Arbeit".

## Befehlsablauf

1. **Initial-Commit**
   `git init && git add datei.txt && git commit -m "Dev A initial"`

2. **Bare-Repo als Server erstellen**
   `cd .. && git clone --bare . central.git`
   `cd central-workflow && git remote add origin ../central.git`
   `git push origin main`

3. **Dev B klont**
   `cd .. && git clone central.git dev-b`

4. **Dev A pusht zuerst**
   `echo "Zeile von Dev A" >> datei.txt`
   `git add . && git commit -m "Dev A changes"`
   `git push origin main`

5. **Dev B versucht zu pushen (ohne vorher zu pullen)**
   `cd ../dev-b`
   `echo "Zeile von Dev B" >> datei.txt`
   `git add . && git commit -m "Dev B changes"`
   `git push origin main`
   → **FEHLER!** Non-fast-forward! Warum?

6. **Dev B pullt mit Rebase**
   `git pull --rebase origin main`
   → Jetzt kommt ein **Merge-Konflikt**! Beide haben die gleiche Datei geändert.

7. **Konflikt lösen**
   `cat datei.txt` — siehst du die <<<<<<< Markierungen?
   Mach aus beiden Zeilen eine: beide sollen drin stehen.
   `git add datei.txt`
   `git rebase --continue`

8. **Jetzt pushen**
   `git push origin main`

## ⚠️ Typische Praxisprobleme

**❗ Push rejected (non-fast-forward):** Du hast vergessen vor dem Push zu pullen.
→ \`git pull --rebase origin main\` — holt neue Commits + setzt deine drauf.

**❗ Merge-Konflikt beim Pull:** Weil du + Kollege die gleiche Datei geändert habt.
→ \`git status\` zeigt conflicted files. Lösen, adden, \`git rebase --continue\`.

**❗ Unabsichtlich gemergt statt rebased:** \`git pull\` ohne \`--rebase\` erzeugt Merge-Commit.
→ \`git reset --hard ORIG_HEAD\` und dann \`git pull --rebase\`
