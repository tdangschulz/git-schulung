## Schnellstart

```bash
# Auspacken
cd /tmp
tar xzf pfad/zu/start.tar.gz
cd start

# Status: file.txt mit "start" auf main
# Zwei Feature-Branches existieren bereits: feature/moin (gruess.txt) und feature/hello (greetings.txt)
# Beide sind UNGEMERGED — bereit zum Üben verschiedener Merge-Strategien!
# Erster Befehl: Merge-Strategie testen
git merge --no-ff feature/moin -m "Merge feature/moin"
```

# Merge-Strategien

Demo verschiedener Merge-Strategien: --no-ff, --ff-only, --squash.

Start: `file.txt` mit "start".

## Befehlsablauf

### Setup: Zwei Feature-Branches

1. **Initial-Commit**
   `git init && git add file.txt && git commit -m "Initial"`

2. **Feature 1 erstellen**
   `git switch -c feature/moin`
   `echo "Hallo Welt!" > gruess.txt`
   `git add . && git commit -m "Add German greeting"`

3. **Feature 2 erstellen (von main aus)**
   `git switch main`
   `git switch -c feature/hello`
   `echo "Hello World!" > greetings.txt`
   `git add . && git commit -m "Add English greeting"`

### Strategie 1: --no-ff (erzwungener Merge-Commit)

4. `git switch main`
   `git merge --no-ff feature/moin -m "Merge feature/moin"`
   `git log --oneline --graph`
   → Siehst du den Merge-Commit?

### Strategie 2: --squash (alles in einen Commit)

5. `git merge --squash feature/hello`
   `git status` → Änderungen sind staged
   `git commit -m "Add English greeting (squashed)"`
   `git log --oneline --graph`
   → Keine Branch-History mehr! Die beiden Feature-Commits wurden zu einem.

### Strategie 3: --ff-only (nur Fast-Forward erlauben)

6. `git switch -c feature/hi main`
   `echo "Hi!" > hi.txt && git add . && git commit -m "Add casual greeting"`
   `git switch main`
   `git merge --ff-only feature/hi`
   → Klappt weil main keine eigenen Commits hat.

7. **Jetzt mit Konflikt testen** (optional)
   `git switch main && echo "A change" >> file.txt && git commit -m "Change on main"`
   `git merge --ff-only feature/hello` → **Fehler!** Kein Fast-Forward möglich.

### Vergleich

| Strategie | Merge-Commit | History | Wann nehmen? |
|---|---|---|---|
| `--no-ff` | Ja | Sichtbarer Merge | Features, Releases |
| `--squash` | Nein | Linear | Kleine Fixes |
| `--ff-only` | Nein | Linear | Nur bei sauberer Basis |

## ⚠️ Typische Praxisprobleme

**❗ --squash vergessen:** 15 Zwischen-Commits landen auf main statt einem sauberen.
→ \`git merge --squash feature/branch\` für kleine Fixes.

**❗ --ff-only schlägt fehl:** Weil main parallel weiterentwickelt wurde.
→ Feature-Branch vorher rebasen: \`git rebase main\`, dann \`git merge --ff-only\`.

**❗ --no-ff auf main:** Erzeugt Merge-Commits auch bei Fast-Forward-Möglichkeit.
→ Das ist der Standard für PRs, aber nicht auf jedem Branch sinnvoll.
