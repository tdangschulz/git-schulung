# Git Advanced – Erweiterte Themen

> **Voraussetzung:** Git-Grundlagen sicher beherrschen (init, add, commit, branch, merge, rebase)

---

## 1. Interactive Rebase – Geschichte umschreiben

Der mächtigste (und gefährlichste) Rebase-Modus: Du kannst Commits sortieren, löschen, zusammenfassen und umbenennen.

```bash
# Letzte 3 Commits bearbeiten
git rebase -i HEAD~3

# Es öffnet sich ein Editor mit:
# pick abc1234 Erster Commit
# pick def5678 Zweiter Commit
# pick ghi9012 Dritter Commit

# Mögliche Aktionen:
# pick    = Commit behalten (default)
# reword  = Commit-Nachricht ändern
# edit    = Commit-Inhalt ändern
# squash  = Mit vorherigem Commit zusammenführen
# fixup   = Wie squash, aber Nachricht verwerfen
# drop    = Commit löschen
# exec    = Shell-Befehl ausführen
```

**Praktisches Beispiel – Drei "WIP"-Commits zu einem sauberen machen:**

```bash
# Vorher:
pick abc123 WIP: angefangen
pick def456 WIP: weiter
pick ghi789 WIP: fertig

# Nach Änderung:
pick abc123 WIP: angefangen
squash def456 WIP: weiter        # wird mit abc123 gemergt
squash ghi789 WIP: fertig        # wird auch mit abc123 gemergt

# Ergebnis: Ein einziger Commit "WIP: angefangen"
```

**⚠️ Wichtig:** `rebase -i` schreibt History um → nie auf bereits gepushten Branches anwenden (oder nur mit `--force` und Absprache mit dem Team)!

---

## 2. Git Bisect – Den Schuldigen finden

Binäre Suche durch die Commit-Historie, um den Commit zu finden, der einen Bug eingeführt hat.

```bash
# Start: guter Commit bekannt (z.B. v1.0)
git bisect start
git bisect bad HEAD                # aktueller Commit ist kaputt
git bisect good v1.0               # v1.0 war noch gut

# Git checked jetzt einen mittleren Commit aus
# Du testest: ist der Bug hier?
git bisect good                    # wenn Bug nicht da
git bisect bad                     # wenn Bug da ist

# Nach ~log2(n) Schritten wird der schuldige Commit gefunden:
# abc1234 is the first bad commit

# Beenden:
git bisect reset
```

**Automatisiert mit Skript:**
```bash
git bisect start HEAD v1.0
git bisect run npm test            # Führt Tests aus, bis fehlschlägt
git bisect reset
```

---

## 3. Git Reflog – Die Rettungsleine

Das Reflog ist dein Rettungsnetz. Es protokolliert ALLE Aktionen (auch verlorene Commits).

```bash
# Reflog anzeigen
git reflog
# abc1234 HEAD@{0}: commit: Mein Commit
# def5678 HEAD@{1}: reset: moving to HEAD~1
# ghi9012 HEAD@{2}: commit: Falscher Commit (gelöscht!)
# ...

# Wiederherstellen nach git reset --hard
git reset --hard HEAD~2            # Ups, zu weit zurück!
git reflog                         # Hash von vor dem Reset finden
git reset --hard abc1234           # Wieder da!

# Wiederherstellen nach gelöschtem Branch
git branch -D feature/alt          # Gelöscht!
git reflog                         # Letzten Commit-Hash finden
git checkout -b feature/alt abc1234  # Branch wiederhergestellt
```

**Reflog vs Log:**
- `git log` = öffentliche Historie (wird mitgepusht)
- `git reflog` = deine private History (nur lokal, nie gepusht)

**Wichtig:** Reflog läuft nach ~90 Tagen ab (konfigurierbar mit `gc.reflogExpire`).

---

## 4. Git Hooks – Automatisierung

Hooks sind Skripte, die bei bestimmten Git-Aktionen automatisch ausgeführt werden.

```bash
# Hooks liegen in: .git/hooks/
ls -la .git/hooks/
# Beispiele: pre-commit.sample, pre-push.sample, post-merge.sample ...

# Eigenen Pre-Commit-Hook (prüft z.B. auf Debug-Logs)
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/sh
if git diff --cached | grep -q "console.log"; then
  echo "❌ Kein console.log im Commit erlaubt!"
  exit 1
fi
EOF
chmod +x .git/hooks/pre-commit
```

**Wichtige Hooks:**

| Hook | Wann | Nutzen |
|---|---|---|
| `pre-commit` | Vor jedem Commit | Linter, Tests, Secrets-Scanner |
| `prepare-commit-msg` | Commit-Message wird erstellt | Issue-Nummer einfügen |
| `pre-push` | Vor `git push` | Tests laufen lassen |
| `post-merge` | Nach `git pull` | Abhängigkeiten aktualisieren |
| `post-commit` | Nach jedem Commit | Benachrichtigung, Logging |

