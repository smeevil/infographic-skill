#!/usr/bin/env bash
# xai-auth.sh — xAI auth resolver for the infographic skill.
#
# Supports three credential sources, in priority order:
#   1. Skill-owned OAuth store   (~/.config/xai-oauth/tokens.json, via `login`)
#   2. Hermes agent OAuth store  (~/.hermes/auth.json, providers."xai-oauth")
#   3. XAI_API_KEY               (metered console.x.ai key)
#
# OAuth rides a SuperGrok / X Premium subscription (no API credits needed).
# Flow + constants mirror the open-source Hermes agent's xai-oauth provider
# (device-code flow against auth.x.ai; ~6h JWT access tokens; refresh 1h early).
#
# Commands:
#   status  — report which sources are available (never prints secrets)
#   login   — interactive device-code login; saves to the skill store
#   token   — print a valid OAuth access token (auto-refresh; exit 4 if none)
#   logout  — delete the skill-owned store
#
# Env:
#   XAI_OAUTH_STORE   override skill store path
#   HERMES_AUTH_JSON  override hermes auth.json path
#   XAI_LOGIN_NO_BROWSER=1  don't auto-open the verification URL
#
# Exit: 0 ok, 1 usage/config, 2 API error, 4 no oauth credentials

set -euo pipefail

ISSUER="https://auth.x.ai"
DISCOVERY_URL="$ISSUER/.well-known/openid-configuration"
DEVICE_CODE_URL="$ISSUER/oauth2/device/code"
CLIENT_ID="b1a00492-073a-47ea-816f-4c329264a828"
SCOPE="openid profile email offline_access grok-cli:access api:access"
REFRESH_SKEW_SECONDS=3600

STORE="${XAI_OAUTH_STORE:-$HOME/.config/xai-oauth/tokens.json}"
HERMES_AUTH="${HERMES_AUTH_JSON:-$HOME/.hermes/auth.json}"

die() { echo "error: $*" >&2; exit 1; }
api_die() { echo "api error: $*" >&2; exit 2; }

command -v jq >/dev/null || die "jq is required (brew install jq)"
command -v curl >/dev/null || die "curl is required"

b64d() { base64 -d 2>/dev/null || base64 -D; }

