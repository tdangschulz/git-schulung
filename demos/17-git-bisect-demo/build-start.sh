#!/bin/bash
BUILD_DIR=$(mktemp -d)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$BUILD_DIR"
git init

git config user.email "demo@git-schulung.de"
git config user.name "Git Schulung"

# ===== Commit 1: Initial =====
# ===== Bisect-Test-Script (ab Commit 1 vorhanden) =====
cat > bisect_test.py << 'PYEOF'
#!/usr/bin/env python3
"""Git-Bisect-Test: Prueft Steuerberechnung.
Exit 0 = gut (Bug nicht vorhanden)
Exit 1 = schlecht (Bug vorhanden)
Exit 125 = Commit ueberspringen (alte API)"""
import sys
sys.path.insert(0, '.')
from receipt import generate_receipt

items = [{'name': 'Test', 'price': 100.00, 'qty': 1}]
try:
    result = generate_receipt(items, tax_rate=0.19, discount=0.10)
except Exception:
    sys.exit(125)  # Commit ueberspringen (alte API)

if len(result) >= 4:
    # tax ist 3. oder 4. Rueckgabewert
    tax = result[2] if len(result) == 4 else result[3]
    # Korrekt: (100-10)*0.19 = 17.10
    # Bug: 100*0.19 = 19.00
    if abs(tax - 17.10) < 0.01:
        sys.exit(0)  # Good
    else:
        sys.exit(1)  # Bad
else:
    sys.exit(125)  # Skip (alte API ohne Rabatt)
PYEOF
git add bisect_test.py && git commit -m "Initial: Rechnungs-Grundstruktur"

# ===== Commit 1b: receipt.py =====
cat > receipt.py << 'PYEOF'
#!/usr/bin/env python3
def generate_receipt(items, tax_rate=0.19):
    subtotal = sum(item["price"] * item["qty"] for item in items)
    tax = subtotal * tax_rate
    total = subtotal + tax
    return subtotal, tax, total

def main():
    items = [
        {"name": "Laptop Stand", "price": 49.99, "qty": 1},
        {"name": "USB-C Hub", "price": 34.99, "qty": 2},
        {"name": "Mauspad", "price": 19.99, "qty": 1},
    ]
    subtotal, tax, total = generate_receipt(items)
    print(f"Zwischensumme: {subtotal:.2f} EUR")
    print(f"MwSt (19%): {tax:.2f} EUR")
    print(f"Gesamtsumme: {total:.2f} EUR")

if __name__ == "__main__":
    main()
PYEOF
git add receipt.py && git commit -m "feat: Rechnungs-Grundstruktur"

# ===== Commit 2: Rabatt =====
cat > receipt.py << 'PYEOF'
#!/usr/bin/env python3
def generate_receipt(items, tax_rate=0.19, discount=0):
    subtotal = sum(item["price"] * item["qty"] for item in items)
    discount_amount = subtotal * discount
    tax = (subtotal - discount_amount) * tax_rate
    total = subtotal - discount_amount + tax
    return subtotal, discount_amount, tax, total

def main():
    items = [
        {"name": "Laptop Stand", "price": 49.99, "qty": 1},
        {"name": "USB-C Hub", "price": 34.99, "qty": 2},
        {"name": "Mauspad", "price": 19.99, "qty": 1},
    ]
    subtotal, discount, tax, total = generate_receipt(items, discount=0.05)
    print(f"Zwischensumme: {subtotal:.2f} EUR")
    print(f"Rabatt: -{discount:.2f} EUR")
    print(f"MwSt (19%): {tax:.2f} EUR")
    print(f"Gesamtsumme: {total:.2f} EUR")

if __name__ == "__main__":
    main()
PYEOF
git add receipt.py && git commit -m "feat: Rabatt-Funktion hinzugefuegt"

# ===== Commit 3: Formatierung =====
cat > receipt.py << 'PYEOF'
#!/usr/bin/env python3
def generate_receipt(items, tax_rate=0.19, discount=0):
    subtotal = sum(item["price"] * item["qty"] for item in items)
    discount_amount = subtotal * discount
    tax = (subtotal - discount_amount) * tax_rate
    total = subtotal - discount_amount + tax
    return subtotal, discount_amount, tax, total

def print_line(label, value, width=50):
    dots = "." * (width - len(label) - len(f"{value:.2f}") - 3)
    print(f"{label} {dots} {value:.2f} EUR")

