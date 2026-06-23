# Demo 12: ReReRe — Merge-Konflikte automatisieren

**Ziel:** Lerne, wie Git sich **einmal gelöste Merge-Konflikte merkt**
und beim nächsten Mal **automatisch wieder anwendet** — ohne dass du
wieder Hand anlegen musst.

## Theorie

### Was ist git rerere?

`rerere` = **Re**use **Re**corded **Re**solution.

Git speichert, wie du einen Merge-Konflikt gelöst hast, und wendet
dieselbe Lösung beim nächsten Auftreten desselben Konflikts automatisch an.

```
┌─────────────────────────────────────────────────────────┐
│                   Merge #1                               │
│                                                          │
│  main: "version = 1.5"    feature/v2: "version = 2.0"   │
│         \                      /                         │
│          \  ┌──────────────┐ /                           │
│           ─▶│  KONFLIKT!   │◀─                           │
│             └──────┬───────┘                             │
│                    ▼                                     │
│         Du löst: "version = 2.0"                        │
│                    │                                     │
│                    ▼                                     │
│         Rerere speichert die Lösung 🧠                  │
│                                                          │
│                   Merge #2 (nach Reset)                  │
│                                                          │
│  main: "version = 1.5"    feature/v2: "version = 2.0"   │
│         \                      /                         │
│          \  ┌──────────────┐ /                           │
│           ─▶│  KONFLIKT!  │◀─                            │
│             └──────┬───────┘                             │
│                    ▼                                     │
│         Rerere löst automatisch 🎉                        │
│         → kein manuelles Eingreifen nötig                 │
└─────────────────────────────────────────────────────────┘
```

### Wann braucht man das?

| Situation | Ohne rerere | Mit rerere |
|---|---|---|
| Rebase mit mehreren Konflikten | Jeden Konflikt **immer wieder** lösen | Nur **einmal** lösen, Rest automatisch |
| Cherry-Pick-Serie | Gleicher Konflikt bei jedem Pick | Auto-gelöst ab dem 2. Mal |
| Topic-Branch oft rebasen | Jedes Rebase = alle Konflikte neu | Einmal gelöst = für immer erledigt |
| Changelog / Versionsnummer | Jeder Merge = gleicher Konflikt | Rerere kennt die Lösung |

### Wie aktiviert man rerere?

```bash
# Für das aktuelle Repo:
git config rerere.enabled true

# Global (empfohlen für alle Repos):
git config --global rerere.enabled true
```

> **💡 Tipp:** Einmal global aktivieren und nie wieder manuell lösen.
> Rerere stört nicht — es greift nur ein, wenn es eine passende
> Lösung gespeichert hat.

---

## 🖥️ Live-Demo

### Setup — Das Start-Repo

```bash
cd demos/12-rerere-demo/start

git log --oneline --graph --all
```

```
* 03eaf8b Bump version to 2.0       ← feature/v2
| * 1884dee Bump version to 1.5     ← main
|/
* 1883456 Initial                    ← gemeinsamer Vorfahr
```

Zwei Branches, beide haben `version.txt` geändert — **Konflikt vorprogrammiert**.

```bash
cat version.txt
# → version = 1.5
# → author = Team
```

```bash
git show feature/v2:version.txt
# → version = 2.0
# → author = Team
```

**Ausgangslage:**
- `main`: `version = 1.5`
- `feature/v2`: `version = 2.0`
- Merge → Konflikt in der ersten Zeile von `version.txt`

---

### Demo A: Erster Merge — Konflikt lösen, Rerere lernt

**Ziel:** Rerere aktivieren, Merge ausführen, Konflikt lösen —
Rerere speichert die Lösung.

```bash
# Rerere aktivieren
git config rerere.enabled true
```

**Prüfen ob rerere aktiv ist:**
```bash
git config rerere.enabled
# → true
```

---

**Merge ausführen (erzeugt Konflikt):**

```bash
git merge feature/v2
```

```
Auto-merging version.txt
CONFLICT (content): Merge conflict in version.txt
Automatic merge failed; fix conflicts and then commit the result.
```

**Konflikt ansehen:**
```bash
cat version.txt
```

```
<<<<<<< HEAD
version = 1.5
=======
version = 2.0
>>>>>>> feature/v2
author = Team
```

---

