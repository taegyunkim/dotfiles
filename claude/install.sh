#!/usr/bin/env zsh
# Install Claude Code configuration.
#  - Merge base settings.json into live ~/.claude/settings.json
#    (dotfiles keys win; live-only keys like enabledPlugins are preserved).
#  - Bootstrap base + optional work plugins/MCP servers via the Claude CLI.

set -euo pipefail

BASE_DIR="${BASE_DIR:-$HOME/.dotfiles/claude}"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"

# On DD machines, clone workspaces-dotfiles at the canonical path and use its
# user folder as the work overlay. Caller can override WORK_DIR (e.g. inside
# a workspace where the user folder is delivered to a different path).
if [[ -d "$HOME/dd" && -z "${WORK_DIR:-}" ]]; then
  WORKSPACES_DOTFILES="$HOME/dd/workspaces-dotfiles"
  if [[ ! -d "$WORKSPACES_DOTFILES/.git" ]]; then
    git clone git@github.com:DataDog/workspaces-dotfiles.git "$WORKSPACES_DOTFILES"
  fi
  WORK_DIR="$WORKSPACES_DOTFILES/users/taegyun.kim/claude"
fi
WORK_DIR="${WORK_DIR:-}"

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
