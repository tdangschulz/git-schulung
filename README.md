# Git-Spickzettel 🚀

Kompakte Befehlsreferenz für den Git-Workshop — mit Erklärungen zum Vorlesen.

> **Trainerleitfaden** mit allen Live-Demos → [`TRAINER.md`](TRAINER.md)
> **Demoprojekte** → [`demos/`](demos/) — `bash setup-demos.sh` zum Entpacken

---

## 🏁 Grundlagen

### Repo erstellen

| Befehl | Erklärung |
|---|---|
| `git init` | **Macht aus einem Ordner ein Git-Repo.** Erzeugt den unsichtbaren `.git`-Ordner. Ab jetzt überwacht Git jede Änderung. |
| `git clone <url>` | **kopiert ein komplettes Repo** inklusive ganzer History. Wie "Fork" bei GitHub, nur lokal. |

### Der Git-Workflow (immer gleich!)

```
Arbeitsverzeichnis  →  git add  →  Staging (grüne Zone)  →  git commit  →  Repository
     (Dateien bearbeiten)                                    (fester Snapshot)

git status          git add           git commit -m "..."
git diff            git restore --staged
```

### Status & Änderungen

| Befehl | Erklärung |
|---|---|
| `git status` | **Zeigt was los ist.** Rote Dateien = ungetrackt/ungeändert. Grüne Dateien = bereit zum Commit. Erster Befehl den man immer eingibt! |
| `git diff` | **Zeigt ungestagte Änderungen** zeilenweise. Was ist anders, aber noch nicht in der grünen Zone? |
| `git diff --staged` | **Zeigt gestagte Änderungen** (was wird mit dem nächsten Commit kommen). |
| `git add <datei>` | **Nimmt Datei in die grüne Zone** (Staging). Erst danach "weiß" Git von der Datei. |
| `git add .` | **Nimmt ALLE Dateien** im aktuellen Ordner in die grüne Zone. Praktisch, aber Vorsicht: auch ungewollte Dateien! |
| `git add -p` | **Interaktives Staging.** Zeigt jede Änderung einzeln. `y` = ja, `n` = nein, `s` = splitten. Perfekt für atomare Commits! |
| `git commit -m "..."` | **Macht einen festen Snapshot.** Der Text in `-m` beschreibt WAS geändert wurde. |
| `git commit --amend` | **Erweitert den letzten Commit** (anstatt einen neuen zu machen). Achtung: überschreibt History — nie bei gepushten Commits! |
| `git restore <datei>` | **Macht ungestagte Änderungen rückgängig** — Datei ist wieder wie im letzten Commit. |
| `git restore --staged <datei>` | **Nimmt Datei aus der grünen Zone** (unstage), aber Änderungen bleiben erhalten. |

### Log & History

| Befehl | Erklärung |
|---|---|
| `git log` | **Zeigt die Commit-Historie** (Autor, Datum, Hash, Nachricht). |
| `git log --oneline` | **Kompakte History** — jeder Commit nur eine Zeile mit kurzem Hash. |
| `git log --oneline --graph` | **History als ASCII-Grafik** mit Verbindungslinien zwischen Branches. |
| `git log --oneline --graph --all` | **Alle Branches** in der Grafik, nicht nur den aktuellen. |
| `git reflog` | **Rettungsanker!** Zeigt ALLE HEAD-Wechsel der letzten 90 Tage. Auch verlorene Commits findet man hier. |

---

## 🌿 Branches

### Branches verwalten

| Befehl | Erklärung |
|---|---|
| `git branch` | **Listet alle lokalen Branches.** Der aktuelle hat ein `*` davor. |
| `git branch -a` | **Listet ALLE Branches** (lokal + remote). |
| `git switch -c <name>` | **Erstellt NEUEN Branch und wechselt sofort dahin.** Wie `git branch <name>` + `git switch <name>` in einem. |
| `git switch <name>` | **Wechselt zu einem existierenden Branch.** |
| `git branch -d <name>` | **Löscht Branch lokal.** Nur wenn er schon gemergt wurde. |
| `git branch -D <name>` | **Löscht Branch mit Gewalt** (auch wenn ungemergt). Vorsicht! |

**Wichtig zu verstehen:** Ein Branch ist NUR ein Zeiger auf einen Commit. Wenn man `git switch -c feature/xyz` macht, erstellt man einen neuen Zeiger auf den aktuellen Commit. Beide Zeiger zeigen erstmal auf denselben Punkt.

