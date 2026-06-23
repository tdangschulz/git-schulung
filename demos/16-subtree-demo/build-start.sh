#!/bin/bash
# build-start.sh — Erzeugt das start.tar.gz für die Subtree-Demo
# Das start-Repo enthält NUR das Hauptprojekt (WebApp).
# Der subtree-vendor-Ordner wird erst LIVE in der Demo hinzugefügt.
#
# Verwendung: bash build-start.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR=$(mktemp -d)

echo "📦 Baue Subtree-Demo-Repo (nur WebApp, kein vendor)..."

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

cd "$MAIN_DIR"

# ============================================================
# 2. Saubermachen
# ============================================================
git checkout main

# Log anzeigen
echo ""
echo "=== Fertiges Repo (NUR WebApp, KEIN vendor!) ==="
git log --oneline --graph --all
echo ""

echo "=== Dateien ==="
ls
echo ""

# ============================================================
# 3. Start-Paket erstellen
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
echo "  ls  # → KEIN vendor/ Ordner!"