**Team-Weit:** Hooks können nicht direkt gepusht werden (Sicherheit). Lösung: Hook-Skripte im Repo unter `.githooks/` ablegen und per `git config core.hooksPath .githooks` aktivieren.

**Fertige Hook-Sammlungen:** `husky` (npm), `pre-commit` (Python)

---

## 5. Git Worktrees – Mehrere Branches gleichzeitig

Arbeite an mehreren Branches parallel, ohne zu stashen oder zu switchen.

```bash
# Neues Worktree für Feature-Branch
git worktree add ../feature-login feature/login
# => ../feature-login/ hat den feature/login ausgecheckt

# Worktrees auflisten
git worktree list
# /projekt/main        abc123 [main]
# /projekt/../feature-login  def456 [feature/login]

# Fertiges Worktree entfernen
git worktree remove ../feature-login

# Aufräumen (verwaiste Worktrees)
git worktree prune
```

**Wann sinnvoll:**
- An zwei Features gleichzeitig arbeiten
- Schnell mal einen Bugfix im alten Release-Branch machen
- Code-Review mit Auschecken des PR-Branches

---

## 6. Cherry-Pick für Serien von Commits

```bash
# Bereich von Commits cherry-picken (exklusive abc, inklusive def)
git cherry-pick abc1234..def5678

# Mit Konfliktverhalten
git cherry-pick --strategy=recursive -X theirs abc1234
git cherry-pick --no-commit abc1234    # Änderungen nur stagen, nicht committen
```

---

## 7. Git Blame – Wer war's?

```bash
# Zeilenweise Autoren anzeigen
git blame README.md
git blame -L 10,20 README.md    # Nur Zeilen 10-20

# Mit Emails statt Namen
git blame -e README.md

# Änderungen vor einem bestimmten Datum ignorieren
git blame --ignore-rev abc1234 README.md

# Aufwändige Zeilen ignorieren (Whitespace, Refactoring)
git blame -w README.md
```

---

## 8. Git Grep & Log -S – Schnellsuche

```bash
# In Dateien suchen (wie grep)
git grep "TODO"                    # Alle Dateien mit TODO
git grep -n "function" -- "*.js"   # Nur JS-Dateien mit Zeilennummern

# In Commit-Nachrichten suchen
git log --grep="Bugfix"

# In Diffs suchen (wann wurde eine Funktion eingeführt/entfernt?)
git log -S "getUser()" --oneline   # Alle Commits, die getUser() betreffen
git log -G "getUser" --oneline     # Wie -S, aber regex-basiert

# Inhalt bestimmten Commits anzeigen
git show abc1234                   # Kompletter Diff des Commits
git show abc1234:README.md         # README.md so, wie in dem Commit
```

---

## 9. Signed Commits – Integrität nachweisen

```bash
# GPG-Key generieren (einmalig)
gpg --full-generate-key
gpg --list-secret-keys --keyid-format LONG
git config --global user.signingkey ABCDEF1234567890

# Commit signieren
git commit -S -m "Signierter Commit"

# Auto-Sign aktivieren
git config --global commit.gpgsign true

# Tag signieren
git tag -s v1.0 -m "Release 1.0"

# Signatur prüfen
git verify-commit abc1234
git verify-tag v1.0
```

---

## 10. Git Rerere – Nie wieder gleiche Konflikte

`rerere` = "REuse REcorded REsolution" – merkt sich, wie du Konflikte gelöst hast.

```bash
# Aktivieren
git config --global rerere.enabled true

# Nur für dieses Repo
git config rerere.enabled true

# Funktioniert dann automatisch: Gleicher Konflikt → gleiche Lösung
# Nützlich bei: Rebase, Cherry-Pick, Merge-Workflows

# Status prüfen
git rerere status
git rerere diff
```

---

## 11. Merge-Strategien im Detail

```bash
# Default: recursive (3-Way-Merge)
git merge feature/login

# ours – einfach unsere Version behalten
git merge -s ours feature/experiment

# subtree – Teilbaum mergen (z.B. Unterprojekt)
git merge -s subtree feature/subprojekt

# octopus – mehrere Branches gleichzeitig
git merge feature/a feature/b feature/c

# ours/x theirs bei Konflikten
git merge -X theirs feature/login    # Bei Konflikten deren Version nehmen
git merge -X ours feature/login      # Bei Konflikten unsere Version nehmen
```

---

## 12. Submodules – Repos in Repos

```bash
# Submodul hinzufügen
git submodule add https://github.com/beispiel/lib.git lib/
git commit -m "Lib als Submodul hinzugefügt"

# Repo mit Submoduls klonen
git clone --recursive https://github.com/.../projekt.git

# Submoduls updaten
git submodule update --init --recursive

# Submodul in neuem Commit bringen
cd lib/
git checkout v2.0
cd ..
git add lib/
git commit -m "Lib auf v2.0 geupdated"
```

