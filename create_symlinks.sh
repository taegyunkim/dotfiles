#!/usr/bin/env zsh
# Symlink dotfiles into $HOME via GNU stow. Idempotent: safe to re-run.
#
# Contract with workspaces-dotfiles (DataDog/workspaces-dotfiles users/<u>):
#   - Workspace's first_login.sh exports WORK_DIR=<user-dir>/claude before
#     calling this script. We pass that env var through to claude/install.sh,
#     which runs $WORK_DIR/bootstrap.sh if it exists.
#   - Manual re-runs also detect the workspace overlay from ~/.gitconfig when
#     it points into workspaces-dotfiles/users/<u>/.gitconfig.
#   - On workspaces we skip stowing the `git` package entirely: the workspace
#     platform manages ~/.gitconfig, and either a regular file or symlink would
#     conflict with stow. The personal git/.gitconfig is bypassed on workspaces
#     regardless. (DD repos cloned under ~/dd/ on personal Macs use the
#     includeIf in git/.gitconfig instead.)
set -euo pipefail

# Ensure stow is available.
if ! command -v stow >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1; then
    brew install stow
  else
    echo "stow is required but not installed; install it (e.g. brew install stow) and re-run." >&2
    exit 1
  fi
fi

cd ~/.dotfiles

WORKSPACE_USER_DIR="${WORKSPACE_USER_DIR:-}"
if [ -z "$WORKSPACE_USER_DIR" ] && [ -n "${WORK_DIR:-}" ]; then
  WORKSPACE_USER_DIR="${WORK_DIR%/claude}"
  if [ "$WORKSPACE_USER_DIR" = "$WORK_DIR" ]; then
    WORKSPACE_USER_DIR="$(dirname "$WORK_DIR")"
  fi
fi
if [ -z "$WORKSPACE_USER_DIR" ] && [ -L "$HOME/.gitconfig" ]; then
  gitconfig_target="$(readlink "$HOME/.gitconfig")"
  case "$gitconfig_target" in
    */workspaces-dotfiles/users/*/.gitconfig)
      WORKSPACE_USER_DIR="${gitconfig_target%/.gitconfig}"
      ;;
  esac
fi
if [ -z "$WORKSPACE_USER_DIR" ] && [ -d "$HOME/dd/workspaces-dotfiles/users/$USER" ]; then
  WORKSPACE_USER_DIR="$HOME/dd/workspaces-dotfiles/users/$USER"
fi
if [ -z "${WORK_DIR:-}" ] && [ -n "$WORKSPACE_USER_DIR" ] && [ -d "$WORKSPACE_USER_DIR/claude" ]; then
  export WORK_DIR="$WORKSPACE_USER_DIR/claude"
fi

# Migration cleanup: the previous create_symlinks.sh left bare symlinks under
# $HOME pointing into ~/.dotfiles. Stow refuses to overwrite arbitrary
# symlinks, so remove any that point into the dotfiles repo before stowing.
find ~ -maxdepth 1 -type l -lname "*/.dotfiles/*" -delete 2>/dev/null || true
find ~/.config -maxdepth 1 -type l -lname "*/.dotfiles/*" -delete 2>/dev/null || true
find ~/.claude -maxdepth 1 -type l -lname "*/.dotfiles/*" -delete 2>/dev/null || true
find ~/.pi/agent -maxdepth 1 -type l -lname "*/.dotfiles/*" -delete 2>/dev/null || true

# ~/.config/nvim: only this script's dotfiles live here, so it's safe to
# wipe a real dir (or stale symlink) so stow can recreate the symlink.
if [ -L ~/.config/nvim ]; then
  rm ~/.config/nvim
elif [ -d ~/.config/nvim ] && [ ! -L ~/.config/nvim ]; then
  rm -rf ~/.config/nvim
fi

# ~/.local/share/nvim: lazy.nvim and mason store plugin/server installs here.
# Only remove the *legacy* symlink (which used to point to ~/.dotfiles/vim);
# a real directory is precious user data and must NOT be wiped.
if [ -L ~/.local/share/nvim ]; then
  rm ~/.local/share/nvim
fi

mkdir -p ~/.config ~/.local/share/nvim ~/.claude ~/.pi/agent

# Stow claude first so ~/.claude/settings.json is in place before
# claude/install.sh writes through it via the Claude CLI.
stow --target="$HOME" --restow claude
~/.dotfiles/claude/install.sh

# Preserve existing Pi agent runtime state, but let stow manage stable config
# files from ~/.dotfiles/pi. Auth, OAuth, caches, sessions, generated models,
# npm installs, and trust state stay as local files under ~/.pi/agent.
for f in SYSTEM.md mcp.json settings.json; do
  if [ -f ~/.pi/agent/"$f" ] && [ ! -L ~/.pi/agent/"$f" ]; then
    mv -f ~/.pi/agent/"$f" ~/.pi/agent/"$f".bak
  fi
done
stow --target="$HOME" --restow pi

# Stow everything except zsh. On workspaces, skip the git package because the
# workspace platform provisions ~/.gitconfig from workspaces-dotfiles.
packages=(dircolors vim tmux nvim)
if [ -z "$WORKSPACE_USER_DIR" ]; then
  packages+=(git)
fi
stow --target="$HOME" --restow "${packages[@]}"

# Stow zsh last so .zprofile flips last, preserving the workspaces-dotfiles
# first-login trigger pattern (a failure earlier leaves $HOME/.zprofile
# untouched and next login retries).
#
# On a fresh workspace, ~/.zprofile is a regular file containing only the
# workspaces first-login trigger, and ~/.zshrc is the default oh-my-zsh
# template — neither is something to preserve, but stow refuses to clobber
# regular files. Back them up to .bak so stow can take over. On re-runs
# these targets are stow-managed symlinks and the branches are skipped.
for f in .zprofile .zshrc; do
  if [ -f ~/"$f" ] && [ ! -L ~/"$f" ]; then
    mv -f ~/"$f" ~/"$f".bak
  fi
done
stow --target="$HOME" --restow zsh

# Invalidate the antigen cache if it still references powerlevel10k (replaced
# by starship). Antigen does not auto-regenerate when bundle commands change,
# so the cached init keeps loading p10k until removed. This is a one-time
# cleanup: once antigen regenerates without p10k the grep matches nothing and
# this block is a no-op.
if [ -f ~/.antigen/init.zsh ] && grep -q powerlevel10k ~/.antigen/init.zsh; then
  rm -f ~/.antigen/init.zsh ~/.antigen/init.zsh.zwc
fi

# Install starship if missing. Uses the official install script (user
# preference); installs to ~/.local/bin which is already on PATH via .zprofile.
if ! command -v starship >/dev/null 2>&1; then
  curl -sS https://starship.rs/install.sh | sh -s -- -b "$HOME/.local/bin" -y || true
fi
