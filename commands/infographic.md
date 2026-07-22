---
description: Generate a publication-quality IMAGE infographic (poster, whiteboard, diagram, mindmap, mockup) via Grok Imagine — not HTML
argument-hint: "[--style …] [--all-styles] [--edit last|PATH] [--source PATH] [--final] [--palette NAME] <content>"
---

Load the **infographic** skill (user skill `infographic` / `SKILL.md`), then generate an **image** for:

$@

Follow the skill workflow exactly (Grok Imagine only):

1. Parse flags (`--style`, `--all-styles`, `--edit`, `--source`, `--final`, `--palette`, multi-frame, etc.).
2. Do **not** produce HTML architecture pages — that is `visual-explainer`. This skill is image-only.
3. Analyze content; write `analysis.md` under `~/.agent/infographics/<slug>/`.
4. Build style prompt(s) with short on-image text budgets; archive each as `.prompt.txt`.
5. Generate **sequentially** with Grok Imagine (`image_gen` / REST, model `grok-imagine-image-quality`).
6. Verify the image; one edit-retry if unreadable.
7. On `--edit`, use `image_edit` / edits API from seed (or `.last.json`).
8. On `--final`, re-render at `2k`.
9. Write `companion.md`, `index.html` gallery, update `.last.json`; open gallery.

Default style: **infographic**. Default model: **grok-imagine-image-quality**.
