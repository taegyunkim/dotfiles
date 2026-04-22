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
settings_layers=()
[[ -f "$settings" ]] && settings_layers+=("$settings")
settings_layers+=("$BASE_DIR/settings.json")
[[ -f "$WORK_DIR/settings.json" ]] && settings_layers+=("$WORK_DIR/settings.json")
jq -s 'reduce .[] as $x ({}; . * $x)' "${settings_layers[@]}" > "$tmp_settings"
mv "$tmp_settings" "$settings"
echo "Merged settings.json"

"$BASE_DIR/bootstrap.sh"

if [[ -x "$WORK_DIR/bootstrap.sh" ]]; then
  "$WORK_DIR/bootstrap.sh"
fi

echo "Claude Code configuration installed."