### Merge

| Befehl | Erklärung |
|---|---|
| `git merge <branch>` | **Führt einen Branch in den aktuellen ein.** |
| `git merge --no-ff <branch>` | **Erzwingt Merge-Commit** (auch wenn Fast-Forward möglich wäre). Wichtig für sichtbare Feature-Merges in der History. |
| `git merge --squash <branch>` | **Zerquetscht alle Commits des Branches in EINEN Commit.** Nützlich für kleine Fixes, die keinen eigenen Branch-Zweig brauchen. |
| `git merge --ff-only <branch>` | **Nur wenn Fast-Forward möglich.** Sonst Abbruch. Für lineare History auf main. |
| `git merge --abort` | **Bricht den Merge ab** — alles ist wie vorher. |

**Merge-Strategien:**
- `git merge -Xours <branch>` — Bei Konflikt automatisch UNSERE Version nehmen
- `git merge -Xtheirs <branch>` — Bei Konflikt automatisch DEREN Version nehmen

### Merge-Konflikte lösen

```bash
# Konflikt-Markierungen in der Datei:
<<<<<<< HEAD        # UNSERE Version (aktueller Branch)
                    # ...
=======             # Trennung
                    # ...
>>>>>>> feature/xyz # DEREN Version (der andere Branch)

# Nach manuellem Fix:
git add <datei>     # Konflikt als gelöst markieren
git commit          # Merge-Commit abschließen (Nachricht steht schon)
```

**diff3** (empfohlen!):
```bash
git config --global merge.conflictstyle diff3
# Zeigt zusätzlich den gemeinsamen Vorfahren:
# <<<<<< | |||||| ANCESTOR | ====== | >>>>>>
# Das macht die Entscheidung VIEL einfacher!
```

---

## 🔄 Rebase vs. Merge

### Was ist Rebase?

`git rebase <ziel>` = **"Schneide meine Commits aus, hol den Ziel-Branch nach vorne, klebe meine Commits wieder drauf."**

```bash
git switch feature/neu
git rebase main

# Ergebnis: feature/neu hängt jetzt an der Spitze von main
# Die Feature-Commits haben NEUE Hashes (wurden neu geschrieben)
# = lineare Historie, kein Merge-Commit
```

### ⚠️ GOLDENE REGEL

| ✅ Darf rebased werden | ❌ Darf NICHT rebased werden |
|---|---|
| Private, ungepushte Feature-Branches | Öffentliche/shared Branches (main, dev) |
| Eigene Arbeit vor dem Push | Branches an denen andere auch arbeiten |
| Lokale Feature-Branches | Bereits gepushte und gezogene Commits |

**Warum?** Rebase schreibt Commits um (neue Hashes). Wenn andere auf den alten Commits aufbauen, entsteht Chaos.

### Merge vs. Rebase — der Unterschied

```bash
# MERGE: Bewahrt die Branch-Struktur
git switch main
git merge feature/neu
# → Merge-Commit mit 2 Eltern sichtbar

# REBASE: Lineare History
git switch feature/neu
git rebase main
git switch main
git merge feature/neu   # Fast-Forward (weil feature schon hinter main hängt)
# → Kein Merge-Commit, lineare History
```

| | Merge | Rebase |
|---|---|---|
| **Historie** | Zeigt echte Branch-Struktur | Sauber, linear |
| **Sicherheit** | Verändert keine Commits | Schreibt Commits um |
| **Wann?** | Shared Branches, Releases, PRs | Private Branches, vor dem Push |

---

## 🗂️ Stash — Arbeit weglegen

| Befehl | Erklärung |
|---|---|
| `git stash` | **Packt unfertige Änderungen auf den Stash-Stack.** Arbeitsverzeichnis wird sauber (wie frisch committed). Nur getrackte Dateien. |
| `git stash -u` | **Wie stash, aber auch neue/ungetrackte Dateien.** `-u` = "untracked". |
| `git stash list` | **Zeigt alle gespeicherten Stash-Einträge.** Format: `stash@{0}: WIP on branch...` |
| `git stash pop` | **Holt den neuesten Stash zurück UND löscht ihn vom Stack.** |
| `git stash apply` | **Holt Stash zurück, LÄSST ihn aber auf dem Stack.** Für mehrere Branches. |

---

## 🏷️ Tags

