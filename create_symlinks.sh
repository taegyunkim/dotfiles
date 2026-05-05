#!/usr/bin/env zsh
# Abort on first error so a failure in claude/install.sh prevents the
# .zprofile relink at the bottom from happening.
#
# Contract with workspaces-dotfiles (DataDog/workspaces-dotfiles users/<u>):
#   - Workspace's first_login.sh exports WORK_DIR=<user-dir>/claude before
#     calling this script. We pass that env var through to claude/install.sh,
#     which runs $WORK_DIR/bootstrap.sh if it exists.
#   - Workspace then symlinks its own .gitconfig over ours after this script
#     returns, so the personal git/gitconfig is bypassed on workspaces.
#     (DD repos cloned under ~/dd/ on personal Macs use the includeIf in
#     git/gitconfig instead.)
set -euo pipefail

# Symlink $HOME/.dotfiles/$1 to $HOME/$2, creating the destination's parent
# directory if needed.
link() {
  local src="$HOME/.dotfiles/$1"
  local dst="$HOME/$2"
  mkdir -p "$(dirname "$dst")"
  ln -sfn "$src" "$dst"
}

# Symlink Claude's settings.json before running the installer so the CLI
# (claude plugin install / claude mcp add) writes through the symlink to
# the dotfiles file rather than to a fresh local copy that we'd then clobber.
link claude/settings.json .claude/settings.json

# Run failure-prone work (network, claude CLI) before any other symlinks so
# that a partial run leaves $HOME/.zprofile untouched — relevant when this
# script runs during the workspaces-dotfiles first-login trigger, which
# lives in $HOME/.zprofile and needs to survive failures so the next login
# can retry.
~/.dotfiles/claude/install.sh

echo "Add symbolic links"
link dircolors-solarized/dircolors.256dark .dir_colors
link git/gitconfig                         .gitconfig
link git/gitignore                         .gitignore
link vim                                   .vim
link vim/vimrc                             .vimrc
link tmux                                  .tmux
link tmux/tmux.conf                        .tmux.conf
link zsh/p10k.zsh                          .p10k.zsh
link zsh/zlogin                            .zlogin
link zsh/zshrc                             .zshrc

# Replace any existing real directory at ~/.config/nvim with a symlink to
# ~/.dotfiles/nvim. Symlinks are overwritten by ln -sfn, but a real directory
# would otherwise cause ln to create the symlink *inside* it.
if [ -d ~/.config/nvim ] && [ ! -L ~/.config/nvim ]; then
  rm -rf ~/.config/nvim
fi
link nvim .config/nvim

# Remove the legacy ~/.local/share/nvim -> ~/.dotfiles/vim symlink (used to
# share vim-plug plugins with nvim). lazy.nvim manages its own data dir.
if [ -L ~/.local/share/nvim ]; then
  rm ~/.local/share/nvim
fi
mkdir -p ~/.local/share/nvim

# .zprofile last: see comment above. Replacing it is irreversible from this
# script's perspective, so do it after everything else has succeeded.
link zsh/zprofile .zprofile