def main():
    items = [
        {"name": "Laptop Stand", "price": 49.99, "qty": 1},
        {"name": "USB-C Hub", "price": 34.99, "qty": 2},
        {"name": "Mauspad", "price": 19.99, "qty": 1},
    ]
    subtotal, discount, tax, total = generate_receipt(items, discount=0.05)

    print("=" * 54)
    print("              RECHNUNG")
    print("=" * 54)
    print()
    for item in items:
        line = f"  {item['qty']}x {item['name']:<20s} {item['price']:>8.2f} EUR"
        print(line)
    print()
    print("-" * 54)
    print_line("Zwischensumme", subtotal)
    print_line("Rabatt (5%)", discount)
    print_line("MwSt (19%)", tax)
    print("=" * 54)
    print_line("GESAMTSUMME", total)

if __name__ == "__main__":
    main()
PYEOF
git add receipt.py && git commit -m "refactor: Formatierte Ausgabe"

# ===== Commit 4: Waehrung =====
cat > receipt.py << 'PYEOF'
#!/usr/bin/env python3
def generate_receipt(items, tax_rate=0.19, discount=0):
    subtotal = sum(item["price"] * item["qty"] for item in items)
    discount_amount = subtotal * discount
    tax = (subtotal - discount_amount) * tax_rate
    total = subtotal - discount_amount + tax
    return subtotal, discount_amount, tax, total

def print_line(label, value, currency, width=50):
    dots = "." * (width - len(label) - len(f"{value:.2f}") - 3)
    print(f"{label} {dots} {value:.2f} {currency}")

def main():
    currency = "EUR"
    items = [
        {"name": "Laptop Stand", "price": 49.99, "qty": 1},
        {"name": "USB-C Hub", "price": 34.99, "qty": 2},
        {"name": "Mauspad", "price": 19.99, "qty": 1},
    ]
    subtotal, discount, tax, total = generate_receipt(items, discount=0.05)

    print("=" * 54)
    print("              RECHNUNG")
    print("=" * 54)
    print()
    for item in items:
        print(f"  {item['qty']}x {item['name']:<20s} {item['price']:>8.2f} {currency}")
    print()
    print("-" * 54)
    print_line("Zwischensumme", subtotal, currency)
    print_line("Rabatt (5%)", discount, currency)
    print_line("MwSt (19%)", tax, currency)
    print("=" * 54)
    print_line("GESAMTSUMME", total, currency)

if __name__ == "__main__":
    main()
PYEOF
git add receipt.py && git commit -m "feat: Waehrung als Variable"

# ===== Commit 5: BUG eingebaut! =====
cat > receipt.py << 'PYEOF'
#!/usr/bin/env python3
def generate_receipt(items, tax_rate=0.19, discount=0):
    subtotal = sum(item["price"] * item["qty"] for item in items)
    discount_amount = subtotal * discount
    # BUG: Steuer wird vom Brutto statt Netto berechnet
    tax = subtotal * tax_rate
    total = subtotal - discount_amount + tax
    return subtotal, discount_amount, tax, total

def print_line(label, value, currency, width=50):
    dots = "." * (width - len(label) - len(f"{value:.2f}") - 3)
    print(f"{label} {dots} {value:.2f} {currency}")

def main():
    currency = "EUR"
    items = [
        {"name": "Laptop Stand", "price": 49.99, "qty": 1},
        {"name": "USB-C Hub", "price": 34.99, "qty": 2},
        {"name": "Mauspad", "price": 19.99, "qty": 1},
    ]
    subtotal, discount, tax, total = generate_receipt(items, discount=0.05)

    print("=" * 54)
    print("              RECHNUNG")
    print("=" * 54)
    print()
    for item in items:
        print(f"  {item['qty']}x {item['name']:<20s} {item['price']:>8.2f} {currency}")
    print()
    print("-" * 54)
    print_line("Zwischensumme", subtotal, currency)
    print_line("Rabatt (5%)", discount, currency)
    print_line("MwSt (19%)", tax, currency)
    print("=" * 54)
    print_line("GESAMTSUMME", total, currency)

if __name__ == "__main__":
    main()
PYEOF
git add receipt.py && git commit -m "refactor: Steuerberechnung optimiert"

