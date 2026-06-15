#!/usr/bin/env zsh
# Install Claude Code configuration. settings.json is symlinked into place
# by create_symlinks.sh; this script just bootstraps base + optional work
# plugins and MCP servers via the Claude CLI.

set -euo pipefail

BASE_DIR="${BASE_DIR:-$HOME/.dotfiles/claude}"

# WORK_DIR points to an optional overlay's claude bootstrap. Set externally
# by workspaces-dotfiles' first_login.sh on DD workspaces; otherwise detect
# a workspace-owned ~/.gitconfig or a locally-cloned workspaces-dotfiles under
# ~/dd. No cloning here.
if [[ -z "${WORK_DIR:-}" && -L "$HOME/.gitconfig" ]]; then
  gitconfig_target="$(readlink "$HOME/.gitconfig")"
  case "$gitconfig_target" in
    */workspaces-dotfiles/users/*/.gitconfig)
      workspace_user_dir="${gitconfig_target%/.gitconfig}"
      if [[ -d "$workspace_user_dir/claude" ]]; then
        WORK_DIR="$workspace_user_dir/claude"
      fi
      ;;
  esac
fi
if [[ -z "${WORK_DIR:-}" && -d "$HOME/dd/workspaces-dotfiles/users/$USER/claude" ]]; then
  WORK_DIR="$HOME/dd/workspaces-dotfiles/users/$USER/claude"
fi
WORK_DIR="${WORK_DIR:-}"

"$BASE_DIR/bootstrap.sh"

if [[ -x "$WORK_DIR/bootstrap.sh" ]]; then
  "$WORK_DIR/bootstrap.sh"
fi

echo "Claude Code configuration installed."
