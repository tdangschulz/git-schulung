## Schnellstart

```bash
# Auspacken
cd /tmp
tar xzf pfad/zu/start.tar.gz
cd start

# Status: README.md bereits committet, Arbeitsverzeichnis sauber
# Erster Befehl: Datei bearbeiten und neuen Commit machen
echo "Zweite Zeile" >> README.md
git diff
git add . && git commit -m "Zweite Zeile hinzugefügt"
```

# Hallo Git

Diese Datei dient als erster Einstieg in den Git-Workflow.

## Befehlsablauf

1. **Repo initialisieren**
   `git init`

2. **Status prüfen**
   `git status` — siehst du die rote README.md?

3. **Datei stagen**
   `git add README.md` — danach nochmal `git status`

4. **Ersten Commit machen**
   `git commit -m "Initial commit"`

5. **README erweitern**
   Hänge eine zweite Zeile an: `echo "Zweite Zeile" >> README.md`

6. **Änderung ansehen**
   `git diff` — zeigt was anders ist (noch ungestaged)

7. **Stagen und committen**
   `git add . && git commit -m "Zweite Zeile hinzugefügt"`

8. **History anzeigen**
   `git log --oneline --graph`

## ⚠️ Typische Praxisprobleme

**❗ Vim-Falle:** Nach \`git commit\` ohne \`-m\` öffnet sich Vim.
→ \`:wq\` zum Speichern + Schließen. Oder: \`git config --global core.editor "nano"\`

**❗ Git add vergessen:** \`git status\` zeigt rote Dateien — die sind NICHT im Commit!
→ Erst \`git add .\` (oder gezielt \`git add datei.txt\`), dann \`git commit\`

**❗ Commit-Nachricht zu knapp:** \`git commit -m "update"\` sagt nichts.
→ Besser: \`git commit -m "Add login functionality"\`
