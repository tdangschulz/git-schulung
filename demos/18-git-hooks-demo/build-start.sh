#!/bin/bash
BUILD_DIR=$(mktemp -d)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$BUILD_DIR"
git init
git config user.email "demo@git-schulung.de"
git config user.name "Git Schulung"

# ===== Initialer Commit: calc.py mit Tests =====
mkdir -p .githooks

cat > calc.py << 'PYEOF'
#!/usr/bin/env python3
"""Taschenrechner mit Grundrechenarten."""

def add(a, b):
    return a + b

def subtract(a, b):
    return a - b

def multiply(a, b):
    return a * b

def divide(a, b):
    if b == 0:
        raise ValueError("Division durch Null nicht erlaubt")
    return a / b

def main():
    print("=== Taschenrechner ===")
    print(f"5 + 3 = {add(5, 3)}")
    print(f"10 - 4 = {subtract(10, 4)}")
    print(f"6 * 7 = {multiply(6, 7)}")
    print(f"15 / 3 = {divide(15, 3)}")

if __name__ == "__main__":
    main()
PYEOF

cat > test_calc.py << 'PYEOF'
#!/usr/bin/env python3
"""Unit-Tests für den Taschenrechner."""
from calc import add, subtract, multiply, divide

def test_add():
    assert add(2, 3) == 5
    assert add(-1, 1) == 0
    print("  ✓ add")

def test_subtract():
    assert subtract(10, 4) == 6
    assert subtract(0, 5) == -5
    print("  ✓ subtract")

def test_multiply():
    assert multiply(3, 4) == 12
    assert multiply(-2, 5) == -10
    print("  ✓ multiply")

def test_divide():
    assert divide(15, 3) == 5
    assert divide(7, 2) == 3.5
    print("  ✓ divide")

def test_divide_by_zero():
    try:
        divide(1, 0)
        assert False, "Sollte Exception werfen"
    except ValueError:
        pass
    print("  ✓ divide_by_zero")

if __name__ == "__main__":
    print("Tests werden ausgeführt...")
    test_add()
    test_subtract()
    test_multiply()
    test_divide()
    test_divide_by_zero()
    print("\n✅ Alle Tests bestanden!")
PYEOF

git add calc.py test_calc.py
git commit -m "Initial: Taschenrechner mit Tests"

# ===== Hook-Dateien erstellen (im .githooks/ Ordner) =====

# --- pre-commit: Syntax-Prüfung + TODO-Warnung ---
cat > .githooks/pre-commit << 'HOOK'
#!/bin/bash
# pre-commit Hook: Prüft Python-Syntax und sucht nach offenen TODOs
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
ERRORS=0

echo ""
echo "🔍 pre-commit: Prüfe geänderte Dateien..."

# Nur gestagede .py Dateien prüfen
for file in $(git diff --cached --name-only --diff-filter=ACM | grep '\.py$'); do
    if [ ! -f "$file" ]; then
        continue
    fi

    # 1. Python-Syntax-Prüfung
    python3 -m py_compile "$file" 2>/dev/null
    if [ $? -ne 0 ]; then
        echo -e "${RED}  ✗ $file: Syntax-Fehler!${NC}"
        python3 -m py_compile "$file" 2>&1 | sed 's/^/    /'
        ERRORS=$((ERRORS + 1))
    else
        echo -e "${GREEN}  ✓ $file: Syntax OK${NC}"
    fi

    # 2. TODO/FIXME/DEBUG-Warnung
    TODOS=$(grep -n 'TODO\|FIXME\|HACK\|XXX' "$file" | grep -v 'grep\|#.*no-warn' || true)
    if [ -n "$TODOS" ]; then
        echo -e "${YELLOW}  ⚠ $file: Offene Todos gefunden:${NC}"
        echo "$TODOS" | while IFS= read -r line; do
            echo "      $line"
        done
    fi

    # 3. print()-Debugging-Warnung
    DEBUG_PRINTS=$(grep -n 'print(' "$file" | grep -v '__main__\|#.*debug' || true)
    if [ -n "$DEBUG_PRINTS" ]; then
        DEPS=$(echo "$DEBUG_PRINTS" | wc -l)
        echo -e "${YELLOW}  ⚠ $file: $DEPS print()-Aufrufe (debug?)${NC}"
    fi
done

if [ $ERRORS -gt 0 ]; then
    echo -e "\n${RED}❌ pre-commit: $ERRORS Fehler gefunden — Commit abgebrochen${NC}"
    exit 1
fi

echo -e "\n${GREEN}✅ pre-commit: Alles OK${NC}"
exit 0
HOOK

# --- commit-msg: Conventional Commits Format erzwingen ---
cat > .githooks/commit-msg << 'HOOK'
#!/bin/bash
# commit-msg Hook: Erzwingt Conventional Commits Format
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

COMMIT_MSG_FILE=$1
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

# Erlaubte Typen
TYPES="feat|fix|docs|refactor|test|chore|style|perf|ci|build|revert"

# Regex: type(scope)!: description
PATTERN="^($TYPES)(\([a-z0-9_-]+\))?(!)?: .{1,72}$"

if ! echo "$COMMIT_MSG" | grep -qE "$PATTERN"; then
    echo ""
    echo -e "${RED}❌ commit-msg: Ungültiges Commit-Format${NC}"
    echo ""
    echo "Erlaubte Formate:"
    echo "  type(scope): description"
    echo "  type: description"
    echo "  type!(scope): description  (Breaking Change)"
    echo ""
    echo "Erlaubte Typen:"
    echo "  feat, fix, docs, refactor, test, chore, style, perf, ci, build, revert"
    echo ""
    echo -e "${YELLOW}Beispiele:${NC}"
    echo "  feat(calc): add power function"
    echo "  fix: handle division by zero"
    echo "  docs(readme): update installation guide"
    echo ""
    echo "Deine Nachricht: $COMMIT_MSG"
    exit 1
