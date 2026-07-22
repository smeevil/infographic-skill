# Grok Imagine backend

This skill uses **Grok Imagine only** (xAI).

## Default model

| Model | Use |
|-------|-----|
| **`grok-imagine-image-quality`** | Default for all generation and edits (latest quality) |
| `grok-imagine-image` | Only if the user explicitly wants the cheaper/faster tier |

Do not use deprecated Flux or third-party model IDs.

## Native tools (Grok Build)

Session auth — no `XAI_API_KEY` required in the shell.

| Tool | Use |
|------|-----|
| `image_gen` | New image from text |
| `image_edit` | Edit / refine / multi-frame continuation |

```
image_gen(
  prompt = "<full constructed prompt>",
  aspect_ratio = "9:16"
)

image_edit(
  prompt = "Change X. Keep Y (layout, palette, title placement).",
  image = ["<absolute or session path to seed>"]
)
```

Copy outputs from the session `images/` dir into
`~/.agent/infographics/<slug>/` with consistent naming.

## REST API

| Field | Value |
|-------|-------|
| Generate | `POST https://api.x.ai/v1/images/generations` |
| Edit | `POST https://api.x.ai/v1/images/edits` |
| Auth | `Authorization: Bearer <token>` — OAuth access token or `XAI_API_KEY` |

### Generate body

```json
{
  "model": "grok-imagine-image-quality",
  "prompt": "<text>",
  "n": 1,
  "aspect_ratio": "9:16",
  "resolution": "1k",
  "response_format": "b64_json"
}
```

| Param | Values |
|-------|--------|
| `aspect_ratio` | `1:1`, `16:9`, `9:16`, `4:3`, `3:4`, `3:2`, `2:3`, `2:1`, `1:2`, `19.5:9`, `9:19.5`, `20:9`, `9:20`, `auto` |
| `resolution` | `1k` (draft default), `2k` (`--final`) |
| `response_format` | `b64_json` preferred; `url` is temporary — download immediately |
| `n` | up to 10 (this skill uses 1) |

### Edit body

```json
{
  "model": "grok-imagine-image-quality",
  "prompt": "Enlarge the title; shorten section body labels; keep layout and palette",
  "image": {
    "url": "data:image/jpeg;base64,...",
    "type": "image_url"
  }
}
```

Public HTTPS image URLs also work in `image.url`.

### Save helpers

```bash
# b64
jq -r '.data[0].b64_json' response.json | base64 --decode > out.png

# url
curl -sSL "$(jq -r '.data[0].url' response.json)" -o out.png
```

## Helper script

```bash
# Generate
./scripts/generate.sh \
  --out ~/.agent/infographics/demo/demo-infographic.png \
  --aspect 9:16 \
  --resolution 1k \
  --prompt-file prompt.txt

# Edit
./scripts/generate.sh \
  --edit ./demo-infographic.png \
  --out ~/.agent/infographics/demo/demo-infographic-edit-1.png \
  --prompt-file edit-prompt.txt
```

Exit codes: `0` ok, `1` usage/config, `2` API error, `3` rate limited after retry.

## Rate limits

- One request at a time (no parallel Imagine calls from this skill).
- On HTTP 429: sleep 10s, retry once; then exit 3.
- `--all-styles` and multi-frame are strictly sequential.

## Prompt notes for Grok Imagine

- Lead with subject; natural prose sections, not keyword spam.
- Front-load composition and style.
- Positive descriptions (what to include).
- Short on-image text; rich layout/icon description is fine at 400–800 words.
- Multi-frame / refine: seed prior image via `image_edit`, do not re-roll from scratch.
- Prefer `1k` while iterating; `2k` only for `--final`.

## Auth summary

Resolved by `scripts/generate.sh` via `scripts/xai-auth.sh` (`XAI_AUTH=auto|oauth|api-key`, default `auto` = OAuth first, key fallback):

| Environment | Auth |
|-------------|------|
| Grok Build tools | Logged-in session (no key export) |
| SuperGrok / X Premium subscription | OAuth device-code flow (`xai-auth.sh login`), tokens in `~/.config/xai-oauth/tokens.json` |
| Existing Hermes agent login | Auto-detected from `~/.hermes/auth.json` (`providers."xai-oauth"`); rotated refresh tokens are written back so Hermes stays valid |
| Metered key | `XAI_API_KEY` from [console.x.ai](https://console.x.ai) |

### OAuth flow details (mirrors Hermes' `xai-oauth` provider)

- Issuer `https://auth.x.ai`; device code `POST /oauth2/device/code`
  (form-encoded `client_id` + `scope`); token endpoint from OIDC discovery.
- Poll with `grant_type=urn:ietf:params:oauth:grant-type:device_code`;
  handle `authorization_pending` / `slow_down`.
- Access tokens are ~6h JWTs; refresh (form-encoded `grant_type=refresh_token`)
  proactively 1h before `exp`. Refresh tokens may rotate — always persist the
  returned pair.
- The bearer token works on all `api.x.ai/v1` surfaces including image
  generation/edits.
- Caveat: xAI sometimes gates OAuth API access to specific SuperGrok tiers —
  a 403 from the token or image endpoint with a valid login means
  tier-blocked, not broken auth.

`xai-auth.sh status` reports which sources are available without printing
secrets; `xai-auth.sh token` emits a fresh access token for scripting.
