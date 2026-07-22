# Infographic skill (Grok Imagine)

Claude Code / Grok Build **skill** that generates publication-quality **image**
infographics — posters, whiteboards, keynote slides, technical diagrams, mind
maps, and UI mockups — using **Grok Imagine** only.

> **Not HTML.** For self-contained HTML architecture pages, diff reviews, and
> browser diagrams, use a separate **visual-explainer** skill. This repo is for
> **images**.

**Version:** 0.2.0  
**Default model:** `grok-imagine-image-quality`

## Origin

Adapted from
[ericblue/visual-explainer-skill](https://github.com/ericblue/visual-explainer-skill)
(the image-generation skill that targeted OpenAI / Gemini). We rewrote the
workflow for Grok Imagine, verification, iteration, galleries, and sharing.

## What’s new in 0.2 (vs the original / our 0.1)

| Area | Change |
|------|--------|
| Backend | **Grok Imagine only** (dropped OpenAI, Gemini, Runware) |
| Model | Pin **`grok-imagine-image-quality`** (latest quality) |
| Quality | Post-gen **verify** + one **edit** retry if unreadable |
| Iteration | **`--edit last\|PATH`** with `.last.json` |
| Resolution | Draft **1k** → **`--final` 2k** |
| Batch | **`--all-styles`** sequential (rate-limit safe) |
| Sourcing | **`--source`**, project README sniff |
| Artifacts | **Gallery `index.html`**, **prompt archive**, **analysis.md** |
| Naming | `~/.agent/infographics/<slug>/<slug>-<style>.ext` |
| Multi-frame | Frame 1 generate → frames 2–N **edit from seed** |
| Scope | Explicitly **infographic images** — no HTML skill collision |
| Text | Style **text budgets** so posters stay readable |

Full history: [CHANGELOG.md](./CHANGELOG.md).

## Install (Claude Code)

```bash
git clone https://github.com/smeevil/infographic-skill.git
cd infographic-skill
./install.sh
```

This copies into:

- `~/.claude/skills/infographic/` — skill + references + scripts  
- `~/.claude/commands/infographic.md` — slash command  

Restart or refresh Claude Code if skills don’t hot-reload.

### Manual

```bash
mkdir -p ~/.claude/skills/infographic ~/.claude/commands
cp -R SKILL.md README.md CHANGELOG.md LICENSE references scripts \
  ~/.claude/skills/infographic/
chmod +x ~/.claude/skills/infographic/scripts/generate.sh
cp commands/infographic.md ~/.claude/commands/
```

## Usage

```
/infographic How DNS resolution works
/infographic --style whiteboard React component lifecycle
/infographic --all-styles Ragnarok's Path overview
/infographic --source README.md --style diagram
/infographic --edit last Make the title larger; shorter bullets
/infographic --final --style presentation Q3 strategy
/infographic --mode multi-frame The water cycle
/infographic --palette nordic-editorial Morale system
```

### Styles

`infographic` (default) · `whiteboard` · `presentation` · `diagram` ·
`mindmap` · `mindmap-structured` · `mockup`

### Auth

| Environment | Auth |
|-------------|------|
| **Grok Build** | Session tools `image_gen` / `image_edit` (no key export) |
| **Claude Code / CLI** | `export XAI_API_KEY=...` from [console.x.ai](https://console.x.ai) |

No OAuth client ships in this skill.

### REST helper

```bash
export XAI_API_KEY=xai-...

./scripts/generate.sh \
  --out ~/.agent/infographics/demo/demo-infographic.png \
  --aspect 9:16 \
  --resolution 1k \
  --prompt-file prompt.txt

# Iterate
./scripts/generate.sh \
  --edit ~/.agent/infographics/demo/demo-infographic.png \
  --out ~/.agent/infographics/demo/demo-infographic-edit-1.png \
  --prompt-file edit.txt
```

## Output layout

```
~/.agent/infographics/<slug>/
├── index.html              # shareable gallery
├── analysis.md
├── companion.md
├── .last.json
├── <slug>-infographic.jpg
├── <slug>-infographic.prompt.txt
└── …
```

Zip the slug folder to share as an artifact.

## Repo layout

```
SKILL.md                 # agent workflow (source of truth)
README.md
CHANGELOG.md
LICENSE
install.sh
commands/infographic.md  # Claude slash command
references/
  backends.md
  style-templates.md
  gallery-template.html
scripts/
  generate.sh            # REST generate + edit
```

## Related

- [ericblue/visual-explainer-skill](https://github.com/ericblue/visual-explainer-skill) — original inspiration (OpenAI/Gemini image skill)
- HTML **visual-explainer** skills (e.g. nicobailon-style) — use those for browser HTML diagrams, not this repo

## License

MIT — see [LICENSE](./LICENSE). Original visual-explainer skill concepts used under MIT-style adaptation; this tree is a new work focused on Grok Imagine.