**⚠️ Nachteile:** Komplexität, "Dangling References" (Submodul-Repo nicht erreichbar).

**Alternative:** Git Subtree – integriert den Code direkt (kein separater Clone, aber größeres Repo).

---

## 13. Git LFS – Large File Storage

Für Binärdateien, die nicht in Git gehören (Bilder, Videos, ZIPs, Modelle).

```bash
# Installation
git lfs install

# Dateitypen tracken
git lfs track "*.psd"
git lfs track "*.zip"
git lfs track "*.stl"

# .gitattributes wird automatisch aktualisiert
git add .gitattributes

# Normal weitermachen
git add bild.psd
git commit -m "Design-Datei hinzugefügt"
# Die Datei wird als Pointer in Git gespeichert, der Inhalt auf LFS-Server
```

**Grenzen:** GitHub LFS ist kostenpflichtig ab 1 GB Speicher / 1 GB Monats-download.

---

## 14. Git Attributes & Merge-Strategien pro Datei

```bash
# .gitattributes – pro Datei/Muster
cat > .gitattributes << 'EOF'
# Text vs Binary
*.json   text
*.png    binary
*.stl    -text diff=lfs

# Merge-Strategie pro Datei
config.json   merge=union         # Bei Konflikt: beide Versionen
passwörter    merge=ours          # Immer unsere Version
EOF

git add .gitattributes
git commit -m "Git-Attributes definiert"
```

---

## 15. CI/CD mit Git – GitHub Actions

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Alle Commits für git log
      - run: npm install
      - run: npm test

  # Automatischer Merge von develop → main
  deploy:
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: echo "Deploying..."
```

---

## 16. Trunk-Based Development vs Git Flow

### Git Flow (klassisch)
```
main ───●──────●──────────────●──────────
          \                /
develop    ●──●──●────●──●──
                  \    /
feature          ●──●
```

**Vorteile:** Klar strukturiert, gute Trennung, Releases nachvollziehbar.
**Nachteile:** Komplex, viele Branches, Merge-Hölle.

### Trunk-Based Development (modern)
```
main ──●──●──●──●──●──●──●──●──●──
        \  /      \  /      \  /
feature ●─●       ●─●       ●─●
```

**Regeln:**
- Feature-Branches leben max. 1-2 Tage
- Kleine, häufige Commits
- Feature Flags statt Feature-Branches
- Automatisierte Tests als Qualitätssicherung

**Vorteile:** Weniger Merge-Konflikte, schnelleres Feedback, Continuous Deployment.
**Nachteile:** Disziplin nötig, Feature Flags erhöhen Komplexität.

---

## 17. Git Tricks & Tastenkombinationen

```bash
# Aliase (Zeitsparer)
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.lg "log --oneline --graph --all --decorate"
git config --global alias.undo "reset --soft HEAD~1"
git config --global alias.last "log -1 HEAD"
git config --global alias.unstage "reset HEAD --"

# Danach: git lg statt git log --oneline --graph --all --decorate

# Letzten Commit korrigieren (wenn noch nicht gepusht)
git commit --amend -m "Neue Message"         # Nachricht ändern
git commit --amend --no-edit                  # Dateien vergessen? Add + amend

# Aktuellen Branch-Namen im Prompt (für bash)
export PS1='\u@\h \[\e[32m\]$(git branch 2>/dev/null | grep "^*" | colrm 1 2)\[\e[0m\] \w\$ '

# Schnellster Weg zum Log
git lg                                      # Wenn Alias gesetzt

# Branch nach Push löschen
git push origin --delete feature/alt        # Remote
git branch -d feature/alt                   # Lokal

# Größe des Repos prüfen
git count-objects -vH

# Merge-Info eines Commits anzeigen
git show --format=%p abc1234                # Parent-Commits anzeigen
```

---

## Abschluss: Die 10 Goldenen Git-Regeln

1. **Committe früh, committe oft** – kleine, logische Einheiten
2. **Schreib gute Commit-Messages** – "Was" in der Betreffzeile, "Warum" im Body
3. **Nie auf main pushen** – immer Branches + PRs
4. **Nie `--force` auf shared Branches** – außer du hast abgesprochen
5. **`git pull --rebase` statt `git pull`** – sauberere Historie
6. **Rebase vor dem Push, Merge vor dem Pull** – Team-Regel
7. **Ein Feature = Ein Branch** – nicht mehrere Features in einem Branch
8. **Lösche gemergte Branches** – hält das Repo sauber
9. **Schreib `.gitignore` vor dem ersten Commit** – keine versehentlichen Credentials
10. **`git reflog` ist dein Freund** – fast nichts ist wirklich weg
