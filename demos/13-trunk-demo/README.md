## Schnellstart

```bash
# Auspacken
cd /tmp
tar xzf pfad/zu/start.tar.gz
cd start

# Status: app.py + config.py, auf main, alles committed
# Erster Befehl: Feature hinter Feature-Flag hinzufügen
# app.py erweitern und Neues Feature ausprobieren
```

# Trunk-Based Development

Demo für Trunk-basierte Entwicklung mit Feature-Flags statt langen Branches.

Enthält:
- `app.py` – einfache Applikation
- `config.py` – Konfiguration mit Feature-Flags

## Befehlsablauf

1. **Initial-Commit**
   `git init && git add . && git commit -m "Initial app"`

2. **Neues Feature hinter Feature-Flag**
   Füge in `app.py` am Ende ein:
   ```python
   import config
   if config.NEW_FEATURE_ENABLED:
       print("🚀 New feature is LIVE!")
   else:
       print("🔄 Old code path")
   ```
   `git add . && git commit -m "Add new feature behind feature flag (disabled)"`

3. **Laufen lassen**
   `python3 app.py` → "🔄 Old code path" (Feature ist deaktiviert)

4. **Feature aktivieren**
   Ändere in `config.py`: `NEW_FEATURE_ENABLED = True`
   `git add . && git commit -m "Enable new feature via feature flag"`

5. **Laufen lassen**
   `python3 app.py` → "🚀 New feature is LIVE!"

6. **Diskussion:**
   - Vorteil: Kein langer Branch, kein großer Merge am Ende
   - Nachteil: Alte Code-Pfade bleiben erstmal im Code
   - Wann löscht man das Feature-Flag? → Wenn das Feature stabil ist und alle es nutzen

## ⚠️ Typische Praxisprobleme

**❗ Feature-Flag nie entfernt:** Alter Code liegt tot im Repository.
→ Regelmäßig alte Flags suchen und tote Codepfade entfernen.

**❗ Zu viele Flags:** 100+ Flags in der Config — niemand weiß mehr was aktiv ist.
→ Flags dokumentieren + mit Datum versehen.

**❗ Flag nicht getestet:** Beide Zustände (True/False) müssen funktionieren.
→ Tests für beide Pfade schreiben.
