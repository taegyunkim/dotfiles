#!/usr/bin/env zsh
# Symlink dotfiles into $HOME via GNU stow. Idempotent: safe to re-run.
#
# Contract with workspaces-dotfiles (DataDog/workspaces-dotfiles users/<u>):
#   - Workspace's first_login.sh symlinks ~/.gitconfig into
#     workspaces-dotfiles/users/<u>/.gitconfig before calling this script.
#     We detect the workspace from that symlink (also on manual re-runs).
#   - On workspaces we skip stowing the `git` package entirely: the workspace
#     platform manages ~/.gitconfig, and either a regular file or symlink would
#     conflict with stow. The personal git/.gitconfig is bypassed on workspaces
#     regardless. (DD repos cloned under ~/dd/ on personal Macs use the
#     includeIf in git/.gitconfig instead.)
set -euo pipefail

# Non-login SSH commands on Linux workspaces may not have linuxbrew on PATH.
if ! command -v brew >/dev/null 2>&1 && [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

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

WORKSPACE_OWNS_GITCONFIG=0
if [ -L "$HOME/.gitconfig" ]; then
  case "$(readlink "$HOME/.gitconfig")" in
    */workspaces-dotfiles/users/*/.gitconfig)
      WORKSPACE_OWNS_GITCONFIG=1
      ;;
  esac
fi

# Migration cleanup: the previous create_symlinks.sh left bare symlinks under
# $HOME pointing into ~/.dotfiles. Stow refuses to overwrite arbitrary
# symlinks, so remove any that point into the dotfiles repo before stowing.
# ~/.claude is included to clean up links left by the removed claude package.
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

mkdir -p ~/.config ~/.local/share/nvim ~/.pi/agent/extensions

# GitHub SSH routing (DataDog vs ddoghq accounts). ~/.ssh/config is not
# stow-managed (the workspaces CLI and other tools write to it), so just make
# sure it includes ssh/github.conf before any `Host *` block. On the Mac, keep
# the workspaces CLI's generated block first, as it asks.
SSH_INCLUDE="Include ~/.dotfiles/ssh/github.conf"
mkdir -p ~/.ssh && chmod 700 ~/.ssh
touch ~/.ssh/config && chmod 600 ~/.ssh/config
if ! grep -qxF "$SSH_INCLUDE" ~/.ssh/config; then
  tmp="$(mktemp)"
  if grep -qxF "## END -- workspaces cli" ~/.ssh/config; then
    awk -v inc="$SSH_INCLUDE" '{ print } $0 == "## END -- workspaces cli" { print ""; print inc }' ~/.ssh/config > "$tmp"
  else
    { printf '%s\n\n' "$SSH_INCLUDE"; cat ~/.ssh/config; } > "$tmp"
  fi
  cat "$tmp" > ~/.ssh/config && rm -f "$tmp"
fi

# Preserve existing Pi agent runtime state, but let stow manage stable config
# files from ~/.dotfiles/pi. Auth, OAuth, caches, sessions, generated models,
# npm installs, and trust state stay as local files under ~/.pi/agent.
for f in SYSTEM.md mcp.json settings.json scripts/slack-mcp-auth-pi.py; do
  if [ -f ~/.pi/agent/"$f" ] && [ ! -L ~/.pi/agent/"$f" ]; then
    mv -f ~/.pi/agent/"$f" ~/.pi/agent/"$f".bak
  fi
done
stow --target="$HOME" --restow pi

# Stow everything except zsh. On workspaces, skip the git package because the
# workspace platform provisions ~/.gitconfig from workspaces-dotfiles.
packages=(dircolors vim tmux nvim)
if [ "$WORKSPACE_OWNS_GITCONFIG" -eq 0 ]; then
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