**Konflikt lösen — Version auf 2.0 setzen:**

```bash
echo "version = 2.0" > version.txt
echo "author = Team" >> version.txt

git add version.txt
git commit --no-edit
```

```
[main abc1234] Merge branch 'feature/v2'
```

**🎯 Das ist der Moment:** Rerere hat sich die Lösung gemerkt!

**Prüfen:**
```bash
git rerere status
# → version.txt  ← Rerere hat die Datei im Cache
```

```bash
git rerere diff
# → zeigt die gemerkte Konfliktlösung
```

**Wo speichert Rerere?**
```bash
ls .git/rr-cache/
# → 1234abcd...  ← hash-basierter Ordner
```

```bash
cat .git/rr-cache/*/preimage
# → Der Konflikt (VOR der Lösung)
cat .git/rr-cache/*/postimage
# → Die Lösung (NACH dem Auflösen)
```

---

**🔍 Prüfen: Merge-Ergebnis**

```bash
cat version.txt
# → version = 2.0
# → author = Team
```

```bash
git log --oneline --graph --all
# → Merge-Commit sichtbar
```

---

**👣 Schritt für Schritt — Was Git intern macht:**

| Schritt | Was passiert | Sichtbar? |
|---|---|---|
| **1. `rerere.enabled true`** | Git aktiviert den Rerere-Cache in `.git/rr-cache/` | Ja — `git config` zeigt `true` |
| **2. `git merge feature/v2`** | Git merged, findet Konflikt in `version.txt` | Ja — „CONFLICT (content)" |
| **3. Preimage speichern** | Git speichert den **Zustand VOR** dem Lösen (`preimage`): die Konflikt-Marker mit beiden Versionen | Ja — `cat .git/rr-cache/*/preimage` |
| **4. Du löst den Konflikt** | Du editiert `version.txt`, führst `git add` + `git commit` aus | Ja |
| **5. Postimage speichern** | Git vergleicht gelöstes Ergebnis mit Preimage, speichert den Unterschied als `postimage` | Ja — `cat .git/rr-cache/*/postimage` |
| **6. Merge-Commit** | Fertiger Merge-Commit | Ja — im Log |

---

**🗣️ Zu erklären:**

> **Rerere speichert die Konfliktlösung beim ersten Merge. Beim zweiten
> Mal kennt Git die Antwort schon und wendet sie automatisch an.**

---

### Demo B: Zweiter Merge — Rerere löst automatisch

**Ziel:** Den Merge rückgängig machen, erneut mergen — Rerere
wendet die gespeicherte Lösung automatisch an.

---

**Merge rückgängig machen:**

```bash
git reset --hard HEAD~1
```

```bash
cat version.txt
# → version = 1.5  ← wieder Ausgangszustand!
```

**Prüfen:**
```bash
git log --oneline --graph --all
# → Merge-Commit weg, main ist wieder auf "Bump version to 1.5"
```

---

**Merge erneut ausführen:**

```bash
git merge feature/v2
```

```
Auto-merging version.txt
CONFLICT (content): Merge conflict in version.txt
Resolved 'version.txt' using previous resolution.
Automatic merge failed; fix conflicts and then commit the result.
```

**🎯 Der entscheidende Unterschied zu Demo A:**

> `Resolved 'version.txt' using previous resolution.`
>
> Rerere hat die Lösung WIEDERGEKANNT und AUTOMATISCH ANGEWENDET!

**Konflikt prüfen:**
```bash
cat version.txt
# → version = 2.0      ← Schon gelöst!
# → author = Team
```

Keine Konflikt-Marker mehr! Kein manuelles Editieren. Git hat alles
automatisch erledigt.

---

**Merge abschließen:**

```bash
git add version.txt
git commit --no-edit
```

**Prüfen:**
```bash
cat version.txt
# → version = 2.0
# → author = Team
```

---

**👣 Schritt für Schritt — Was Git diesmal anders macht:**

| Schritt | Was passiert |
|---|---|
| **1. `merge feature/v2`** | Gleicher Konflikt wie in Demo A |
| **2. Preimage prüfen** | Git checkt: „Hab ich diesen Konflikt schonmal gesehen?" |
| **3. Cache-Hit** | Ja! Der Hash des Preimages existiert in `.git/rr-cache/` |
| **4. Postimage anwenden** | Git wendet die gespeicherte Lösung (`postimage`) automatisch auf `version.txt` an |
| **5. Meldung** | `Resolved 'version.txt' using previous resolution.` |
| **6. Du commitest nur noch** | `git add` + `git commit` — fertig |

