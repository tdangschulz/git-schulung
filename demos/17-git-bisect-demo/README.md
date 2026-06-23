# Demo 17: Git Bisect — Den Schuldigen finden

**Ziel:** Lerne, wie `git bisect` per binärer Suche den genauen Commit
findet, der einen Bug eingeschleust hat — auch bei 100+ Commits.

## Theorie

### Was ist Git Bisect?

Git Bisect ist eine **binäre Suche durch die Commit-Historie**.
Du markierst einen bekannten **guten** Commit (vor dem Bug) und einen
bekannten **schlechten** Commit (mit Bug). Git checkt dann einen Commit
nach dem anderen aus, halbiert die verbleibende Menge und du testest
jedes Mal: „Ist der Bug hier drin oder nicht?"

```
Schritte bei binärer Suche:
─────────────────────────────────────────
10 Commits → max 4 Schritte
100 Commits → max 7 Schritte
1000 Commits → max 10 Schritte
─────────────────────────────────────────
```

### Warum ist das mächtig?

- **Kein Rumraten:** Du musst nicht wissen wo der Bug steckt
- **Automatisierbar:** `git bisect run <script>` erledigt alles
- **Reproduzierbar:** Jeder findet denselben Commit
- **Genaue Ursache:** Nicht „irgendwann letzte Woche", sondern
  der exakte Commit + Diff

---

## 🖥️ Live-Demo

> **Szenario:** Eine Rechnungs-App entwickelt sich über 10 Commits.
> Bei Commit 5 wurde ein Bug eingebaut: die **Mehrwertsteuer wird
> vom Brutto statt Netto** berechnet. Eine Test-Person hat den Bug
> erst viel später bemerkt (Commit 10).

### Setup

```bash
# Auspacken
cd /tmp
tar xzf pfad/zu/17-git-bisect-demo/start.tar.gz
cd receipt-app
```

**Historie ansehen:**
```bash
git log --oneline --all
```

```
0fab76d feat: Rabatt auf 10% erhoeht       ← HEAD (schlecht)
5430b0e docs: README hinzugefuegt
2fe3128 feat: Kunden-Nummer und Datum
61ed29d feat: Versandkosten-Funktion
4200ed9 test: Unit-Tests fuer Rechnung
5ac10ba refactor: Steuerberechnung optimiert  ← BUG!
e4c06b2 feat: Waehrung als Variable
6c07cf4 refactor: Formatierte Ausgabe
bbc7071 feat: Rabatt-Funktion hinzugefuegt
ccbc714 feat: Rechnungs-Grundstruktur       ← erster Commit (gut)
```

**Tags prüfen:**
```bash
git tag -l
# → good, bad, v0.1, v0.2, ...
```

### Demo A: Manuelle binäre Suche

**Schritt 1: Bisect starten**

```bash
git bisect start bad good
```

Ausgabe:
```
Bisecting: 4 revisions left to test after this (roughly 2 steps)
```

Git hat auf halber Strecke einen Commit ausgecheckt:
```
2fe3128 feat: Kunden-Nummer und Datum
```

**Schritt 2: Testen — ist der Bug hier?**

```bash
python3 receipt.py
# → Sieh dir die MwSt an. Ist sie korrekt?
```

Hier zeigt `receipt.py` **falsche Steuer** (19.00 statt 17.10).
→ Also ist dieser Commit **schlecht** (enthält den Bug).

```bash
git bisect bad
```

Git checkt den nächsten Commit aus:
```
6c07cf4 refactor: Formatierte Ausgabe
```

**Schritt 3: Wieder testen**

```bash
python3 receipt.py
```

Hier ist die Steuer **korrekt** (17.10).
→ Also ist dieser Commit **gut** (Bug noch nicht da).

```bash
git bisect good
```

**Schritt 4: Test + Ergebnis**

```
5ac10ba refactor: Steuerberechnung optimiert is the first bad commit
```

Git hat den Bug gefunden! Genau Commit 5.

```bash
git show 5ac10ba
# → Zeigt genau die geänderte Code-Zeile mit dem Bug
```

**Schritt 5: Aufräumen**

```bash
git bisect reset
```

---

### Demo B: Automatisch mit `git bisect run`

Ab Commit 1 existiert ein Test-Skript `bisect_test.py`, das automatisch
prüft ob die Steuer korrekt ist. Damit kannst du die ganze Suche
**in einem Befehl** erledigen:

```bash
git bisect start bad good
git bisect run python3 bisect_test.py
```

Git checkt aus, führt das Skript aus, wertet den Exit-Code aus
und wiederholt bis der Schuldige gefunden ist.

```
Bisecting: 4 revisions left to test after this (roughly 2 steps)
running  'python3' 'bisect_test.py'
Bisecting: 1 revision left to test after this (roughly 1 step)
running  'python3' 'bisect_test.py'
Bisecting: 0 revisions left to test after this (roughly 0 steps)
running  'python3' 'bisect_test.py'
5ac10ba is the first bad commit
```

**Exit-Codes für `git bisect run`:**

| Code | Bedeutung |
|---|---|
| `0` | Commit ist **gut** (Bug nicht vorhanden) |
| `1` | Commit ist **schlecht** (Bug vorhanden) |
| `125` | Commit **überspringen** (z.B. nicht kompilierbar) |

---

### Demo C: Bug beheben und prüfen

Nachdem der Bug gefunden wurde, kannst du ihn fixen und mit
einem normalen Commit bestätigen:

```bash
# Zum fixen auf den Bug-Commit schauen
git show 5ac10ba

# Fix: tax = (subtotal - discount_amount) * tax_rate
# Statt: tax = subtotal * tax_rate
```

Dann mit `git bisect log` die Suche dokumentieren:

```bash
git bisect log
```

---

## 🔍 Zusammenfassung

| Befehl | Wirkung |
|---|---|
| `git bisect start <bad> <good>` | Binäre Suche starten |
| `git bisect good` | Aktueller Commit ist gut |
| `git bisect bad` | Aktueller Commit ist schlecht |
| `git bisect run <script>` | Automatische Suche |
| `git bisect skip` | Commit überspringen |
| `git bisect reset` | Suche beenden, zu HEAD zurück |
| `git bisect log` | Such-Protokoll anzeigen |
| `git bisect visualize` | Visuelle Darstellung der Suche |

**Die goldene Regel:**
> `git bisect run` braucht ein Skript das in ALLEN Commits der Suche
> existiert und mit Exit-Code 0/1/125 antwortet.
> Für die manuelle Suche reicht `git bisect good/bad`.

---

## 📚 Weiterführend

- [`git-bisect` Manpage](https://git-scm.com/docs/git-bisect)
- [Git Bisect im Einsatz — Atlassian](https://www.atlassian.com/git/tutorials/git-bisect)
- `git bisect visualize` nutzt `gitk` oder `git log` für die visuelle Darstellung
