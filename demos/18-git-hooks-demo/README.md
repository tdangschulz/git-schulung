# Demo 18: Git Hooks — Automatische Qualitätssicherung

**Ziel:** Lerne wie Git-Hooks funktionieren — automatische Skripte die vor,
nach oder während bestimmter Git-Aktionen ausgelöst werden.

---

## Theorie

### Was sind Git Hooks?

Git-Hooks sind **Shell-Skripte** im Ordner `.git/hooks/` (oder einem
benutzerdefinierten Pfad via `core.hooksPath`). Git ruft sie bei
bestimmten Aktionen automatisch auf.

```
.git/hooks/              # Standard-Pfad (wird nicht versioniert)
.githooks/               # Versioniert — besser! (core.hooksPath)
```

### Client-Side Hooks (lokal)

| Hook | Wann? | Exit ≠ 0 |
|---|---|---|
| `pre-commit` | Bevor der Commit entsteht | Commit abgebrochen |
| `prepare-commit-msg` | Nach Editor-Start, vor finalem Speichern | — |
| `commit-msg` | Nachdem die Message geschrieben wurde | Commit abgebrochen |
| `post-commit` | Nach erfolgreichem Commit | Nur Benachrichtigung |
| `pre-push` | Vor `git push` | Push abgebrochen |
| `post-checkout` | Nach `git checkout` | Nur Benachrichtigung |
| `post-merge` | Nach `git merge` | Nur Benachrichtigung |
| `pre-rebase` | Vor `git rebase` | Rebase abgebrochen |

### Server-Side Hooks (auf dem Remote)

| Hook | Wann? |
|---|---|
| `pre-receive` | Bevor der Server neue Ref-Daten annimmt |
| `update` | Pro Branch — feiner als pre-receive |
| `post-receive` | Nach erfolgreichem Push (z.B. CI auslösen) |

---

## 🖥️ Live-Demo

> **Szenario:** Ein Python-Taschenrechner-Projekt. Wir richten nacheinander
> verschiedene Hooks ein und sehen wie sie Commits blockieren, warnen oder
> protokollieren.

### Setup

```bash
# Auspacken
cd /tmp
tar xzf pfad/zu/18-git-hooks-demo/start.tar.gz
cd calc-app
```

**Repo-Struktur:**
```
calc-app/
├── calc.py              # Taschenrechner
├── test_calc.py         # Unit-Tests
├── .githooks/           # Versionierte Hooks
│   ├── pre-commit       # Syntax-Prüfung
│   ├── commit-msg       # Conventional Commits
│   ├── pre-push         # Tests vor Push
│   ├── post-commit      # Commit-Log
│   └── post-merge       # (gleicher Inhalt)
└── setup-hooks.sh       # Hooks aktivieren
```

---

### Demo A: Hooks installieren

Standardmäßig liegen Hooks in `.git/hooks/` — der wird **nicht versioniert**
(jeder müsste sie manuell kopieren). Besser: `.githooks/` versionieren
und `core.hooksPath` setzen:

```bash
./setup-hooks.sh
```

Ausgabe:
```
✅ Git-Hooks aktiviert!
  Pfad: /tmp/calc-app/.githooks

Aktive Hooks:
  ✓ pre-commit
  ✓ commit-msg
  ✓ pre-push
  ✓ post-commit
  ✓ post-merge
```

Was passiert? `git config core.hooksPath .githooks/` — ab sofort sucht Git
in `.githooks/` statt `.git/hooks/` nach Hook-Skripten. **Jeder im Team**
hat sofort dieselben Hooks nach `git pull`.

---

### Demo B: `pre-commit` — Syntax-Prüfung

Der `pre-commit` Hook prüft:
1. Python-Syntax (`python3 -m py_compile`)
2. TODO/FIXME/HACK-Kommentare (⚠ Warnung)
3. `print()`-Aufrufe (⚠ Debug-Hinweis)

**Erfolgreicher Commit:**

```bash
echo "" >> calc.py
git add calc.py
git commit -m "chore: add newline"
```

Ausgabe:
```
🔍 pre-commit: Prüfe geänderte Dateien...
  ✓ calc.py: Syntax OK

✅ pre-commit: Alles OK
📝 post-commit: Logeintrag geschrieben (abc1234)
```

**Geblockter Commit (Syntax-Fehler):**

```bash
echo "def broken(" >> calc.py
git add calc.py
git commit -m "chore: test"
```

Ausgabe:
```
🔍 pre-commit: Prüfe geänderte Dateien...
  ✗ calc.py: Syntax-Fehler!
    SyntaxError: unexpected EOF while parsing

❌ pre-commit: 1 Fehler gefunden — Commit abgebrochen
```

→ Der Commit wurde **verhindert**. Kein kaputter Code im Repository!

**Warnung bei TODO/print():**

```bash
cat >> calc.py << 'EOF'

# TODO: Add power function
print("DEBUG: loading calc")
EOF
git add calc.py
git commit -m "chore: add power placeholder"
```

```
🔍 pre-commit: Prüfe geänderte Dateien...
  ✓ calc.py: Syntax OK
  ⚠ calc.py: Offene Todos gefunden:
      25: # TODO: Add power function
  ⚠ calc.py: 1 print()-Aufrufe (debug?)

✅ pre-commit: Alles OK
```

