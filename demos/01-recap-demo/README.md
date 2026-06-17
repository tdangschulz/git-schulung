# Hallo Git

Diese Datei dient als erster Einstieg in den Git-Workflow.

## Übungsaufgaben

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
