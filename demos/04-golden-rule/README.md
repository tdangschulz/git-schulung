## Schnellstart

```bash
# Auspacken
cd /tmp
tar xzf pfad/zu/start.tar.gz
cd start

# Status: file.txt mit "Initial", auf main, Remote zeigt auf ../central.git
# central.git existiert im selben Ordner wie start/
# Erster Befehl: Zwei Klone erstellen (simuliert zwei Entwickler)
git clone . /tmp/dev-a && git clone . /tmp/dev-b
```

# Golden Rule of Rebasing

Demo zur Goldenen Regel: "Rebase niemals öffentliche Commits, die andere bereits haben."

Start: `file.txt` mit "Initial".

## Übungsaufgaben

### Setup: Zwei Entwickler, ein Feature-Branch

1. **Initial-Commit**
   `git init && git add file.txt && git commit -m "Initial"`

2. **Zwei Klone erstellen** (simuliert zwei Entwickler)
   `git clone . /tmp/dev-a && git clone . /tmp/dev-b`

3. **Dev A: Feature-Branch anlegen + pushen**
   `cd /tmp/dev-a`
   `git switch -c feature/neu`
   `echo "Dev-A Feature" > feature.txt`
   `git add . && git commit -m "Dev-A feature"`
   `git push origin feature/neu`

4. **Dev B: Feature-Branch holen + eigenen Commit machen**
   `cd /tmp/dev-b`
   `git fetch origin && git switch feature/neu`
   `echo "Dev-B Ergänzung" >> feature.txt`
   `git add . && git commit -m "Dev-B changes on feature"`
   `git push origin feature/neu`

### ❌ Der verbotene Rebase

5. **Dev A: Rebase + Force-Push (Verboten!)**
   `cd /tmp/dev-a && git switch feature/neu`
   `git rebase main`
   `git push --force-with-lease origin feature/neu`

6. **Dev B holt — und sieht Chaos**
   `cd /tmp/dev-b && git fetch origin`
   `git log --oneline --graph --all`
   → Dev-Bs Commit ist weg! Was ist passiert?

### Wiederherstellung

7. **Dev B findet seinen Commit im Reflog**
   `git reflog`
   `git cherry-pick <hash-des-verlorenen-commits>`

8. **Lektion:** Wann darf man rebasen? → Nur auf privaten, ungepush ten Branches!