| Befehl | Erklärung |
|---|---|
| `git tag` | **Listet alle Tags.** |
| `git tag -l "v1.0*"` | **Listet Tags mit Filter** (Pattern). |
| `git tag -a v1.0.0 -m "..."` | **Erstellt annotierten Tag** (mit Autor + Datum + Nachricht). Für Releases nehmen! |
| `git tag v1.0.0` | **Erstellt Lightweight-Tag** (nur Zeiger). Für private Markierungen. |
| `git push origin --tags` | **Pusht ALLE Tags** zum Remote. |

**Tag vs. Branch:** Tags sind wie Branches, die sich nie bewegen. `git checkout <tag>` = Detached HEAD (nur lesen, nicht committen!).

---

## ☁️ Remote (GitHub/GitLab)

| Befehl | Erklärung |
|---|---|
| `git remote -v` | **Zeigt alle Remotes** (meist `origin`). |
| `git remote add origin <url>` | **Fügt Remote hinzu.** `origin` ist der Standard-Name für GitHub/GitLab. |
| `git clone <url>` | **Klont ein Repo inklusive Remote** — `origin` ist automatisch gesetzt. |
| `git push origin main` | **Lädt main zum Remote hoch.** |
| `git pull origin main` | **Holt Änderungen vom Remote** (fetch + merge in einem). |
| `git pull --rebase origin main` | **Holt Änderungen mit Rebase statt Merge.** Sauberer, kein extra Merge-Commit. |
| `git fetch` | **Holt nur Infos über neue Branches/Commits**, ohne zu mergen. |
| `git push -u origin <branch>` | **Pusht + setzt upstream.** `-u` = nächstes Mal reicht `git push`. |
| `git push origin -d <branch>` | **Löscht Branch auf dem Remote.** |
| `git push --force-with-lease` | **Erzwungener Push mit Sicherheitscheck.** Besser als `--force`! Prüft ob jemand zwischendrin gepusht hat. |

---

## 🧰 Fortgeschritten

| Befehl | Erklärung |
|---|---|
| `git rebase -i HEAD~5` | **Interaktives Rebase.** Commits umsortieren, squashen, umbenennen. Vorsicht: schreibt History um! |
| `git cherry-pick <hash>` | **Holt einen bestimmten Commit in den aktuellen Branch.** Ohne den ganzen Branch zu mergen. |
| `git bisect start` | **Binäre Fehlersuche.** Markiert Commits als "good/bad" bis der Schuldige gefunden ist. |
| `git bisect good/bad` | **Markiert aktuellen Commit.** Git springt automatisch in die Mitte des verdächtigen Bereichs. |
| `git bisect reset` | **Beendet bisect-Modus.** |
| `git config rerere.enabled true` | **Reuse Recorded Resolution.** Git merkt sich, wie du Konflikte gelöst hast und wendet die Lösung automatisch wieder an. |
| `git config --global pull.rebase true` | **Immer `git pull --rebase` statt `git pull`.** Vermeidet unnötige Merge-Commits. |
| `git config --global merge.conflictstyle diff3` | **diff3-Konfliktstil aktivieren.** Zeigt den gemeinsamen Vorfahren — viel leichter zu lösen! |
| `git config --global user.name "..."` | **Setzt den Commit-Namen** (global für alle Repos). |
| `git config --global user.email "..."` | **Setzt die Commit-Email.** |

## 📝 Gute Commit-Nachrichten

```
Zeile 1: Betreff (Subject) — max. 50 Zeichen, Imperativ
         "Add" nicht "Added", "Fix" nicht "Fixed"

Leerzeile (wichtig!)

Zeile 3+: Body — WARUM wurde geändert (nicht WAS)
           WAS sieht man im Diff. WARUM steht im Body.

Optional: Footer mit Issue-ID
           Related to #F1337
```

**Beispiele:**
- ❌ `update` (sagt nichts)
- ❌ `fix bug` (welcher Bug?)
- ❌ `changes` (welche?)
- ✅ `Add JWT-based authentication`
- ✅ `Fix memory leak in websocket handler`
- ✅ `Remove deprecated login endpoint`

---

## 🎯 Kurz vor dem Push — Check

```bash
git status              # Was ist los?
git log --oneline --graph --all  # History-Check
git diff                # Sind die richtigen Änderungen drin?
git pull --rebase       # Aktuellster Stand?
git push                # Raus damit!
```
