#!/bin/bash
# setup-demos.sh — Alle Git-Schulung Demos auf einmal vorbereiten
# Einfach im geklonten Repo ausführen:
#   cd git-schulung && bash setup-demos.sh
#
# Danach: cd demos/10-conflict-demo/start && git merge feature/change-color

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEMOS_DIR="$SCRIPT_DIR/demos"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'
BOLD='\033[1m'

echo -e "${BOLD}${BLUE}"
echo "╔══════════════════════════════════════════════╗"
echo "║       Git-Schulung — Demo-Setup             ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "${NC}"

EXTRACTED=0
SKIPPED=0
FAILED=0

for demo_dir in "$DEMOS_DIR"/*/; do
    demo_name=$(basename "$demo_dir")
    tar_file="$demo_dir/start.tar.gz"
    target_dir="$demo_dir/start"

    pretty_name=$(echo "$demo_name" | sed 's/^[0-9]*-//' | tr '-' ' ' | sed 's/\b\(.\)/\u\1/g')

    if [ -d "$target_dir" ]; then
        echo -e "${YELLOW}⚠  ${pretty_name}${NC}: existiert bereits — überspringe"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi

    if [ ! -f "$tar_file" ]; then
        echo -e "${RED}✗  ${pretty_name}${NC}: kein start.tar.gz gefunden"
        FAILED=$((FAILED + 1))
        continue
    fi

    echo -e "${BLUE}📦 ${pretty_name}${NC}: entpacke..."

    cd "$demo_dir"
    if tar xzf "$tar_file" 2>/dev/null; then
        if [ -d "$target_dir/.git" ]; then
            echo -e "${GREEN}✓  ${pretty_name}${NC}: ${target_dir}"
        else
            echo -e "${YELLOW}⚠  ${pretty_name}${NC}: entpackt, aber kein .git gefunden"
        fi
        EXTRACTED=$((EXTRACTED + 1))
    else
        echo -e "${RED}✗  ${pretty_name}${NC}: entpacken fehlgeschlagen"
        FAILED=$((FAILED + 1))
    fi
    cd "$SCRIPT_DIR"
done

echo ""
echo -e "${BOLD}══════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ ${EXTRACTED} Demos entpackt${NC}"
if [ $SKIPPED -gt 0 ]; then echo -e "${YELLOW}⚠ $SKIPPED bereits vorhanden${NC}"; fi
if [ $FAILED -gt 0 ]; then echo -e "${RED}✗ $FAILED fehlgeschlagen${NC}"; fi
echo ""

if [ $EXTRACTED -gt 0 ]; then
    echo -e "${BOLD}Schnellstart für Live-Demos:${NC}"
    echo ""
    echo "  Nr  Demo                Befehl"
    echo "  --  ----                ------"
    echo "  10  Merge-Konflikt      cd demos/10-conflict-demo/start  →  git merge feature/change-color"
    echo "  11  diff3-Konfliktstil  cd demos/11-diff3-demo/start    →  git merge feature/dark"
    echo "  12  Rerere              cd demos/12-rerere-demo/start   →  git merge feature/v2"
    echo "  09  Merge-Strategien    cd demos/09-merge-strategies/start"
    echo "  07  Gitflow             cd demos/07-gitflow-demo/start  →  git switch -c feature/login"
    echo "  02  Pizza-Branches      cd demos/02-galactic-pizza/start →  git switch -c feature/menu"
    echo ""
    echo -e "${BOLD}Workflow:${NC}"
    echo "  cd start/ → git log --oneline --graph --all → Status checken → loslegen!"
fi
echo ""
