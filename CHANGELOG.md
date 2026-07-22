# Changelog

## 0.3.0 — 2026-07-22

### Added

- **xAI OAuth (subscription) auth** — `scripts/xai-auth.sh` implements the
  SuperGrok / X Premium device-code flow against `auth.x.ai` (same client as
  the open-source Hermes agent): `login`, `token` (auto-refresh, ~6h JWTs,
  1h-early refresh), `status`, `logout`. Tokens stored in
  `~/.config/xai-oauth/tokens.json` (0600).
- **Existing-session detection** — reuses a Hermes agent login from
  `~/.hermes/auth.json` (`providers."xai-oauth"`, incl. `credential_pool`
  entries) when present; rotated refresh tokens are written back so the
  Hermes session stays valid.
- **Auth resolution in `generate.sh`** — `XAI_AUTH=auto|oauth|api-key`
  (default `auto`: OAuth first, `XAI_API_KEY` fallback); prints the resolved
  `auth:` source; targeted 403 hints (missing console credits vs
  OAuth tier-gating).

## 0.2.0 — 2026-07-22

Major rewrite. Hosted as [smeevil/infographic-skill](https://github.com/smeevil/infographic-skill).

Adapted from [ericblue/visual-explainer-skill](https://github.com/ericblue/visual-explainer-skill) (image-generation skill); backends and workflow replaced.

### Breaking

- **Grok Imagine only** — removed Runware, OpenAI, and Gemini backends
- Default model: **`grok-imagine-image-quality`**
- Skill name / triggers emphasize **infographic images**, not HTML diagrams (no collision with `visual-explainer`)

### Added

- **Post-gen verify** (Step 5b) with one targeted edit-retry for unreadable results
- **`--edit PATH|last`** iteration via `image_edit` / edits API + `.last.json` sidecar
- **`--final`** resolution ladder (`1k` draft → `2k` ship)
- **`--all-styles`** sequential multi-style generation (rate-limit safe)
- **`--source PATH`** and soft project README sniff for “explain this project”
- **`--palette`** aesthetic presets
- **Prompt archive** (`*.prompt.txt` next to every image)
- **`analysis.md` always saved** before generation
- **Gallery `index.html`** per slug folder (shareable artifact)
- **Consistent naming:** `~/.agent/infographics/<slug>/<slug>-<style>.ext`
- **Multi-frame = base then edit** (not independent re-rolls)
- **Sequential generation** + 429 retry once
- Style **text budgets** (short on-image labels; prose in companion)
- Anti-slop rules for image aesthetics
- `scripts/generate.sh` generate + edit + prompt archive
- `install.sh` + slash command `commands/infographic.md`
- `references/gallery-template.html`

### Removed

- Runware MCP / REST paths
- OpenAI `gpt-image-*` and Gemini backends from the original skill

### Kept / refined

- Seven styles: infographic, whiteboard, presentation, diagram, mindmap, mindmap-structured, mockup
- Mermaid input parsing
- Style prompt templates (with stricter text budgets)

## 0.1.0 — 2026-07-22

Initial private conversion: dual Grok Imagine + Runware backends, global Claude install.
