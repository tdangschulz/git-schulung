# Git Hooks & Automation

Demo für client-seitige Git Hooks — automatisierte Qualitätsprüfungen vor Commit/Push.

## Schnellstart

```bash
cd demos/14-hooks-automation
tar xzf start.tar.gz
cd start

# Hooks aktivieren (Variante A: Symlinks)
bash scripts/install-hooks.sh

# Oder (Variante B: core.hooksPath — noch einfacher!)
git config core.hooksPath .githooks
```

## Übersicht: 5 Hooks

| Hook | Wann? | Was macht er? |
|---|---|---|
| `pre-commit` | Vor dem Commit | Prüft auf nachgestellte Leerzeichen + Python-Syntax |
| `commit-msg` | Nach Commit-Nachricht | Prüft Format: Prefix + max 50 Zeichen |
| `pre-push` | Vor `git push` | Simuliert Tests + warnt vor Debug-Logs |
| `post-commit` | Nach erfolgreichem Commit | Schreibt automatisch CHANGELOG.md |
| `post-merge` | Nach einem Merge | Prüft auf geänderte Dependencies |

## Befehlsablauf

### 1. Hooks installieren und testen

```bash
git config core.hooksPath .githooks
```

### 2. pre-commit — Whitespace-Fehler provozieren

```bash
echo "test    " > test.txt
git add .
git commit -m "FEAT: Test-Datei"
# → ❌ Nachgestellte Leerzeichen gefunden!
```

Fix: `echo "test" > test.txt`, dann nochmal.

### 3. commit-msg — Falsches Format

```bash
git commit -m "update"
# → ❌ Kein Prefix!

git commit -m "FEAT: Test-Datei"
# → ✅ Geht durch!

git commit -m "FIX: Dies ist eine sehr lange Nachricht die ueber 50 Zeichen geht und abgelehnt wird"
# → ❌ Betreff zu lang!
```

### 4. pre-push — Debug-Logs erkennen

```bash
git switch demo/schlechter-commit
git push origin demo/schlechter-commit
# → ⚠️ Warnung: Debug/Artefakte gefunden!
```

### 5. post-commit — Automatischer Changelog

```bash
git commit -m "FEAT: Noch ein Feature"
cat CHANGELOG.md
# → Automatisch erstellt!
```

### 6. Hooks umgehen (`--no-verify`)

```bash
git commit --no-verify -m "umgehung"
# → Hooks werden übersprungen
```

Nur für Ausnahmen! Normalerweise ist Umgehen ein Alarmzeichen.

## Demo-Branch: Schlechter Commit

Der Branch `demo/schlechter-commit` enthält bewusst schlechten Code:
- Trailing Whitespace
- `print("DEBUG...")` Logs

```bash
git switch demo/schlechter-commit
git commit -m "update"                        # ❌ commit-msg
git commit -m "BUG: Schlechten Code"           # ✅ Format ok
# → pre-commit prüft Syntax, pre-push warnt vor Debug
```

## Wichtige Hook-Regeln

- **Exit-Code ≠ 0** = Vorgang abbrechen (pre-commit, commit-msg, pre-push)
- `git commit --no-verify` / `git push --no-verify` = Hooks umgehen
- **post-commit / post-merge** können NICHT abbrechen (laufen immer durch)
- Hooks sind **client-seitig** — jeder muss sie selbst installieren
- Hooks in `.githooks/` werden **versioniert** — automatisch im Team verteilt

## ⚠️ Typische Praxisprobleme

**❗ Hooks nicht installiert:** \`git clone\` — Team hat die Hooks nicht.
→ \`bash scripts/install-hooks.sh\` oder \`git config core.hooksPath .githooks\`

**❗ --no-verify als Standard:** Hooks werden systematisch umgangen → sinnlos.
→ Nur in echten Ausnahmefällen umgehen.

**❗ Hooks zu langsam:** Ein Hook der 30s braucht wird irgendwann umgangen.
→ Hooks schlank halten, schwere Checks in die CI.

**❗ Hooks nur lokal:** Andere im Team haben sie nicht.
→ Hooks ins Repo einchecken (.githooks/) + Installation dokumentieren.
