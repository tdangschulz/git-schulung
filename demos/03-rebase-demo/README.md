# Rebase Demo

Start: `datei.txt` enthält "Zeile 1".

## Übungsaufgaben

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