fi

# Breaking Change erkennen
if echo "$COMMIT_MSG" | grep -q "!"; then
    echo "  ⚠ BREAKING CHANGE erkannt!"
fi

echo -e "  ✓ Commit-Format OK"
exit 0
HOOK

# --- pre-push: Tests ausführen ---
cat > .githooks/pre-push << 'HOOK'
#!/bin/bash
# pre-push Hook: Führt Tests aus bevor gepusht wird
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

REMOTE=$1
URL=$2

echo ""
echo "📤 pre-push: Pushe zu $REMOTE ($URL)"

# Nur pushen wenn wir auf main oder feature/* sind
BRANCH=$(git symbolic-ref HEAD 2>/dev/null | sed 's|refs/heads/||')
if [ "$BRANCH" = "main" ]; then
    echo -e "${YELLOW}  ⚠ Hauptbranch — führe Tests aus...${NC}"
elif [[ "$BRANCH" == feature/* ]]; then
    echo "  Feature-Branch: $BRANCH"
fi

# Tests ausführen
echo "  Führe Tests aus..."
TEST_OUTPUT=$(python3 test_calc.py 2>&1)
TEST_EXIT=$?

if [ $TEST_EXIT -ne 0 ]; then
    echo -e "${RED}  ❌ Tests fehlgeschlagen! Push abgebrochen${NC}"
    echo "$TEST_OUTPUT" | sed 's/^/    /'
    exit 1
fi

echo -e "${GREEN}  ✅ Tests bestanden${NC}"
exit 0
HOOK

# --- post-commit: Commit-Log ---
cat > .githooks/post-commit << 'HOOK'
#!/bin/bash
# post-commit Hook: Schreibt Commit-Info ins Log
LOGFILE=".commit-log"
COMMIT_HASH=$(git rev-parse --short HEAD)
COMMIT_MSG=$(git log -1 --pretty=%s)
COMMIT_DATE=$(git log -1 --format=%cd --date=short)
AUTHOR=$(git log -1 --pretty=%an)

echo "$COMMIT_DATE | $AUTHOR | $COMMIT_HASH | $COMMIT_MSG" >> "$LOGFILE"
echo "  📝 post-commit: Logeintrag geschrieben ($COMMIT_HASH)"
exit 0
HOOK

# --- post-commit auch als post-merge aktivieren ---
cp .githooks/post-commit .githooks/post-merge

# Hooks ausführbar machen
chmod +x .githooks/pre-commit .githooks/commit-msg .githooks/pre-push .githooks/post-commit .githooks/post-merge

# Hooks committen
git add .githooks/
git commit -m "chore: add git hooks for code quality"

# ===== setup-hooks.sh =====
cat > setup-hooks.sh << 'SHEOF'
#!/bin/bash
# Installiert die Git-Hooks für dieses Repository
# Setzt core.hooksPath auf .githooks/

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="$SCRIPT_DIR/.githooks"

if [ ! -d "$HOOKS_DIR" ]; then
    echo "❌ Fehler: .githooks/ nicht gefunden"
    echo "  Bist du im Repository-Root?"
    exit 1
fi

git config core.hooksPath "$HOOKS_DIR"
echo "✅ Git-Hooks aktiviert!"
echo "  Pfad: $HOOKS_DIR"
echo ""
echo "Aktive Hooks:"
for hook in pre-commit commit-msg pre-push post-commit post-merge; do
    if [ -x "$HOOKS_DIR/$hook" ]; then
        echo "  ✓ $hook"
    fi
done
echo ""
echo "Jetzt werden bei jedem Commit/Push automatisch Prüfungen ausgeführt."
echo "Mit --no-verify (git commit --no-verify) kannst du Hooks umgehen."
SHEOF
chmod +x setup-hooks.sh
git add setup-hooks.sh
git commit -m "chore: add setup-hooks script"

# ===== Tags =====
git tag v1.0 HEAD~2
git tag v1.1 HEAD~1
git tag v1.2 HEAD

echo ""
echo "=== Repo mit $(git log --oneline | wc -l) Commits erstellt ==="
echo ""
git log --oneline
echo ""
echo "=== Hooks ==="
for hook in .githooks/*; do
    name=$(basename "$hook")
    desc=$(head -2 "$hook" | grep "^#" | sed 's/^# //')
    echo "  $name: $desc"
done
echo ""

# Hooks testen
echo "=== Teste Syntax aller Hooks ==="
for hook in .githooks/*; do
    bash -n "$hook" && echo "  ✓ $(basename "$hook"): Syntax OK" || echo "  ✗ $(basename "$hook"): Syntax-Fehler!"
done
echo ""

# Tar erstellen
cd "$SCRIPT_DIR"
rm -f start.tar.gz 2>/dev/null || true
rm -rf start 2>/dev/null || true
tar czf start.tar.gz \
  --exclude='__pycache__' \
  --transform='s|^./|calc-app/|' \
  -C "$BUILD_DIR" .
echo "start.tar.gz erstellt"
echo ""
echo "=== Verwendung ==="
echo "cd /tmp && tar xzf pfad/zu/start.tar.gz && cd calc-app"
echo "./setup-hooks.sh            # Hooks aktivieren"
echo "git commit --allow-empty -m 'test: ohne hooks'"
echo "git commit --allow-empty -m 'test'  # Wird von commit-msg geblockt"
echo "python3 test_calc.py        # Tests ausführen"
