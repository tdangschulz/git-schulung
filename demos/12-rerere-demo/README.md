## Schnellstart

```bash
# Auspacken
cd /tmp
tar xzf pfad/zu/start.tar.gz
cd start

# Status: version.txt auf main = "version = 1.5", feature/v2 = "version = 2.0"
# Merge führt zum Konflikt — perfekt zum Üben von rerere
# Erster Befehl: rerere aktivieren und merge
git config rerere.enabled true
git merge feature/v2
```

# ReReRe (Reuse Recorded Resolution)

Git kann sich gemerkte Konfliktlösungen automatisch wieder anwenden.
Perfekt für wiederkehrende Merge-Konflikte (z.B. Changelogs, Versionsnummern).

Der Ordner ist leer — der Trainer erstellt die Dateien live.

## Übungsaufgaben

1. **Repo initialisieren**
   `git init`

2. **Rerere aktivieren**
   `git config rerere.enabled true`
   (Oder global: `git config --global rerere.enabled true`)

3. **Start-Datei**
   ```bash
   echo "version = 1.0" > version.txt
   echo "author = Team" >> version.txt
   git add . && git commit -m "Initial"
   ```

4. **Feature-Branch: Version erhöhen**
   `git switch -c feature/v2`
   `echo "version = 2.0" > version.txt`
   `echo "author = Team" >> version.txt`
   `git add . && git commit -m "Bump version to 2.0"`

5. **Main: Auch Version erhöht**
   `git switch main`
   `echo "version = 1.5" > version.txt`
   `echo "author = Team" >> version.txt`
   `git add . && git commit -m "Bump version to 1.5"`

6. **Erster Merge → Konflikt lösen**
   `git merge feature/v2 || true`
   `cat version.txt` — siehst du den Konflikt?
   Löse ihn: `echo "version = 2.0" > version.txt && echo "author = Team" >> version.txt`
   `git add version.txt`
   `git merge --continue` (oder `git commit --no-edit`)
   → Rerere hat sich die Lösung jetzt gemerkt!

7. **Reset und nochmal — jetzt automatisch**
   `git reset --hard HEAD~1`
   `git merge feature/v2`
   → Rerere wendet die gemerkte Lösung automatisch an! Kein manuelles Eingreifen nötig.
