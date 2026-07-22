---
name: infographic
description: >
  Generate publication-quality IMAGE infographics with Grok Imagine — posters,
  whiteboards, presentation slides, technical diagrams, mind maps, and UI
  mockups. Use when the user asks for an infographic, image poster, whiteboard
  sketch image, mind-map image, keynote-style slide image, or wireframe mockup
  image; or runs /infographic. Defaults to Grok Imagine (latest quality model).
  Do NOT use this skill for self-contained HTML diagrams, architecture HTML
  pages, diff reviews, or browser-viewable technical docs — those belong to the
  separate visual-explainer skill.
argument-hint: "[--style infographic|whiteboard|presentation|diagram|mindmap|mindmap-structured|mockup] [--all-styles] [--edit PATH|last] [--source PATH] [--palette NAME] [--final] [--draw-level sketch|normal|polished] [--complexity simple|moderate|detailed] [--mode single|multi-frame] <content>"
metadata:
  version: "0.2.0"
  author: smeevil
  adapted-from: https://github.com/ericblue/visual-explainer-skill
---

# Infographic (Grok Imagine)

Generate a **single image** (or a small set of images) that visually explains a
topic. Prompt craft is the product. Backend is **Grok Imagine only**.

**Default style:** `infographic`.

Adapted from
[ericblue/visual-explainer-skill](https://github.com/ericblue/visual-explainer-skill)
(image-generation skill). Completely reworked for Grok Imagine, verification,
iteration, galleries, and project-aware sourcing.

> **Not HTML.** This skill never writes architecture HTML pages or Mermaid-in-browser
> diagrams. For pixel-perfect text, real data charts, or shareable HTML explainers,
> use the separate **`visual-explainer`** skill. Use **this** skill when visual
> impact and illustrative clarity matter more than typographic precision.

> **Accuracy note.** Image models still garble dense body copy. Prefer short
> labels, big numbers, and icons in the image; put long prose in the companion
> markdown (always saved next to the image).

---

## Usage

```
/infographic How DNS resolution works
/infographic --style whiteboard React component lifecycle
/infographic --style mindmap OOP principles
/infographic --all-styles Ragnarok's Path overview
/infographic --source README.md --style diagram
/infographic --edit last Make the title larger and drop section 6
/infographic --final --style presentation Q3 strategy
/infographic --mode multi-frame The water cycle
/infographic --palette nordic-editorial --style infographic Morale system
```

---

## Arguments

Parse free text / `$ARGUMENTS`. Flags are optional.

| Flag | Default | Description |
|------|---------|-------------|
| `--style S` | `infographic` | One of the 7 styles (ignored if `--all-styles`) |
| `--all-styles` | off | Generate every style sequentially (rate-limit safe) |
| `--edit PATH\|last` | off | Iterate on an existing image instead of generating from scratch |
| `--source PATH` | off | Read a file (README, plan, design doc) before analysis |
| `--palette NAME` | auto | Aesthetic preset (see Palettes) |
| `--final` | off | After a good draft, re-render at `resolution: 2k` |
| `--device D` | `mobile` | Mockup only: `mobile`, `desktop`, `tablet` |
| `--draw-level L` | `normal` | `sketch`, `normal`, `polished` |
| `--complexity C` | `moderate` | `simple` (3–4), `moderate` (5–7), `detailed` (8–12) |
| `--aspect A` | style default | `1:1`, `16:9`, `9:16`, `4:3`, `3:4`, `3:2`, `2:3`, `2:1`, `1:2`, `auto` |
| `--output DIR` | `~/.agent/infographics/<slug>/` | Output directory (created) |
| `--prefix NAME` | slug | Filename prefix (usually the content slug) |
| `--mode M` | `single` | `single` or `multi-frame` (3–5 progressive frames) |
| `--from F` | (none) | `mermaid` or `mermaid-file PATH` |
| `--model M` | `grok-imagine-image-quality` | Override model id |
| `--resolution R` | `1k` (draft) / `2k` with `--final` | Grok Imagine resolution |
| `--skip-verify` | off | Skip post-gen image inspection (not recommended) |
| `--no-open` | off | Do not open images/gallery in the browser |

Everything after flags is the **content** to visualize. If empty and no
`--edit` / `--source`, ask what to visualize and stop.

### Auto style from free text (when `--style` omitted)

| User language | Style |
|---|---|
| keynote, slide, pitch slide | `presentation` |
| whiteboard, sketch the idea, classroom | `whiteboard` |
| architecture, system diagram, flowchart, sequence | `diagram` |
| mind map, mindmap, brainstorm map | `mindmap` |
| structured mind map, org map, XMind | `mindmap-structured` |
| wireframe, mockup, HUD, UI layout | `mockup` |
| infographic, poster, explainer image (default) | `infographic` |

---

## Naming & output layout

Derive a short **slug** from the title (kebab-case, max ~48 chars), e.g.
`ragnaroks-path-overview`.

```
~/.agent/infographics/<slug>/
├── index.html                 # gallery (always when ≥1 image)
├── analysis.md                # Step 2 analysis (always)
├── companion.md               # human summary for sharing
├── .last.json                 # pointer for --edit last
├── <slug>-infographic.jpg
├── <slug>-infographic.prompt.txt
├── <slug>-whiteboard.jpg
├── <slug>-whiteboard.prompt.txt
├── ...
├── <slug>-presentation-frame-1.jpg   # multi-frame
└── <slug>-presentation-final-2k.jpg  # --final pass
```

**Consistent filenames:**

| Kind | Pattern |
|------|---------|
| Single style | `<slug>-<style>.<ext>` |
| Multi-frame | `<slug>-<style>-frame-<n>.<ext>` |
| Final 2k pass | `<slug>-<style>-final-2k.<ext>` |
| Prompt archive | same stem + `.prompt.txt` |
| Edit iteration | `<slug>-<style>-edit-<n>.<ext>` |

Copy Grok Build `images/N.jpg` results into this folder with the names above.
Never leave the only copy inside a session temp path.

---

## Workflow

### Step 0 — Resolve mode

1. If `--edit last`: read `~/.agent/infographics/**/.last.json` (most recent
   mtime) or the slug the user names.
2. If `--edit PATH`: use that image as the seed.
3. If `--source PATH`: read the file; content = source text + user notes.
4. If in a git repo and content is vague (“explain this project”) and no
   `--source`, try `README.md` then `docs/README.md` as soft context.
5. Derive **title** + **slug**. Create output dir.

### Step 1 — Backend (Grok Imagine only)

Priority:

1. **Grok Build** with native `image_gen` / `image_edit` tools → use them
2. Else REST via `scripts/generate.sh`, which resolves auth itself
   (`XAI_AUTH=auto|oauth|api-key`, default `auto`):
   1. **xAI OAuth** (SuperGrok / X Premium subscription — no API credits
      needed): the skill's own store (`~/.config/xai-oauth/tokens.json`)
      or a detected **Hermes agent** session (`~/.hermes/auth.json`).
      Inspect with `scripts/xai-auth.sh status`; sign in with
      `scripts/xai-auth.sh login` (browser device-code flow).
   2. **`XAI_API_KEY`** → metered console.x.ai key as fallback.
3. Else stop:

```
No Grok Imagine backend available.

  • In Grok Build: image_gen should work without a key (session auth).
  • Subscription: scripts/xai-auth.sh login   # SuperGrok / X Premium OAuth
  • Or metered:  export XAI_API_KEY="xai-..." # console.x.ai
```

**Default model:** `grok-imagine-image-quality` (latest quality Imagine model).
Do not use deprecated Flux aliases.

Report immediately (generate.sh prints the resolved `auth:` source):

```
Backend: Grok Imagine (image_gen tool) — model grok-imagine-image-quality
Backend: Grok Imagine REST (oauth) — model grok-imagine-image-quality
Backend: Grok Imagine REST (api-key) — model grok-imagine-image-quality
```

Full API shapes: `./references/backends.md`.

### Step 1b — Mermaid input (optional)

If `--from mermaid`, `--from mermaid-file PATH`, or content contains Mermaid
fences / diagram keywords, parse structure first (nodes, edges, subgraphs,
title). Map to a style only when the user did not set `--style` (see table in
previous version: flowchart→diagram, mindmap→mindmap, gantt/pie→infographic).

**Every node → labeled visual; every edge → connection.** Mermaid prompts must
be more detailed, not less.

### Step 2 — Analyze (always write `analysis.md`)

Write and **save** to `<out>/analysis.md` before any image call:

1. **Title** / **Slug**
2. **Core Concept**
3. **Key Sub-Topics** (count from complexity)
4. **Relationships**
5. **Visual Metaphors**
6. **Layout Strategy**
7. **Color Coding** (+ palette name if set)
8. **Text budget** (style-specific — see below)
9. **Styles to generate** (one or all)

### Step 3 — Build prompt(s)

Read `./references/style-templates.md`. Fill the template. Prompts are
typically **400–800 words**, but **on-image text stays short**:

| Style | On-image text budget |
|-------|----------------------|
| presentation | Title + ≤5 bullets of ≤8 words each |
| mindmap / mindmap-structured | Node labels ≤5 words |
| diagram | Node labels ≤4 words; edge labels ≤3 words |
| whiteboard | Short phrases; doodle-friendly |
| infographic | Section titles + ≤3 short bullets each; big numbers OK |
| mockup | UI chrome labels only |

Put longer explanation in `companion.md`, not on the canvas.

**Prompt rules:** spatial positions, specific icons, exact short labels, named
colors (hex), typography, connections, background, eye-flow, mood.
Checklist at end of this file.

**Anti-slop (forbidden in prompts and results):**
- Inter/Roboto as “the” look + violet/indigo gradients
- Cyan–magenta–pink neon on black
- Emoji as section headers
- Animated glow language, mesh gradient blobs
- Walls of paragraph text on the image

### Step 4 — Multi-frame (if requested)

**Required pattern for consistency:**

1. Generate **frame 1** with `image_gen` (or REST).
2. Frames **2–N** via `image_edit` / edits API, seeding frame 1 (or previous
   frame). Prompt: what is added; what must stay (palette, layout grid, title).
3. Each prompt states `frame X of Y`.
4. Sequential only — never parallel multi-frame.

Warn the user: N frames ≈ N API calls.

### Step 5 — Generate

#### Aspect defaults

| Style | Aspect |
|-------|--------|
| infographic | `9:16` |
| whiteboard | `16:9` |
| presentation | `16:9` |
| diagram | `1:1` |
| mindmap | `16:9` |
| mindmap-structured | `16:9` |
| mockup mobile/tablet | `9:16` |
| mockup desktop | `16:9` |

Resolution: **`1k`** by default. Use **`2k`** only with `--final` (or after
verify when the user asks for a final pass).

#### Sequential generation (rate limits)

- **Never** fire more than one Imagine request in parallel.
- Between jobs (especially `--all-styles`): brief pause if a 429 was seen.
- On **HTTP 429**: wait ~8–15s, retry **once**, then report and stop the batch
  gracefully (keep successful images).

#### Grok Build tools

```
image_gen(prompt=..., aspect_ratio="9:16")
image_edit(prompt=..., image=["<path>"])   # refine / multi-frame
```

Then **copy** the returned session path into
`<out>/<slug>-<style>.jpg` (or appropriate name).

#### REST

```bash
./scripts/generate.sh \
  --out ~/.agent/infographics/<slug>/<slug>-infographic.png \
  --aspect 9:16 \
  --resolution 1k \
  --prompt-file prompt.txt
```

Always write `<stem>.prompt.txt` next to the image (full prompt archive).

#### `--edit` path

Skip full regen. Load seed image + prior analysis if present. Build a **short
edit prompt** (what changes; what stays). Call `image_edit` or edits API.
Save as `<slug>-<style>-edit-<n>.ext` and update `.last.json`.

#### `--final` path

Take the verified draft image (or last good edit) and either:

- re-generate with same prompt at `resolution: 2k`, or
- prefer edit-upscale only if the API path supports it; otherwise re-gen at 2k
  with the archived prompt.

Save as `<slug>-<style>-final-2k.ext`.

### Step 5b — Verify (default on)

Unless `--skip-verify`:

1. Inspect the image (vision / `Read` on the image file).
2. Check: title readable? required sections present? labels not gibberish?
   layout not collapsed? nothing critical clipped?
3. If **major** failure (unreadable title, missing half the sections):
   - One targeted `image_edit` retry (“fix illegible text in header; keep layout”), **or**
   - For dense technical accuracy needs, tell the user HTML `visual-explainer`
     is the better tool and stop retry spam.
4. If **minor** issues: note them in companion; offer `--edit last`.
5. Infographic style is most prone to unreadable body text — prefer fixing via
   edit toward shorter labels rather than regenerating the same dense prompt.

### Step 6 — Gallery, companion, last pointer

1. Write/update `companion.md` (structured summary — see below).
2. Write/update `index.html` gallery listing every image in the slug folder
   (thumbnails or full-width figures, style labels, links to prompt/analysis).
   Self-contained CSS; no build step. Good to zip/share as an artifact.
3. Write `.last.json`:

```json
{
  "slug": "ragnaroks-path-overview",
  "title": "Ragnarok's Path Overview",
  "style": "infographic",
  "image": "/absolute/path/to/file.jpg",
  "prompt_file": "/absolute/path/to/file.prompt.txt",
  "analysis_file": "/absolute/path/to/analysis.md",
  "model": "grok-imagine-image-quality",
  "resolution": "1k",
  "updated_at": "ISO-8601"
}
```

4. Open gallery (`open index.html`) unless `--no-open`.
5. Suggest refinements: `--edit last …`, other styles, `--final`, or HTML
   visual-explainer for precision docs.

### Companion format

```markdown
## Infographic: [Title]

**Style(s):** … | **Backend:** Grok Imagine | **Model:** grok-imagine-image-quality
**Draw level:** … | **Complexity:** … | **Palette:** … | **Resolution:** …

### Sections
1. **…** — …
…

### Key Relationships
- A → B: …

### Files
- Gallery: `…/index.html`
- Analysis: `…/analysis.md`
- Images: …
```

---

## Palettes

| Name | Feel |
|------|------|
| `nordic-editorial` | Charcoal navy, parchment cream, frost teal, ember amber |
| `paper-ink` | Warm cream `#faf7f5`, terracotta, sage |
| `blueprint` | Slate/blue technical, monospace labels, grid |
| `terminal-mono` | Green/amber on near-black |
| `midnight-pitch` | Near-black, cream type, single gold accent (presentation) |
| `clean-wireframe` | White, charcoal, blue interactive (mockup) |

If omitted, pick one that fits the content and **name it in analysis.md**.
Vary over time; do not default every run to purple neon.

---

## Style selection guide

| Content shape | Prefer |
|---|---|
| Educational poster, numbered steps | **infographic** |
| Fun classroom explanation | whiteboard |
| One bold keynote moment | presentation |
| Process / architecture / sequence | diagram |
| Hierarchical, creative | mindmap |
| Hierarchical, business | mindmap-structured |
| UI / HUD / PRD layout | mockup |
| “Give me every view” | `--all-styles` |

Templates: `./references/style-templates.md`.

---

## Prompt quality checklist

- [ ] Canvas / background
- [ ] Title + styling
- [ ] Spatial layout
- [ ] Sections within complexity + **short** labels (text budget)
- [ ] Specific icons (not generic)
- [ ] Connections
- [ ] Palette with concrete names/hex
- [ ] Typography
- [ ] Style-appropriate decoration (not slop)
- [ ] Mood / feel
- [ ] ≥ 300 words of prompt detail (layout/icons), even if on-image text is sparse

---

## Error handling

- Missing content → ask
- No auth outside Grok Build → offer `scripts/xai-auth.sh login` (subscription
  OAuth) or `XAI_API_KEY` setup instructions
- 403 on api-key → team has no console.x.ai credits; suggest the OAuth path
- 403 on oauth → xAI may gate API access to specific SuperGrok tiers;
  re-login won't help — suggest `XAI_API_KEY` or a subscription upgrade
- Missing `jq` on REST path → `brew install jq`
- Moderation block → report; do **not** rephrase to evade
- 429 → wait, retry once, then stop batch with partial results
- Over-dense content → suggest lower complexity or HTML visual-explainer
- Unreadable infographic after verify → edit toward less text or switch style

---

## Notes

- **Grok Imagine only** — no Runware/OpenAI/Gemini in this skill.
- Model default: **`grok-imagine-image-quality`** (latest quality).
- Draft at **1k**, ship with **`--final`** → **2k**.
- Sequential generation protects team rate limits.
- Always archive **prompt + analysis** next to images.
- Prefer `image_edit` for iteration and multi-frame consistency.
- For exact architecture docs, hand off to **`visual-explainer`** (HTML).
