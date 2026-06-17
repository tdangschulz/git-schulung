#!/bin/bash
# cleanup-demos.sh — Entfernt alle entpackten Demo-Ordner
# Nachher: bash setup-demos.sh für frischen Stand

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEMOS_DIR="$SCRIPT_DIR/demos"

for demo_dir in "$DEMOS_DIR"/*/; do
    target="$demo_dir/start"
    if [ -d "$target" ]; then
        echo "🧹 Entferne: $target"
        rm -rf "$target"
    fi
done

echo "✅ Alle Start-Ordner entfernt. Bereit für frisches setup-demos.sh"