→ Warnung, aber kein Abbruch. TODOs sind OK, müssen nur sichtbar sein.

---

### Demo C: `commit-msg` — Conventional Commits

Der `commit-msg` Hook prüft das Format der Commit-Message:

```
type(scope): description
↑    ↑       ↑
fix  calc    max 72 Zeichen
```

**Geblockt — falsches Format:**

```bash
git commit --allow-empty -m "bugfix"
```

```
❌ commit-msg: Ungültiges Commit-Format

Erlaubte Formate:
  type(scope): description
  type: description
  type!(scope): description  (Breaking Change)

Erlaubte Typen:
  feat, fix, docs, refactor, test, chore, style, perf, ci, build, revert

Beispiele:
  feat(calc): add power function
  fix: handle division by zero
  docs(readme): update installation guide

Deine Nachricht: bugfix
```

**Erfolgreich — korrektes Format:**

```bash
git commit --allow-empty -m "fix(calc): handle negative numbers correctly"
```

```
  ✓ Commit-Format OK
```

**Hooks umgehen (Notfall):**

```bash
git commit --no-verify -m "schnellfix"
#            ^^^^^^^^^^ Überspringt pre-commit + commit-msg
```

⚠ Nur in Ausnahmefällen! `post-commit` läuft trotzdem (der Commit existiert ja).

---

### Demo D: `pre-push` — Tests vor Push

Vor jedem `git push` werden die Unit-Tests ausgeführt. Wenn Tests
fehlschlagen, wird der Push abgebrochen:

```bash
# Bug einbauen
sed -i 's/return a + b/return a - b/' calc.py
git add calc.py
git commit -m "fix(calc): improve addition performance"

# Pushen → Tests laufen
git push origin main
```

```
📤 pre-push: Pushe zu origin (https://...)
  Führe Tests aus...
  ✗ add: assert 2 + 3 == 5 → 2 - 3 == -1 ≠ 5

❌ Tests fehlgeschlagen! Push abgebrochen
```

→ Bug bemerkt **bevor** er ins Remote kommt. Mit `--no-verify` umgehbar:

```bash
git push --no-verify
```

---

### Demo E: `post-commit` — Commit-Log

Nach jedem erfolgreichen Commit schreibt der `post-commit` Hook einen
Logeintrag in `.commit-log`:

```bash
git commit --allow-empty -m "docs(calc): update readme"
cat .commit-log
```

```
2026-06-23 | Git Schulung | a1b2c3d | docs(calc): update readme
```

Sieht aus wie ein einfaches Changelog. In der Praxis könnte das ein
API-Call an ein Ticket-System sein oder ein Slack-Webhook.

---

### Demo F: Hooks selbst schreiben

Ein minimaler Hook ist nur ein ausführbares Bash-Skript:

```bash
#!/bin/bash
# .githooks/pre-commit
echo "🔍 Prüfe Code-Qualität..."

# Prüfe ob alle .py Dateien Syntax-korrekt sind
for file in $(git diff --cached --name-only | grep '\.py$'); do
    python3 -m py_compile "$file" || exit 1
done

exit 0
```

**Regeln für Hooks:**
- Exit-Code `0` = OK (Git fährt fort)
- Exit-Code `≠0` = Abbruch (Git bricht ab — außer bei post-* Hooks)
- stdout/stderr wird dem User angezeigt
- Keine Argumente nötig (Hooks lesen Umgebungsvariablen oder Dateien)
- `core.hooksPath` macht Hooks teilbar → `git config --global init.templatedir`

---

## 🔍 Zusammenfassung

| Aspekt | Details |
|---|---|
| **Ort** | `.git/hooks/` (lokal) oder `.githooks/` (versioniert) |
| **Aktivierung** | `git config core.hooksPath .githooks/` |
| **Abbruch** | Exit-Code ≠ 0 für pre-* Hooks |
| **Umgehung** | `--no-verify` (pre-commit, commit-msg, pre-push) |
| **Automatisch** | Hooks werden versioniert, per `git` geteilt |
| **Sprache** | Beliebig! Bash, Python, Node, Ruby — Hauptsache ausführbar |

**Typische Anwendungsfälle:**
- ✅ Automatische Linter / Formatierer (`pre-commit`)
- ✅ Conventional Commits erzwingen (`commit-msg`)
- ✅ Tests vor Push (`pre-push`)
- ✅ Changelog / Ticket-Update (`post-commit`)
- ✅ Branch-Namen validieren (`pre-push`)
- ✅ Secret-Leaks erkennen (`pre-commit`)
- ✅ CI/CD auslösen (`post-receive` server-seitig)

---

## 📚 Weiterführend

- [Git Hooks Dokumentation](https://git-scm.com/book/de/v2/Git-Anpassungen-Git-Hooks)
- [githooks.com](https://githooks.com/) — Beispiele und Best Practices
- [Husky](https://typicode.github.io/husky/) — Node.js Hooks-Manager
- [pre-commit.com](https://pre-commit.com/) — Framework für Multi-Language Hooks
- [`git config core.hooksPath`](https://git-scm.com/docs/githooks) — Manpage
