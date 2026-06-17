## Schnellstart

```bash
# Auspacken
cd /tmp
tar xzf pfad/zu/start.tar.gz
cd start

# Status: Repo mit index.html + style.css, auf main, kein Branch außer main
# Alles bereits committed — Arbeitsverzeichnis sauber
# Erster Befehl: Branch für neues Feature anlegen
git switch -c feature/menu
```

# Galaktische Pizza

Ein HTML/CSS-Projekt für das GitHub-Schulungstraining.

Enthält:
- `index.html` – vollständiges HTML-Grundgerüst mit Header, Navigation und Footer
- `style.css` – CSS-Styling mit radial-gradient, goldenem h1 und Footer

## Befehlsablauf — Branches & Merges

### Grundlagen

1. **Initial-Commit**
   `git init && git add . && git commit -m "Initial commit: Pizza-Website Grundstruktur"`

2. **Neuen Branch erstellen & wechseln**
   `git switch -c feature/menu`

3. **Menü-Sektion hinzufügen**
   Füge vor dem `</main>` Tag folgendes HTML ein:
   ```html
   <section id="menu">
       <h2>Unsere Speisekarte</h2>
       <ul>
           <li>🌌 Milchstraßen-Margherita — 12 Credits</li>
           <li>🪐 Saturn-Salami — 15 Credits</li>
           <li>☄️ Asteroid-Ananas (nur im Andromeda-Galaxy) — 18 Credits</li>
       </ul>
   </section>
   ```

4. **Committen**
   `git add . && git commit -m "Add menu section with galactic pizzas"`

5. **Zurück zu main**
   `git switch main`

6. **Feature-Branch mergen (Fast-Forward)**
   `git merge feature/menu`
   → Warum war das ein Fast-Forward? Antwort: main hatte keine eigenen Commits.

### 3-Way Merge

7. **Neuen Branch erstellen**
   `git switch -c feature/contact`

8. **Kontakt-Sektion in index.html einfügen**
   ```html
   <section id="contact">
       <h2>Kontakt</h2>
       <p>Lieferzonen: Mars, Mond, Saturn</p>
       <p>Hyperraum-Telefon: +++-///-1234-5678</p>
   </section>
   ```
   Committen: `git add . && git commit -m "Add contact section"`

9. **Jetzt auf main eine Änderung machen**
   `git switch main`
   Aktualisiere das Copyright-Jahr in der Footer-Zeile, z.B. von 2123 auf 2170.
   `git add . && git commit -m "Update copyright year"`

10. **Merge — jetzt 3-Way!**
    `git merge feature/contact`
    → Jetzt gibt es einen Merge-Commit! Warum? Weil beide Branches auseinander gelaufen sind.

11. **History vergleichen**
    `git log --oneline --graph --all`

## ⚠️ Typische Praxisprobleme

**❗ Auf dem falschen Branch committed:** Du bist auf \`main\`, willst aber auf \`feature/xyz\`.
→ Lösung: \`git switch -c feature/xyz\`, dann Commit ist da. \`git switch main\` und \`git reset --hard HEAD~1\` zum Bereinigen.

**❗ Fast-Forward nicht möglich:** \`git merge feature/xyz\` macht einen 3-Way-Merge, weil main eigene Commits hat.
→ Kein Fehler! Aber wenn du lineare History willst: vorher \`git rebase main\` im Feature-Branch.

**❗ Merge-Konflikt beim 3-Way-Merge:** Beide Branches haben die gleiche Zeile geändert.
→ \`cat datei.txt\` zeigt \`<<<<<<<\` Markierungen. Manuell auflösen, dann \`git add datei.txt && git commit\`
