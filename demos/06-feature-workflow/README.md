## Schnellstart

```bash
# Auspacken
cd /tmp
tar xzf pfad/zu/start.tar.gz
cd start

# Status: README.md mit "main", auf main, Remote zeigt auf ../central.git
# central.git existiert im selben Ordner wie start/
# Erster Befehl: Feature-Branch anlegen
git switch -c feature/dark-mode
```

# Feature Branch Workflow

Demo des Feature-Branch-Workflows mit Pull Requests.

Start: main enthält `README.md` mit "main".

## Befehlsablauf

1. **Initial-Commit**
   `git init && git add README.md && git commit -m "Initial"`
   `git push` (nachdem du ein Remote konfiguriert hast)

2. **Feature-Branch für Dark Mode**
   `git switch -c feature/dark-mode`

3. **Dark Mode CSS erstellen**
   `echo "body.dark-mode { background: #222; color: #fff; }" > dark.css`
   `git add . && git commit -m "Add dark mode stylesheet"`
   `git push origin feature/dark-mode`

4. **PR simulieren**
   Wechsel zurück zu main: `git switch main`
   Merge mit `--no-ff`: `git merge --no-ff feature/dark-mode -m "Merge PR #1: Dark Mode"`

5. **Branch aufräumen**
   `git branch -d feature/dark-mode`

6. **Übung: Zweites Feature mit Konflikt**
   `git switch -c feature/header-fix`
   Ändere im `index.html` die Überschrift (sofern vorhanden) oder füge eine Zeile in `style.css` hinzu.
   Merges mit `--no-ff` in main.

## ⚠️ Typische Praxisprobleme

**❗ --no-ff vergessen:** Feature-Branch per Fast-Forward gemergt — kein Merge-Commit.
→ Für Features/PRs immer \`--no-ff\`, sonst sieht man nicht was zusammengehört.

**❗ Branch nach Merge nicht gelöscht:** Alte Branches sammeln sich.
→ \`git branch -d feature/alt\` (lokal) + \`git push origin -d feature/alt\` (remote).

**❗ Feature-Branch nie gemergt:** Arbeit fertig, aber PR hängt seit Wochen.
→ Kleine, schnelle PRs. Lieber 5 kleine Branches als ein Riesen-Feature.