---

**🗣️ Zu erklären:**

> **Rerere erkennt den Konflikt am Inhalt (Hash des Preimages).
> Gleicher Konflikt → gleiche Lösung. Punkt.**
>
> **Du brauchst nur noch `git add` + `git commit`. Das Editieren
> entfällt komplett.**

---

### Demo C: Rerere-Cache verwalten

**Ziel:** Gespeicherte Lösungen ansehen, kontrollieren, löschen.

---

**Alle gespeicherten Konflikte anzeigen:**

```bash
git rerere status
# → version.txt  ← Aktuell gemerkte Konflikte
```

---

**Konflikt-Diff anzeigen (was wurde gelernt?):**

```bash
git rerere diff
```

Zeigt den Unterschied zwischen Preimage und Postimage —
also genau das, was Rerere beim nächsten Mal automatisch anwendet.

---

**Bestimmte Datei aus dem Cache entfernen:**

```bash
git rerere forget version.txt
```

Danach: Rerere behandelt den Konflikt beim nächsten Mal **frisch** —
du musst wieder manuell lösen.

---

**Kompletten Cache löschen:**

```bash
git rerere clear
```

**Oder direkt das Filesystem:**
```bash
rm -rf .git/rr-cache/
```

Beides entfernt alle gespeicherten Lösungen. Nächster Konflikt =
wieder manuell lösen (und Rerere lernt neu).

---

**Gespeicherte Daten direkt im Filesystem:**

```bash
ls .git/rr-cache/
# → 1234abcd...  ← ein Ordner pro gemerktem Konflikt
```

```bash
# Was war der Konflikt? (VOR der Lösung)
cat .git/rr-cache/*/preimage
# version = 1.5 … version = 2.0

# Was ist die gespeicherte Lösung? (NACH dem Lösen)
cat .git/rr-cache/*/postimage
# version = 2.0
```

---

**🗣️ Zu erklären:**

> **`git rerere status/diff/clear/forget` = dein Werkzeugkasten für den
> Rerere-Cache. Normalerweise musst du da nie ran — aber wenn mal
> eine falsche Lösung gespeichert wurde, kannst du sie einfach löschen.**

---

### Demo D: Rerere ohne vorherige Aktivierung

**Problem:** Du hast einen Merge-Konflikt gelöst, aber Rerere war
**nicht aktiviert**. Die Lösung ist verloren — oder?

**Die gute Nachricht:** Das Skript `git-rerere-train.sh` kann
**rückwirkend** aus bestehenden Merge-Commits lernen!

```bash
# Rerere jetzt aktivieren (zu spät — der Merge ist schon durch)
git config rerere.enabled true

# Aus bestehenden Merges lernen
/usr/share/git/contrib/rerere-train.sh
# → Durchläuft alle Merge-Commits und speichert deren Lösungen
```

**Wo liegt das Skript?**
```bash
find / -name "rerere-train.sh" 2>/dev/null
# → /usr/share/doc/git/contrib/rerere-train.sh  (Debian/Ubuntu)
# → /usr/local/share/git-core/contrib/rerere-train.sh  (macOS)
```

> **Ohne das Skript:** Nächster `git reset` + `git merge` →
> Konflikt kommt wieder. Aber dann mit aktiviertem Rerere → wird
> für die Zukunft gemerkt.

---

### Demo E: Rerere beim Rebase

**Ziel:** Derselbe Konflikt tritt mehrfach beim Rebase auf —
Rerere löst ihn automatisch beim 2., 3., 4. Mal.

---

**Setup — Drei Commits auf feature/v2, alle mit Konflikt:**

```bash
git switch feature/v2
echo "change A" > changes.txt
git add . && git commit -m "Change A"

echo "change B" > changes.txt
git add . && git commit -m "Change B"

echo "change C" > changes.txt
git add . && git commit -m "Change C"
```

```bash
git log --oneline main..feature/v2
# → (1) Change C
# → (2) Change B
# → (3) Change A
# → (4) Bump version to 2.0
```
---

