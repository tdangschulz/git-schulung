#!/bin/bash
# Build script for rerere demo start repo
# Creates a repo with main + feature/v2 that have a version.txt conflict
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="${SCRIPT_DIR}/start"

echo "📦 Baue Rerere-Demo-Repo (main + feature/v2 mit Konflikt)..."

# Clean start
rm -rf "$TARGET"
mkdir -p "$TARGET"
cd "$TARGET"

# Init and base commit
git init
echo "version = 1.0" > version.txt
echo "author = Team" >> version.txt
git add .
git commit -m "Initial"

# Feature branch: bump to 2.0
git checkout -b feature/v2
echo "version = 2.0" > version.txt
echo "author = Team" >> version.txt
git add .
git commit -m "Bump version to 2.0"

# Back to main: bump to 1.5 (conflict!)
git checkout main
echo "version = 1.5" > version.txt
echo "author = Team" >> version.txt
git add .
git commit -m "Bump version to 1.5"

echo ""
echo "=== Fertiges Repo ==="
git log --oneline --graph --all
echo ""
echo "=== Dateien ==="
ls
echo ""
echo "✅ start/ erstellt!"

# Create tar.gz
cd "$SCRIPT_DIR"
tar czf start.tar.gz start/
echo "✅ start.tar.gz erstellt!"
