#!/usr/bin/env zsh
# Symlink dotfiles into $HOME via GNU stow. Idempotent: safe to re-run.
#
# Contract with workspaces-dotfiles (DataDog/workspaces-dotfiles users/<u>):
#   - Workspace's first_login.sh exports WORK_DIR=<user-dir>/claude before
#     calling this script. We pass that env var through to claude/install.sh,
#     which runs $WORK_DIR/bootstrap.sh if it exists.
#   - When WORK_DIR is set we skip stowing the `git` package entirely: the
#     workspace platform already manages ~/.gitconfig (a stub at workspace
#     creation, then a symlink to $WORK_DIR/../.gitconfig set by
#     first_login.sh after this script returns). Either form would conflict
#     with stow, and the personal git/.gitconfig is bypassed on workspaces
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

# Migration cleanup: the previous create_symlinks.sh left bare symlinks under
# $HOME pointing into ~/.dotfiles. Stow refuses to overwrite arbitrary
# symlinks, so remove any that point into the dotfiles repo before stowing.
find ~ -maxdepth 1 -type l -lname "*/.dotfiles/*" -delete 2>/dev/null || true
find ~/.config -maxdepth 1 -type l -lname "*/.dotfiles/*" -delete 2>/dev/null || true
find ~/.claude -maxdepth 1 -type l -lname "*/.dotfiles/*" -delete 2>/dev/null || true

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

mkdir -p ~/.config ~/.local/share/nvim ~/.claude

# Stow claude first so ~/.claude/settings.json is in place before
# claude/install.sh writes through it via the Claude CLI.
stow --target="$HOME" --restow claude
~/.dotfiles/claude/install.sh

# Stow everything except zsh. On workspaces, skip the git package: the
# workspace platform provisions ~/.gitconfig (a regular file at first boot,
# then a symlink to $WORK_DIR/../.gitconfig after first_login.sh runs), and
# either form would conflict with stow. The personal git/.gitconfig is
# bypassed on workspaces anyway (see header), so there's nothing to stow.
packages=(dircolors vim tmux nvim)
if [ -z "${WORK_DIR:-}" ]; then
  packages+=(git)
fi
stow --target="$HOME" --restow "${packages[@]}"

# Stow zsh last so .zprofile flips last — preserves the workspaces-dotfiles
# first-login trigger pattern (a failure earlier leaves $HOME/.zprofile
# untouched and next login retries).
stow --target="$HOME" --restow zsh
