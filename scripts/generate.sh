#!/usr/bin/env bash
# generate.sh — Grok Imagine REST helper (generate + edit)
#
# Generate:
#   ./generate.sh --out out.png --aspect 9:16 < prompt.txt
# Edit:
#   ./generate.sh --edit seed.png --out out-edit.png < edit-prompt.txt
#
# Exit: 0 ok, 1 usage/config, 2 API error, 3 rate limited after retry

set -euo pipefail

OUT=""
ASPECT="9:16"
RESOLUTION="1k"
MODEL="grok-imagine-image-quality"
PROMPT_FILE=""
EDIT_IMAGE=""
N=1
MAX_RETRIES=1
RETRY_SLEEP=10

usage() {
  cat <<'EOF'
Usage:
  generate.sh --out PATH [options] < prompt.txt
  generate.sh --edit SEED --out PATH [options] < edit-prompt.txt

Options:
  --out PATH          output image path (required)
  --edit SEED         edit existing image (path or https URL)
  --prompt-file F     prompt from file instead of stdin
  --aspect A          aspect ratio for generate (default 9:16)
  --resolution R      1k | 2k (default 1k)
  --model M           default grok-imagine-image-quality
  --n N               variations (default 1; only first saved)

Env:
  XAI_API_KEY         required
  XAI_ENV_FILE        optional dotenv path
EOF
}

die() { echo "error: $*" >&2; exit 1; }
api_die() { echo "api error: $*" >&2; exit 2; }
rate_die() { echo "rate limited: $*" >&2; exit 3; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --out) OUT="${2:-}"; shift 2 ;;
    --edit) EDIT_IMAGE="${2:-}"; shift 2 ;;
    --aspect) ASPECT="${2:-}"; shift 2 ;;
    --resolution) RESOLUTION="${2:-}"; shift 2 ;;
    --model) MODEL="${2:-}"; shift 2 ;;
    --prompt-file) PROMPT_FILE="${2:-}"; shift 2 ;;
    --n) N="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown arg: $1" ;;
  esac
done

[[ -n "$OUT" ]] || { usage; die "--out is required"; }
command -v jq >/dev/null || die "jq is required (brew install jq)"
command -v curl >/dev/null || die "curl is required"

_load_env_file() {
  local f="$1"
  [[ -n "$f" && -f "$f" ]] || return 0
  # shellcheck disable=SC1090
  set -a; source "$f"; set +a
}
if [[ -z "${XAI_API_KEY:-}" ]]; then
  _load_env_file "${XAI_ENV_FILE:-}"
  _load_env_file "$HOME/.config/xai.env"
fi

# Auth resolution — XAI_AUTH = auto (default) | oauth | api-key.
# auto/oauth: prefer a subscription OAuth token (skill store or Hermes,
# via xai-auth.sh); auto falls back to XAI_API_KEY when no OAuth session.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUTH_MODE="${XAI_AUTH:-auto}"
AUTH_TOKEN=""
AUTH_SOURCE=""
case "$AUTH_MODE" in
  auto|oauth)
    if AUTH_TOKEN=$("$SCRIPT_DIR/xai-auth.sh" token 2>/dev/null); then
      AUTH_SOURCE="oauth"
    elif [[ "$AUTH_MODE" == "oauth" ]]; then
      die "XAI_AUTH=oauth but no OAuth session (run: xai-auth.sh login)"
    fi
    ;;
  api-key) ;;
  *) die "invalid XAI_AUTH: $AUTH_MODE (auto|oauth|api-key)" ;;
esac
if [[ -z "$AUTH_TOKEN" ]]; then
  [[ -n "${XAI_API_KEY:-}" ]] || die "no xAI auth: run scripts/xai-auth.sh login (subscription) or set XAI_API_KEY"
  AUTH_TOKEN="$XAI_API_KEY"
  AUTH_SOURCE="api-key"
fi
echo "auth: $AUTH_SOURCE" >&2

if [[ -n "$PROMPT_FILE" ]]; then
  [[ -f "$PROMPT_FILE" ]] || die "prompt file not found: $PROMPT_FILE"
  PROMPT=$(cat "$PROMPT_FILE")
else
  if [[ -t 0 ]]; then
    die "pass prompt on stdin or via --prompt-file"
  fi
  PROMPT=$(cat)
fi
[[ -n "${PROMPT// /}" ]] || die "empty prompt"