**Rebase — Jeder Commit erzeugt denselben Konflikt:**

```bash
git rebase main
```

```
# Commit 1 (Bump version to 2.0):
#   CONFLICT → lösen → git add → git rebase --continue

# Commit 2 (Change A):
#   CONFLICT → RERERE LÖST AUTOMATISCH!
```

**👣 Was passiert beim Rebase:**

| Rebase-Step | Konflikt? | Rerere? |
|---|---|---|
| Pick 1: `Bump version to 2.0` | ✅ Konflikt in `version.txt` | Neu lernen (du löst) |
| Pick 2: `Change A` | ✅ Gleicher Konflikt | Auto-lösen 🎉 |
| Pick 3: `Change B` | ✅ Gleicher Konflikt | Auto-lösen 🎉 |
| Pick 4: `Change C` | ✅ Gleicher Konflikt | Auto-lösen 🎉 |

**Du löst den Konflikt nur EINMAL, Rerere macht den Rest automatisch.**

---

**Warum ist das so mächtig?**

Ohne Rerere beim Rebase mit 10 Commits:

```
pick a1b2c3 → Konflikt → lösen → add → continue
pick d4e5f6 → Konflikt → lösen → add → continue  ← schon wieder!
pick g7h8i9 → Konflikt → lösen → add → continue  ← und nochmal!
```

Mit Rerere:
```
pick a1b2c3 → Konflikt → lösen → add → continue
pick d4e5f6 → Konflikt → RERERE → add → continue  ← kein Editieren!
pick g7h8i9 → Konflikt → RERERE → add → continue  ← wieder nicht!
```

---

**🗣️ Zu erklären:**

> **Rebase ist Rereres glänzendste Stunde. Jeder gepickte Commit
> kann denselben Konflikt auslösen — Rerere löst ihn ab dem 2. Mal
> automatisch. Das spart bei größeren Rebase-Serien richtig Zeit.**

---

### Vollständige Demo (alles in einem Durchlauf)

```bash
# === Setup ===
cd demos/12-rerere-demo/start
git config rerere.enabled true
cat version.txt   # → version = 1.5

# === 1) Erster Merge → Rerere lernt ===
git merge feature/v2 || true
cat version.txt   # → Konflikt-Marker
echo "version = 2.0" > version.txt
echo "author = Team" >> version.txt
git add version.txt
git commit --no-edit

git rerere status
git rerere diff

# === 2) Zweiter Merge → Rerere löst automatisch ===
git reset --hard HEAD~1
cat version.txt   # → wieder 1.5!

git merge feature/v2
# → "Resolved 'version.txt' using previous resolution."

cat version.txt   # → version = 2.0, schon gelöst!
git add version.txt
git commit --no-edit

# === 3) Rerere-Cache verwalten ===
git rerere status           # → version.txt
git rerere forget version.txt  # → vergessen
git rerere clear               # → komplett löschen

# === 4) Rerere-Cache im Filesystem ===
ls .git/rr-cache/           # leer (nach clear)
```

---

## 🔍 Zusammenfassung

| Befehl | Wirkung |
|---|---|
| `git config rerere.enabled true` | Rerere aktivieren (global empfohlen) |
| `git merge <branch>` (1. Mal) | Konflikt lösen → Rerere lernt |
| `git merge <branch>` (2. Mal) | Rerere löst automatisch |
| `git rerere status` | Gemerkte Konflikte anzeigen |
| `git rerere diff` | Gemerkte Lösung als Diff zeigen |
| `git rerere forget <datei>` | Einzelne Datei aus Cache entfernen |
| `git rerere clear` | Kompletten Cache löschen |
| `rerere-train.sh` | Rückwirkend aus bestehenden Merges lernen |

**Die goldene Regel:**

> **`git config --global rerere.enabled true`** — einmal aktivieren,
> nie wieder manuell denselben Konflikt lösen. Besonders beim Rebase
> und Cherry-Pick-Serien unschlagbar.

---

## 📚 Weiterführend

- [`git-rerere`](https://git-scm.com/docs/git-rerere) in der Git-Manpage
- [`rerere-train.sh`](https://github.com/git/git/tree/master/contrib/rerere-train.sh) — rückwirkend lernen
- Rerere-Cache im Filesystem: `.git/rr-cache/`