# ===== Commit 6: Tests =====
cat > test_receipt.py << 'PYEOF'
#!/usr/bin/env python3
import sys
sys.path.insert(0, ".")
from receipt import generate_receipt

items = [{"name": "Test Item", "price": 100.00, "qty": 1}]
sub, disc, tax, total = generate_receipt(items, tax_rate=0.19, discount=0.10)

ok = True
if abs(sub - 100.00) >= 0.01:
    print(f"Fehler: Zwischensumme {sub:.2f} != 100.00")
    ok = False
if abs(disc - 10.00) >= 0.01:
    print(f"Fehler: Rabatt {disc:.2f} != 10.00")
    ok = False
expected_tax = 17.10  # (100-10) * 0.19 = 17.10
if abs(tax - expected_tax) >= 0.01:
    print(f"Fehler: Steuer {tax:.2f} != {expected_tax:.2f}")
    ok = False
expected_total = 107.10  # 100 - 10 + 17.10 = 107.10
if abs(total - expected_total) >= 0.01:
    print(f"Fehler: Summe {total:.2f} != {expected_total:.2f}")
    ok = False

if ok:
    print("Alle Tests bestanden!")
    sys.exit(0)
else:
    print("Tests FEHLGESCHLAGEN!")
    sys.exit(1)
PYEOF
python3 test_receipt.py 2>/dev/null || true
git add test_receipt.py && git commit -m "test: Unit-Tests fuer Rechnung"

# ===== Commit 7: Versand =====
cat > receipt.py << 'PYEOF'
#!/usr/bin/env python3
def generate_receipt(items, tax_rate=0.19, discount=0, shipping=0):
    subtotal = sum(item["price"] * item["qty"] for item in items)
    discount_amount = subtotal * discount
    # BUG: Steuer wird vom Brutto statt Netto berechnet
    tax = subtotal * tax_rate
    total = subtotal - discount_amount + shipping + tax
    return subtotal, discount_amount, shipping, tax, total

def print_line(label, value, currency, width=50):
    dots = "." * (width - len(label) - len(f"{value:.2f}") - 3)
    print(f"{label} {dots} {value:.2f} {currency}")

def main():
    currency = "EUR"
    items = [
        {"name": "Laptop Stand", "price": 49.99, "qty": 1},
        {"name": "USB-C Hub", "price": 34.99, "qty": 2},
        {"name": "Mauspad", "price": 19.99, "qty": 1},
    ]
    subtotal, discount, shipping, tax, total = generate_receipt(items, discount=0.05, shipping=4.99)

    print("=" * 54)
    print("              RECHNUNG")
    print("=" * 54)
    print()
    for item in items:
        print(f"  {item['qty']}x {item['name']:<20s} {item['price']:>8.2f} {currency}")
    print()
    print("-" * 54)
    print_line("Zwischensumme", subtotal, currency)
    print_line("Rabatt (5%)", discount, currency)
    print_line("Versand", shipping, currency)
    print_line("MwSt (19%)", tax, currency)
    print("=" * 54)
    print_line("GESAMTSUMME", total, currency)

if __name__ == "__main__":
    main()
PYEOF
git add receipt.py && git commit -m "feat: Versandkosten-Funktion"

# ===== Commit 8: Kunde =====
cat > receipt.py << 'PYEOF'
#!/usr/bin/env python3
import time

def generate_receipt(items, tax_rate=0.19, discount=0, shipping=0):
    subtotal = sum(item["price"] * item["qty"] for item in items)
    discount_amount = subtotal * discount
    # BUG: Steuer wird vom Brutto statt Netto berechnet
    tax = subtotal * tax_rate
    total = subtotal - discount_amount + shipping + tax
    return subtotal, discount_amount, shipping, tax, total

def print_line(label, value, currency, width=50):
    dots = "." * (width - len(label) - len(f"{value:.2f}") - 3)
    print(f"{label} {dots} {value:.2f} {currency}")

