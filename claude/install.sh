#!/usr/bin/env zsh
# Install Claude Code configuration.
#  - Symlink hooks/ from base dotfiles.
#  - Merge base settings.json into live ~/.claude/settings.json
#    (dotfiles keys win; live-only keys like enabledPlugins are preserved).
#  - Bootstrap base + optional work plugins/MCP servers via the Claude CLI.

set -euo pipefail

BASE_DIR="${BASE_DIR:-$HOME/.dotfiles/claude}"
WORK_DIR="${WORK_DIR:-$HOME/.dotfiles-work/claude}"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"

mkdir -p "$CLAUDE_DIR"

symlink_dir() {
  local src="$1" dst="$2"
  if [[ -L "$dst" ]]; then
    ln -sfn "$src" "$dst"
  elif [[ ! -e "$dst" ]]; then
    ln -s "$src" "$dst"
  else
    echo "ERROR: $dst exists and is not a symlink. Remove it and re-run." >&2
    exit 1
  fi
}

symlink_dir "$BASE_DIR/hooks" "$CLAUDE_DIR/hooks"

# Merge settings.json: live * dotfiles (dotfiles overrides on conflict).
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