mkdir -p "$(dirname "$OUT")"
TMPDIR_GEN=$(mktemp -d)
trap 'rm -rf "$TMPDIR_GEN"' EXIT
RESP="$TMPDIR_GEN/response.json"
PROMPT_JSON="$TMPDIR_GEN/prompt.json"
printf '%s' "$PROMPT" | jq -Rs . > "$PROMPT_JSON"

# Build request
if [[ -n "$EDIT_IMAGE" ]]; then
  ENDPOINT="https://api.x.ai/v1/images/edits"
  if [[ "$EDIT_IMAGE" == https://* || "$EDIT_IMAGE" == http://* || "$EDIT_IMAGE" == data:* ]]; then
    IMAGE_URL="$EDIT_IMAGE"
  else
    [[ -f "$EDIT_IMAGE" ]] || die "edit seed not found: $EDIT_IMAGE"
    MIME="image/png"
    case "$EDIT_IMAGE" in
      *.jpg|*.jpeg|*.JPG|*.JPEG) MIME="image/jpeg" ;;
      *.webp|*.WEBP) MIME="image/webp" ;;
    esac
    B64=$(base64 -i "$EDIT_IMAGE" 2>/dev/null || base64 "$EDIT_IMAGE")
    IMAGE_URL="data:${MIME};base64,${B64}"
  fi
  BODY=$(jq -n \
    --arg model "$MODEL" \
    --rawfile prompt "$PROMPT_JSON" \
    --arg url "$IMAGE_URL" \
    '{
      model: $model,
      prompt: ($prompt | fromjson),
      image: { url: $url, type: "image_url" },
      response_format: "b64_json"
    }')
else
  ENDPOINT="https://api.x.ai/v1/images/generations"
  BODY=$(jq -n \
    --arg model "$MODEL" \
    --rawfile prompt "$PROMPT_JSON" \
    --arg aspect "$ASPECT" \
    --arg res "$RESOLUTION" \
    --argjson n "$N" \
    '{
      model: $model,
      prompt: ($prompt | fromjson),
      aspect_ratio: $aspect,
      resolution: $res,
      n: $n,
      response_format: "b64_json"
    }')
fi

attempt=0
while true; do
  HTTP=$(curl -sS -o "$RESP" -w "%{http_code}" \
    -X POST "$ENDPOINT" \
    -H "Authorization: Bearer $AUTH_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$BODY") || api_die "curl failed"

  if [[ "$HTTP" == "200" ]]; then
    break
  fi
  if [[ "$HTTP" == "403" ]]; then
    if [[ "$AUTH_SOURCE" == "api-key" ]]; then
      api_die "HTTP 403 — API key rejected (team may lack console.x.ai credits; try OAuth: scripts/xai-auth.sh login) — $(head -c 300 "$RESP")"
    fi
    api_die "HTTP 403 — OAuth token rejected (xAI may gate image API access to specific SuperGrok tiers) — $(head -c 300 "$RESP")"
  fi
  if [[ "$HTTP" == "429" && "$attempt" -lt "$MAX_RETRIES" ]]; then
    echo "rate limited (429); sleeping ${RETRY_SLEEP}s then retry…" >&2
    sleep "$RETRY_SLEEP"
    attempt=$((attempt + 1))
    continue
  fi
  if [[ "$HTTP" == "429" ]]; then
    rate_die "HTTP 429 — $(head -c 400 "$RESP")"
  fi
  api_die "HTTP $HTTP — $(head -c 500 "$RESP")"
done

B64=$(jq -r '.data[0].b64_json // empty' "$RESP")
if [[ -n "$B64" ]]; then
  printf '%s' "$B64" | base64 --decode > "$OUT"
else
  URL=$(jq -r '.data[0].url // empty' "$RESP")
  [[ -n "$URL" ]] || api_die "no image in response: $(head -c 500 "$RESP")"
  curl -sSL "$URL" -o "$OUT" || api_die "download failed"
fi

[[ -s "$OUT" ]] || api_die "output file empty: $OUT"

# Archive prompt next to output when possible
PROMPT_OUT="${OUT%.*}.prompt.txt"
printf '%s\n' "$PROMPT" > "$PROMPT_OUT"

echo "wrote $OUT ($(wc -c < "$OUT" | tr -d ' ') bytes)"
echo "prompt $PROMPT_OUT"
