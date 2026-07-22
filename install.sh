#!/usr/bin/env bash
# Install the infographic skill into Claude Code (user-global).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
DEST="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills/infographic}"
CMD_DEST="${CLAUDE_COMMANDS_DIR:-$HOME/.claude/commands}"

mkdir -p "$DEST/references" "$DEST/scripts" "$CMD_DEST"

cp "$ROOT/SKILL.md" "$ROOT/README.md" "$ROOT/CHANGELOG.md" "$ROOT/LICENSE" "$DEST/"
cp -R "$ROOT/references/." "$DEST/references/"
cp -R "$ROOT/scripts/." "$DEST/scripts/"
chmod +x "$DEST/scripts/"*.sh 2>/dev/null || true
cp "$ROOT/commands/infographic.md" "$CMD_DEST/infographic.md"

echo "Installed skill → $DEST"
echo "Installed slash  → $CMD_DEST/infographic.md"
echo "Use: /infographic <topic>"
