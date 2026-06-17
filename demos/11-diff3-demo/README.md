## Schnellstart

```bash
# Auspacken
cd /tmp
tar xzf pfad/zu/start.tar.gz
cd start

# Status: theme.txt auf main = sepia, feature/dark = dark
# Merge führt sofort zum Konflikt in theme.txt
# Erster Befehl: Merge mit Konflikt
git merge feature/dark || true
cat theme.txt
# Dann diff3-Ansicht aktivieren:
git checkout --conflict=diff3 theme.txt
```

# diff3-Konfliktstil

Mit diff3 sieht man beim Konflikt auch den gemeinsamen Vorfahren — das macht die Lösung leichter.

Start: `theme.txt` mit drei Zeilen.

## Befehlsablauf

1. **Initial-Commit**
   `git init && git add theme.txt && git commit -m "Initial theme"`

2. **Feature-Branch: Dark Mode**
   `git switch -c feature/dark`
   `sed -i 's/background = white/background = black/' theme.txt`
   `git add . && git commit -m "Dark mode"`

3. **Main: Sepia Mode**
   `git switch main`
   `sed -i 's/background = white/background = sepia/' theme.txt`
   `git add . && git commit -m "Sepia mode"`

4. **Merge → Konflikt**
   `git merge feature/dark || true`
   `cat theme.txt`
   → Siehst du nur `<<<<<<<`, `=======`, `>>>>>>>`?

5. **Mit diff3 sieht man den Vorfahren**
   `git checkout --conflict=diff3 theme.txt`
   `cat theme.txt`
   → Jetzt siehst du zusätzlich `|||||||` mit "background = white" — dem gemeinsamen Ausgangspunkt!

6. **Konflikt lösen**
   Entscheide dich für eine Farbe oder mach einen Kompromiss (z.B. "purple").
   `git add theme.txt && git commit --no-edit`

7. **Global aktivieren** (damit man's nie wieder vergisst)
   `git config --global merge.conflictstyle diff3`
