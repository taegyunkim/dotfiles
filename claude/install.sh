#!/usr/bin/env zsh
# Install Claude Code configuration. settings.json is symlinked into place
# by create_symlinks.sh; this script just bootstraps base + optional work
# plugins and MCP servers via the Claude CLI.

set -euo pipefail

BASE_DIR="${BASE_DIR:-$HOME/.dotfiles/claude}"
WORK_DIR="${WORK_DIR:-}"

"$BASE_DIR/bootstrap.sh"

if [[ -x "$WORK_DIR/bootstrap.sh" ]]; then
  "$WORK_DIR/bootstrap.sh"
fi

echo "Claude Code configuration installed."
