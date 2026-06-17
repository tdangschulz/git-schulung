## Schnellstart

```bash
# Auspacken
cd /tmp
tar xzf pfad/zu/start.tar.gz
cd start

# Status: config.txt auf main = "color = green", feature/change-color = "color = red"
# Branches sind divergiert — Merge führt sofort zum Konflikt!
# Erster Befehl: Merge provozieren
git merge feature/change-color
# → cat config.txt zeigt die Konflikt-Markierungen
```

# Merge-Konflikte

Demo zur Entstehung und Auflösung von Merge-Konflikten.

Start: `config.txt` mit "color = blue".

## Übungsaufgaben

### Konflikt provozieren

1. **Initial-Commit**
   `git init && git add config.txt && git commit -m "Initial config"`

2. **Feature-Branch: Farbe auf Rot ändern**
   `git switch -c feature/change-color`
   `echo "color = red" > config.txt`
   `git add . && git commit -m "Change color to red"`

3. **Main: Farbe auf Grün ändern (parallel!)**
   `git switch main`
   `echo "color = green" > config.txt`
   `git add . && git commit -m "Change color to green"`

4. **Merge → KONFLIKT!**
   `git merge feature/change-color`
   `cat config.txt` → Zeigt die Konflikt-Markierungen

### Lösung 1: Automatisch mit -Xours

5. Merge abbrechen: `git merge --abort`
6. Nochmal merge, aber "unsere" Seite gewinnt:
   `git merge -Xours feature/change-color --no-edit`
   `cat config.txt` → "color = green"

### Lösung 2: Manuell (der saubere Weg)

7. `git reset --hard HEAD~1`
8. `git merge feature/change-color || true`
9. `cat config.txt` und konfiguration manuell bearbeiten
10. `git add config.txt && git commit --no-edit`

### Diskussion

- Wann ist `-Xours` sinnvoll? (z.B. bei reinen Formatierungs-Änderungen)
- Wann muss man manuell lösen? (bei inhaltlichen Konflikten)
- Warum ist der Konflikt entstanden? → Beide haben die SELBE Zeile geändert.