jwt_exp() {
  # Print the exp claim of a JWT, or 0 if undecodable.
  local payload pad
  payload=$(cut -d. -f2 <<<"$1" | tr '_-' '/+')
  pad=$(( (4 - ${#payload} % 4) % 4 ))
  [[ $pad -gt 0 && $pad -lt 4 ]] && payload="${payload}$(printf '=%.0s' $(seq 1 $pad))"
  printf '%s' "$payload" | b64d 2>/dev/null | jq -r '.exp // 0' 2>/dev/null || echo 0
}

token_is_fresh() {
  local exp now
  exp=$(jwt_exp "$1")
  now=$(date +%s)
  [[ "$exp" =~ ^[0-9]+$ ]] && (( exp - REFRESH_SKEW_SECONDS > now ))
}

token_endpoint() {
  local ep
  ep=$(curl -sS -H "Accept: application/json" "$DISCOVERY_URL" | jq -r '.token_endpoint // empty') || true
  [[ -n "$ep" && "$ep" == "$ISSUER"* ]] || ep="$ISSUER/oauth2/token"
  echo "$ep"
}

# --- source readers (emit compact JSON {access_token,refresh_token} or fail) ---

read_store_tokens() {
  [[ -f "$STORE" ]] || return 1
  jq -ce '.tokens | select(.access_token and .refresh_token and (.access_token|length>0) and (.refresh_token|length>0))' "$STORE" 2>/dev/null
}

read_hermes_tokens() {
  [[ -f "$HERMES_AUTH" ]] || return 1
  jq -ce '
    (.providers["xai-oauth"].tokens // empty
     | select(.access_token and .refresh_token and (.access_token|length>0) and (.refresh_token|length>0)))
    // ((.credential_pool["xai-oauth"] // [])
        | map(select(.access_token and .refresh_token and (.access_token|length>0) and (.refresh_token|length>0)))
        | first
        | select(. != null)
        | {access_token, refresh_token})
  ' "$HERMES_AUTH" 2>/dev/null
}

refresh_tokens() {
  # $1 = refresh_token → prints full token JSON payload on stdout
  local ep resp http
  ep=$(token_endpoint)
  resp=$(mktemp)
  http=$(curl -sS -o "$resp" -w "%{http_code}" -X POST "$ep" \
    -H "Content-Type: application/x-www-form-urlencoded" -H "Accept: application/json" \
    --data-urlencode "grant_type=refresh_token" \
    --data-urlencode "client_id=$CLIENT_ID" \
    --data-urlencode "refresh_token=$1") || { rm -f "$resp"; api_die "refresh curl failed"; }
  if [[ "$http" != "200" ]]; then
    local body; body=$(head -c 300 "$resp"); rm -f "$resp"
    if [[ "$http" == "403" ]]; then
      api_die "refresh HTTP 403 — this xAI account's tier may not allow OAuth API access ($body)"
    fi
    api_die "refresh HTTP $http — $body"
  fi
  cat "$resp"; rm -f "$resp"
}

save_store() {
  # $1 access, $2 refresh, $3 token_endpoint
  mkdir -p "$(dirname "$STORE")"
  local tmp; tmp=$(mktemp)
  jq -n --arg at "$1" --arg rt "$2" --arg ep "$3" \
    '{tokens:{access_token:$at,refresh_token:$rt,token_type:"Bearer"},
      token_endpoint:$ep,
      last_refresh:(now|todate)}' > "$tmp"
  mv "$tmp" "$STORE"
  chmod 600 "$STORE"
}

writeback_hermes() {
  # xAI rotates refresh tokens; after refreshing with Hermes' token we must
  # write the new pair back or Hermes' next refresh would fail.
  # $1 access, $2 refresh
  [[ -f "$HERMES_AUTH" ]] || return 0
  local tmp; tmp=$(mktemp)
  if jq --arg at "$1" --arg rt "$2" '
      if .providers["xai-oauth"].tokens then
        .providers["xai-oauth"].tokens.access_token = $at
        | .providers["xai-oauth"].tokens.refresh_token = $rt
        | .providers["xai-oauth"].last_refresh = (now|todate)
      else . end' "$HERMES_AUTH" > "$tmp" 2>/dev/null; then
    cp "$HERMES_AUTH" "$HERMES_AUTH.bak"
    mv "$tmp" "$HERMES_AUTH"
    chmod 600 "$HERMES_AUTH"
  else
    rm -f "$tmp"
    echo "warn: could not write refreshed tokens back to $HERMES_AUTH" >&2
  fi
}

# --- commands ---

cmd_status() {
  local found=0
  if read_store_tokens >/dev/null 2>&1; then
    local at; at=$(read_store_tokens | jq -r .access_token)
    if token_is_fresh "$at"; then echo "oauth (skill store): READY — $STORE"
    else echo "oauth (skill store): present, needs refresh — $STORE"; fi
    found=1
  else
    echo "oauth (skill store): not logged in — run: xai-auth.sh login"
  fi
  if read_hermes_tokens >/dev/null 2>&1; then
    local hat; hat=$(read_hermes_tokens | jq -r .access_token)
    if token_is_fresh "$hat"; then echo "oauth (hermes): READY — $HERMES_AUTH"
    else echo "oauth (hermes): present, needs refresh — $HERMES_AUTH"; fi
    found=1
  else
    echo "oauth (hermes): not found ($HERMES_AUTH)"
  fi
  if [[ -n "${XAI_API_KEY:-}" ]]; then
    echo "api-key (XAI_API_KEY): set (may need console.x.ai credits)"
    found=1
  else
    echo "api-key (XAI_API_KEY): not set"
  fi
  [[ $found -eq 1 ]] || return 4
}

cmd_token() {
  # Priority: skill store → hermes. Prints a fresh access token on stdout.
  local src tokens at rt payload new_at new_rt ep
  if tokens=$(read_store_tokens); then src="store"
  elif tokens=$(read_hermes_tokens); then src="hermes"
  else
    echo "no xAI OAuth credentials found (run: xai-auth.sh login)" >&2
    exit 4
  fi
  at=$(jq -r .access_token <<<"$tokens")
  rt=$(jq -r .refresh_token <<<"$tokens")
  if token_is_fresh "$at"; then
    printf '%s\n' "$at"
    return 0
  fi
  payload=$(refresh_tokens "$rt")
  new_at=$(jq -r '.access_token // empty' <<<"$payload")
  new_rt=$(jq -r '.refresh_token // empty' <<<"$payload")
  [[ -n "$new_at" ]] || api_die "refresh response missing access_token"
  [[ -n "$new_rt" ]] || new_rt="$rt"
  ep=$(token_endpoint)
  if [[ "$src" == "store" ]]; then
    save_store "$new_at" "$new_rt" "$ep"
  else
    writeback_hermes "$new_at" "$new_rt"
  fi
  printf '%s\n' "$new_at"
}

cmd_login() {
  local resp device_code user_code verify_uri verify_full expires_in interval ep
  resp=$(curl -sS -X POST "$DEVICE_CODE_URL" \
    -H "Content-Type: application/x-www-form-urlencoded" -H "Accept: application/json" \
    --data-urlencode "client_id=$CLIENT_ID" \
    --data-urlencode "scope=$SCOPE") || api_die "device-code request failed"
  device_code=$(jq -r '.device_code // empty' <<<"$resp")
  user_code=$(jq -r '.user_code // empty' <<<"$resp")
  verify_uri=$(jq -r '.verification_uri // empty' <<<"$resp")
  verify_full=$(jq -r '.verification_uri_complete // empty' <<<"$resp")
  expires_in=$(jq -r '.expires_in // 600' <<<"$resp")
  interval=$(jq -r '.interval // 5' <<<"$resp")
  [[ -n "$device_code" && -n "$user_code" ]] || api_die "device-code response invalid: $(head -c 300 <<<"$resp")"

  echo "To sign in with your SuperGrok / X Premium subscription:"
  echo
  echo "  Open:  ${verify_full:-$verify_uri}"
  echo "  Code:  $user_code"
  echo
  if [[ "${XAI_LOGIN_NO_BROWSER:-}" != "1" ]] && command -v open >/dev/null; then
    open "${verify_full:-$verify_uri}" 2>/dev/null || true
  fi

  ep=$(token_endpoint)
  local deadline now http err tokresp
  deadline=$(( $(date +%s) + expires_in ))
  echo "waiting for approval…"
  while true; do
    now=$(date +%s)
    (( now < deadline )) || api_die "timed out waiting for device authorization"
    tokresp=$(mktemp)
    http=$(curl -sS -o "$tokresp" -w "%{http_code}" -X POST "$ep" \
      -H "Content-Type: application/x-www-form-urlencoded" -H "Accept: application/json" \
      --data-urlencode "grant_type=urn:ietf:params:oauth:grant-type:device_code" \
      --data-urlencode "client_id=$CLIENT_ID" \
      --data-urlencode "device_code=$device_code") || { rm -f "$tokresp"; api_die "token poll curl failed"; }
    if [[ "$http" == "200" ]]; then
      local at rt
      at=$(jq -r '.access_token // empty' "$tokresp")
      rt=$(jq -r '.refresh_token // empty' "$tokresp")
      rm -f "$tokresp"
      [[ -n "$at" && -n "$rt" ]] || api_die "token response missing access/refresh token"
      save_store "$at" "$rt" "$ep"
      echo "login successful — tokens saved to $STORE"
      return 0
    fi
    err=$(jq -r '.error // empty' "$tokresp" 2>/dev/null || true)
    rm -f "$tokresp"
    case "$err" in
      authorization_pending) sleep "$interval" ;;
      slow_down) interval=$(( interval + 1 > 30 ? 30 : interval + 1 )); sleep "$interval" ;;
      *) api_die "device authorization failed: ${err:-HTTP $http}" ;;
    esac
  done
}

cmd_logout() {
  rm -f "$STORE" && echo "removed $STORE (hermes store untouched)"
}

case "${1:-}" in
  status) cmd_status ;;
  token) cmd_token ;;
  login) cmd_login ;;
  logout) cmd_logout ;;
  *) echo "usage: xai-auth.sh {status|login|token|logout}" >&2; exit 1 ;;
esac
