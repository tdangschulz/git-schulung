#!/bin/bash
# build-start.sh — Erzeugt das start.tar.gz für die Subtree-Demo
# Führe dies aus, wenn du das Demo-Repo neu aufbauen willst.
#
# Verwendung: bash build-start.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR=$(mktemp -d)

echo "📦 Baue Subtree-Demo-Repo..."

# Externes Repo auf GitHub
GIT_SUBTREE_REPO="https://github.com/tdangschulz/git-subtree.git"

# ============================================================
# 1. Hauptprojekt (WebApp)
# ============================================================
MAIN_DIR="$BUILD_DIR/start"
mkdir -p "$MAIN_DIR"
cd "$MAIN_DIR"
git init

echo "webapp v1.0" > README.md
echo "<!DOCTYPE html><html><head><title>WebApp</title></head><body>Hello</body></html>" > index.html
git add .
git commit -m "Initial commit: WebApp-Setup"

echo "console.log('app.js v1');" > app.js
git add .
git commit -m "feat: JavaScript-Grundstruktur"

echo "function greet(name) { return 'Hello, ' + name; }" > app.js
git add .
git commit -m "feat: Hello-Funktion"

mkdir -p src
echo "export const VERSION = '1.0';" > src/version.js
git add .
git commit -m "feat: Version-Modul"

echo "/* WebApp Styles */ body { font-family: sans-serif; margin: 0; }" > style.css
git add .
git commit -m "feat: Basis-Stylesheet"

# ============================================================
# 2. Externes Repo per Subtree ins Hauptprojekt einbinden
# ============================================================
cd "$MAIN_DIR"
git subtree add --prefix=vendor/bootstrap "$GIT_SUBTREE_REPO" main \
  -m "chore: Bootstrap per Subtree von github.com/tdangschulz/git-subtree eingebunden"

# Noch ein eigener Commit im Hauptprojekt
echo "# WebApp - v1.0" > README.md
echo "Uses Bootstrap via git subtree from tdangschulz/git-subtree" >> README.md
git add README.md
git commit -m "docs: README aktualisiert"

# ============================================================
# 3. Saubermachen
# ============================================================
cd "$MAIN_DIR"
git checkout main

# Log anzeigen
echo ""
echo "=== Fertiges Repo ==="
git log --oneline --graph --all
echo ""

echo "=== Branches ==="
git branch -a
echo ""

# ============================================================
# 4. Start-Paket erstellen
# ============================================================
cd "$BUILD_DIR"
tar czf "$SCRIPT_DIR/start.tar.gz" start/

# Aufräumen
rm -rf "$BUILD_DIR"

echo "✅ start.tar.gz erstellt!"
echo ""
echo "Zum Testen:"
echo "  cd demos/16-subtree-demo"
echo "  tar xzf start.tar.gz"
echo "  cd start"
echo "  git log --oneline --graph --all"
