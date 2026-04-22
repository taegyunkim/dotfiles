#!/usr/bin/env zsh
# Install Claude Code configuration.
#  - Merge base settings.json into live ~/.claude/settings.json
#    (dotfiles keys win; live-only keys like enabledPlugins are preserved).
#  - Bootstrap base + optional work plugins/MCP servers via the Claude CLI.

set -euo pipefail

BASE_DIR="${BASE_DIR:-$HOME/.dotfiles/claude}"
WORK_DIR="${WORK_DIR:-$HOME/.dotfiles-work/claude}"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"

mkdir -p "$CLAUDE_DIR"

settings="$CLAUDE_DIR/settings.json"
tmp_settings="$(mktemp)"
trap 'rm -f "$tmp_settings"' EXIT
if [[ -f "$settings" ]]; then
  jq -s '.[0] * .[1]' "$settings" "$BASE_DIR/settings.json" > "$tmp_settings"
else
  cp "$BASE_DIR/settings.json" "$tmp_settings"
fi
mv "$tmp_settings" "$settings"
echo "Merged settings.json"

"$BASE_DIR/bootstrap.sh"

if [[ -x "$WORK_DIR/bootstrap.sh" ]]; then
  "$WORK_DIR/bootstrap.sh"
fi

echo "Claude Code configuration installed."
