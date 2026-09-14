# christine-preuss.de — Portfolio

Static Hugo site for artist Christine Preuß. Clean white/black design in IBM Plex
Mono, all fonts/images/videos served by the site itself (no third-party assets).
Config comes from Nix (`flake.nix` → generated `hugo.toml`); **content** is plain
files you can edit.

## Where things live

```
data/                 → ARBEITEN, VITA, KONTAKT (YAML text, easy to edit)
content/projekte/     → project pages (one folder per project)
assets/img/art/       → artwork images (full-resolution originals)
assets/css, assets/js → site chrome (CSS + vanilla JS)
layouts/              → templates (baseof, index, single)
flake.nix             → site config; generates hugo.toml
```

## Preview & build

```bash
nix develop            # enter the devshell (links hugo.toml)
hugo server            # live preview at http://localhost:1313/

nix build              # production build → result/
nix flake check        # run tests/hooks/format checks
```

`hugo.toml` is generated from `flake.nix` — don't edit it by hand. To change
site config (title, baseURL, image quality…), edit `flake.nix`.

## Add a new artwork (ARBEITEN)

1. Drop the image into `assets/img/art/` (full resolution is fine — Hugo
   Pipes builds the responsive srcset + lightbox versions).
2. Add an entry **at the top** of `data/art.yaml` (newest first, manual order):

```yaml
- title: "Ohne Titel"
  date: "2024-03-01"
  year: "2024"
  medium: "Öl auf Leinwand"
  size: "195 × 165 cm"        # optional
  src: "mein-bild.jpg"
```

Keep German prose in YAML as `|` literal blocks so the `yamlfmt` formatter
doesn't collapse your text.

## Add a new project (PROJEKTE)

1. Create a folder `content/projekte/<name>/` with an `index.md`:

```yaml
---
title: "Projektname"
date: 2024-01-01
params:
  year: "2024"          # shown as the page date
---
Text (Markdown)…

```

2. Put images/videos **in the same folder** as sidecar resources:
   - Video: `<name>.mp4` — add `<name>.jpg` for a poster frame.
   - Photos: any `.jpg`/`.png` besides the poster → shown as a gallery with
     lightbox.
3. That's it — the project link appears **automatically** in the nav, sorted
   alphabetically, because `baseof.html` lists everything under
   `content/projekte/`.

## Edit VITA / KONTAKT

- `data/vita.yaml` — `lede` (intro), `cv` (Werdegang), `selected`
  (Ausstellungen/Projekte).
- `data/contact.yaml` — name, e-mail, address (placeholders — still to verify).

## Navigation

The ARBEITEN / VITA / PROJEKTE / KONTAKT groups are hand-written HTML in
`layouts/_default/baseof.html`. The **items inside a group** (project links) are
auto-listed from the content folders. To add a new section (e.g. PUBLIKATIONEN),
clone the PROJEKTE `<button class="group">…</button>` + `<div class="sublist">`
block, point it at the new section, and generalize the `proj-toggle`/`proj-sublist`
toggle in `assets/js/main.js` to handle multiple groups.

## Commits

- One logical change per commit (atomic).
- Conventional Commits (e.g. `fix:`, `feat:`, `style:`) — enforced by the
  `convco` pre-commit hook; never bypass hooks.
- Never push — the user decides what leaves the machine.