def main():
    customer_id = "K-2024-0042"
    currency = "EUR"
    items = [
        {"name": "Laptop Stand", "price": 49.99, "qty": 1},
        {"name": "USB-C Hub", "price": 34.99, "qty": 2},
        {"name": "Mauspad", "price": 19.99, "qty": 1},
    ]
    subtotal, discount, shipping, tax, total = generate_receipt(items, discount=0.05, shipping=4.99)

    print(f"Kunde: {customer_id}")
    print("=" * 54)
    print("              RECHNUNG")
    print("=" * 54)
    print()
    for item in items:
        print(f"  {item['qty']}x {item['name']:<20s} {item['price']:>8.2f} {currency}")
    print()
    print("-" * 54)
    print_line("Zwischensumme", subtotal, currency)
    print_line("Rabatt (5%)", discount, currency)
    print_line("Versand", shipping, currency)
    print_line("MwSt (19%)", tax, currency)
    print("=" * 54)
    print_line("GESAMTSUMME", total, currency)
    print()
    print(f"Datum: {time.strftime('%d.%m.%Y')}")

if __name__ == "__main__":
    main()
PYEOF
git add receipt.py && git commit -m "feat: Kunden-Nummer und Datum"

# ===== Commit 9: README =====
cat > README.md << 'MD'
# Rechnungs-App

Eine kleine Python-App zur Rechnungsgenerierung.
MD
git add README.md && git commit -m "docs: README hinzugefuegt"

# ===== Commit 10: Rabatt erhoeht =====
cat > receipt.py << 'PYEOF'
#!/usr/bin/env python3
import time

def generate_receipt(items, tax_rate=0.19, discount=0, shipping=0):
    subtotal = sum(item["price"] * item["qty"] for item in items)
    discount_amount = subtotal * discount
    # BUG: Steuer wird vom Brutto statt Netto berechnet
    tax = subtotal * tax_rate
    total = subtotal - discount_amount + shipping + tax
    return subtotal, discount_amount, shipping, tax, total

def print_line(label, value, currency, width=50):
    dots = "." * (width - len(label) - len(f"{value:.2f}") - 3)
    print(f"{label} {dots} {value:.2f} {currency}")

def main():
    customer_id = "K-2024-0042"
    currency = "EUR"
    items = [
        {"name": "Laptop Stand", "price": 49.99, "qty": 1},
        {"name": "USB-C Hub", "price": 34.99, "qty": 2},
        {"name": "Mauspad", "price": 19.99, "qty": 1},
    ]
    subtotal, discount, shipping, tax, total = generate_receipt(items, discount=0.10, shipping=4.99)

    print(f"Kunde: {customer_id}")
    print("=" * 54)
    print("              RECHNUNG")
    print("=" * 54)
    print()
    for item in items:
        print(f"  {item['qty']}x {item['name']:<20s} {item['price']:>8.2f} {currency}")
    print()
    print("-" * 54)
    print_line("Zwischensumme", subtotal, currency)
    print_line("Rabatt (10%)", discount, currency)
    print_line("Versand", shipping, currency)
    print_line("MwSt (19%)", tax, currency)
    print("=" * 54)
    print_line("GESAMTSUMME", total, currency)
    print()
    print(f"Datum: {time.strftime('%d.%m.%Y')}")

if __name__ == "__main__":
    main()
PYEOF
git add receipt.py && git commit -m "feat: Rabatt auf 10% erhoeht"

# ===== Tags setzen =====
git tag v0.1 HEAD~9
git tag v0.2 HEAD~7
git tag v0.3 HEAD~5
git tag v0.4 HEAD~3
git tag v1.0 HEAD

git tag good HEAD~9
git tag bad HEAD

# ===== Ausgabe =====
echo ""
echo "=== Repo mit $(git log --oneline | wc -l) Commits erstellt ==="
echo ""
git log --oneline
echo ""
echo "=== Der Bug ist in Commit 5 (Steuerberechnung optimiert) ==="
echo "    Die Steuer wird vom Brutto statt Netto berechnet."
echo "    python3 test_receipt.py schlaegt fehl."
echo ""

# Tar erstellen
cd "$SCRIPT_DIR"
rm -f start.tar.gz 2>/dev/null || true
rm -rf start 2>/dev/null || true
# In einen Unterordner receipt-app packen
tar czf start.tar.gz \
  --exclude='__pycache__' \
  --transform='s|^./|receipt-app/|' \
  -C "$BUILD_DIR" .
echo "start.tar.gz erstellt"
echo ""
echo "Verwendung:"
echo "cd /tmp && tar xzf pfad/zu/start.tar.gz && cd receipt-app"
echo "git bisect start good bad"
echo "git bisect run python3 bisect_test.py"
