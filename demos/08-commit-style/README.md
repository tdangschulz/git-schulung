## Schnellstart

```bash
# Auspacken
cd /tmp
tar xzf pfad/zu/start.tar.gz
cd start

# Status: Leeres Repo (nur initialer Empty-Commit "Start")
# Erster Befehl: Status prüfen
git status
```

# Commit Style

Demo für gute Commit-Konventionen und sinnvolle Commit-Größen.

Der Ordner ist leer — der Trainer erstellt die Dateien live.

## Befehlsablauf

1. **Repo initialisieren**
   `git init`

2. ❌ **Schlechter Commit**
   `echo "fix" > datei.txt`
   `git add . && git commit -m "update"`
   → Sagt dieser Commit jemandem, was passiert ist? Nein!

3. **Bessere Commit-Nachricht**
   `echo "function authenticate(user, pw) { ... }" > auth.py`
   `git add . && git commit -m "Add JWT-based authentication

   The new auth system uses JWT tokens to improve security
   and reduce database load on every request.

   Related to #F1337"`
   → Subject (50 Z.), Leerzeile, Body (WARUM nicht WAS), Footer

4. **Atomare Commits mit `git add -p`**
   `echo "console.log('debug')" >> auth.py`
   `echo "const API_URL = 'https://api.example.com'" > config.js`
   `git add -p`
   → Wähle nur die auth.py Änderung aus (y/n), nicht die config.js
   `git commit -m "Remove debug logging"`
   → Jetzt hat man zwei saubere, atomare Commits statt einem Mischmasch!

5. **Diskussion:** Warum sind atomare Commits wichtig?
   - Einfacheres Revert & Cherry-Pick
   - Klarere Code-Review-Historie
   - `git bisect` findet den Fehler exakter
