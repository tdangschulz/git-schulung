# Git-Schulung — Demos

15 interaktive Live-Demos für den Git-Workshop.

## Setup

```bash
# Nach dem Klonen: Einmalig alle Demos entpacken
bash setup-demos.sh
```

Damit werden alle `start.tar.gz` Archive entpackt. Du bekommst pro Demo
einen `start/` Ordner mit fertigem Git-Repo (.git inklusive).

## Aufräumen

```bash
bash cleanup-demos.sh   # Entfernt alle start/ Ordner
bash setup-demos.sh     # Frisch entpacken
```

## Demo-Übersicht

| #  | Demo | Was lernst du? | Erster Befehl |
|----|------|----------------|---------------|
| 01 | Recap | Git-Workflow (add, commit, log) | `echo "Zweite Zeile" >> README.md` |
| 02 | Galaktische Pizza | Branches, Fast-Forward, 3-Way Merge | `git switch -c feature/menu` |
| 03 | Rebase | Rebase vs. Merge, History umschreiben | `git switch -c feature/neu` |
| 04 | Golden Rule | Warum Force-Push auf shared Branches böse ist | `cd /tmp/dev-a` |
| 05 | Central Workflow | Team-Konflikte + pull --rebase | `echo "Zeile von Dev A" >> datei.txt` |
| 06 | Feature Workflow | Feature-Branches + --no-ff | `git switch -c feature/dark-mode` |
| 07 | Gitflow | develop, release, hotfix Zyklus | `git switch -c feature/login` |
| 08 | Commit Style | Gute Commit-Nachrichten + add -p | Dateien selbst erstellen |
| 09 | Merge-Strategien | --no-ff vs --squash vs --ff-only | `git merge --no-ff feature/moin` |
| 10 | Merge-Konflikt | Konflikt provozieren + lösen | `git merge feature/change-color` |
| 11 | diff3 | Konflikte mit Vorfahren-Ansicht | `git merge feature/dark` |
| 12 | Rerere | Automatische Konfliktlösung | `git merge feature/v2` |
| 13 | Trunk | Feature-Flags statt Branches | Code in app.py einfügen |
| 14 | Git Hooks | Client-seitige Hooks (pre-commit, commit-msg, pre-push) | `bash scripts/install-hooks.sh`
| 15 | Git Internals | .git-Ordner, Objekte, Three Trees, Reflog | `cat .git/HEAD`

## Tipp für Live-Demos

Immer zuerst einen Blick in die History werfen:
```bash
cd demos/10-conflict-demo/start
git log --oneline --graph --all
```

So siehst du sofort: "Aha, hier sind die Branches schon auseinander gezweigt!"
