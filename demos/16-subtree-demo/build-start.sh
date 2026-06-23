#!/bin/bash
# build-start.sh — Erzeugt das start.tar.gz für die Subtree-Demo
# Führe dies aus, wenn du das Demo-Repo neu aufbauen willst.
#
# Verwendung: bash build-start.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR=$(mktemp -d)

echo "📦 Baue Subtree-Demo-Repo..."

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
# 2. Externes Projekt (Bootstrap-ähnliche Library)
# ============================================================
BOOTSTRAP_DIR="$BUILD_DIR/tmp-bootstrap"
mkdir -p "$BOOTSTRAP_DIR"
cd "$BOOTSTRAP_DIR"
git init

echo "/*! Bootstrap v1.0 */" > bootstrap.css
echo "Bootstrap - The most popular front-end framework" > README.md
git add .
git commit -m "Initial commit: Bootstrap v1.0"

echo "MIT License" > LICENSE
git add .
git commit -m "chore: Lizenz hinzugefügt"

echo "/*! Bootstrap v1.1 */" > bootstrap.css
echo ".btn { display: inline-block; padding: 6px 12px; border-radius: 4px; }" >> bootstrap.css
git add .
git commit -m "feat: Button-Styles"

echo "/*! Bootstrap Grid */" > grid.css
echo ".row { display: flex; flex-wrap: wrap; }" >> grid.css
echo ".col { flex: 1; padding: 0 15px; }" >> grid.css
git add .
git commit -m "feat: Grid-System"

echo "/*! Bootstrap v1.2 */" > bootstrap.css
echo ".btn-primary { background: #007bff; color: white; }" >> bootstrap.css
git add .
git commit -m "feat: Primary Button"

# ============================================================
# 3. Bootstrap als benannten Branch in WebApp-Repo importieren
#    (damit wir nicht ständig auf /tmp/bootstrap verweisen müssen)
# ============================================================
cd "$MAIN_DIR"
git remote add bootstrap "$BOOTSTRAP_DIR"
git fetch bootstrap --no-tags

# Als Branch für einfachen Zugriff
git branch lib/bootstrap bootstrap/main

# ============================================================
# 4. Einbinden — Bootstraps erste Version per subtree add
# ============================================================
git subtree add --prefix=vendor/bootstrap "$BOOTSTRAP_DIR" main \
  -m "chore: Bootstrap per Subtree eingebunden"

# Noch ein eigener Commit im Hauptprojekt
echo "# WebApp - v1.0" > README.md
echo "Uses Bootstrap via git subtree" >> README.md
git add README.md
git commit -m "docs: README aktualisiert"

# ============================================================
# 5. Ein zweites externes Projekt (Tailwind-ähnlich)
# ============================================================
TAILWIND_DIR="$BUILD_DIR/tmp-tailwind"
mkdir -p "$TAILWIND_DIR"
cd "$TAILWIND_DIR"
git init

echo "/*! TailLite v1.0 - A minimal utility framework */" > tailwind.css
echo ".flex { display: flex; }" >> tailwind.css
echo ".text-center { text-align: center; }" >> tailwind.css
echo ".p-4 { padding: 1rem; }" >> tailwind.css
git add .
git commit -m "Initial: TailLite Utilities"

# Als zweiten Remote hinzufügen
cd "$MAIN_DIR"
git remote add taillite "$TAILWIND_DIR"
git fetch taillite --no-tags
git branch lib/taillite taillite/main

# ============================================================
# 6. Optional: bootstrap als "echtes" externes Repo kopieren
#    für update/push-Demos (wird in README verwendet)
# ============================================================
# Einfach den Bootstrap-Ordner ins start-Paket kopieren
cp -r "$BOOTSTRAP_DIR" "$BUILD_DIR/start/bootstrap-external"

# ============================================================
# 7. Saubermachen: Remote-URLs entfernen
# ============================================================
cd "$MAIN_DIR"
git remote remove bootstrap
git remote remove taillite
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
# 8. Start-Paket erstellen
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
