# Git-Praxisprobleme mit konkreten Beispielen

Typische Alltagsprobleme mit Git — und wie man sie löst.

---

## 1. Auf `main` committed, sollte aber auf einen Feature-Branch

```bash
# Neuen Branch auf den aktuellen Commits erstellen
git checkout -b feature/meine-arbeit

# main zurück auf den letzten richtigen Stand setzen
git checkout main
git reset --hard origin/main

# Alternativ: soft-reset (Änderungen bleiben staged)
git reset --soft HEAD~3
```

**Tipp:** Vor dem ersten Commit lieber `git stash` + `git switch -c` für spontane Ideen.

---

## 2. Merge-Konflikt — wer hat was geändert?

```bash
# Branches anzeigen die am Konflikt beteiligt sind
git log --merge --oneline

# Eigene Änderungen anzeigen
git diff HEAD -- src/datei.ts

# Änderungen des anderen Branches
git diff MERGE_HEAD -- src/datei.ts

# Nach manuellem Fix:
git add src/datei.ts
git commit
```

**Nicht gleich abbrechen!** Einfach fixen und `git add` + `git commit` — kein `--abort` nötig.

---

## 3. `git reset --hard` — und jetzt?

```bash
git reflog
# → zeigt alle HEAD-Wechsel der letzten 90 Tage
git checkout <commit-hash> -- .
# oder direkt:
git reset --hard <commit-hash>
```

**Kein Commit ist wirklich weg** — der Reflog ist dein Rettungsanker.

---

## 4. Auf den falschen Remote gepusht

```bash
git push --force-with-lease origin +main
# checkt vorher ob der Remote-stand noch aktuell ist
```

**Nie `--force` ohne `--with-lease`!** Sonst überschreibst du ggf. die Arbeit anderer.

---

## 5. Detached HEAD — "Wo bin ich?"

```bash
# Ist-Zustand sichern
git checkout -b rettungs-branch
# oder (neuere Syntax):
git switch -c rettungs-branch

# Jetzt wieder auf einem Branch — push möglich!
```

---

## 6. Einen alten Commit nachträglich ändern

```bash
git rebase -i HEAD~5
# "pick" → "edit" für den zu ändernden Commit
# Datei fixen, dann:
git add <file>
git commit --amend
git rebase --continue

# Bei Fehlern:
git rebase --abort
```

**Niemals Commits rebasen die schon gepusht und von anderen gezogen wurden!**

---

## 7. Merge vs. Rebase

```bash
# Sauberer Pull ohne Merge-Commits
git pull --rebase

# Global aktivieren:
git config --global pull.rebase true
```

| Merge | Rebase |
|---|---|
| Shared Branches (main, dev) | Private Feature-Branches |
| Vor PR-Merge (sichtbare History) | Vor erstem Push (saubere History) |
| Wenn Zeitpunkte wichtig sind | Wenn lineare History gewünscht |
