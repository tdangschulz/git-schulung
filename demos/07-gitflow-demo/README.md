## Schnellstart

```bash
# Auspacken
cd /tmp
tar xzf pfad/zu/start.tar.gz
cd start

# Status: version.txt mit "v1.0", Tag v1.0.0 existiert, develop-Branch existiert und ist ausgecheckt
# Erster Befehl: Feature-Branch von develop aus anlegen
git switch -c feature/login
```

# GitFlow Demo

Demo des GitFlow-Branching-Modells (feature, develop, release, hotfix).

Start: `version.txt` mit "v1.0".

## Befehlsablauf

### Phase 1: Setup

1. **Initial-Commit**
   `git init && git add version.txt && git commit -m "Initial project setup"`
   `git tag v1.0.0`

2. **Develop-Branch**
   `git switch -c develop`

### Phase 2: Feature-Entwicklung

3. **Feature-Branch von develop**
   `git switch -c feature/login`
   `echo "print('login')" > login.py`
   `git add . && git commit -m "Add login feature"`

4. **Feature zurück nach develop mergen**
   `git switch develop`
   `git merge feature/login -m "Merge feature/login into develop"`

### Phase 3: Release

5. **Release-Branch vorbereiten**
   `git switch -c release/1.1.0 develop`
   `echo "v1.1.0" > version.txt`
   `git add . && git commit -m "Bump version to 1.1.0"`

6. **Release in main mergen**
   `git switch main`
   `git merge --no-ff release/1.1.0 -m "Merge release/1.1.0 into main"`
   `git tag v1.1.0`

### Phase 4: Hotfix

7. **Hotfix von main**
   `git switch -c hotfix/crash-fix main`
   `echo "crash-fix applied" > hotfix.txt`
   `git add . && git commit -m "Fix critical crash"`

8. **Hotfix in main + develop mergen**
   `git switch main && git merge --no-ff hotfix/crash-fix -m "Merge hotfix"`
   `git tag v1.1.1`
   `git switch develop && git merge --no-ff hotfix/crash-fix -m "Merge hotfix into develop"`

9. **Finale History**
   `git log --oneline --graph --all --decorate`
   → Erkennst du den Gitflow-Zyklus?
