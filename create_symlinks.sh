#!/usr/bin/env zsh
# Abort on first error so a failure in claude/install.sh prevents the
# .zprofile relink at the bottom from happening.
set -euo pipefail

# Symlink Claude's settings.json before running the installer so the CLI
# (claude plugin install / claude mcp add) writes through the symlink to
# the dotfiles file rather than to a fresh local copy that we'd then clobber.
mkdir -p ~/.claude
ln -sfn ~/.dotfiles/claude/settings.json ~/.claude/settings.json

# Run failure-prone work (network, claude CLI) before any other symlinks so
# that a partial run leaves $HOME/.zprofile untouched — relevant when this
# script runs during the workspaces-dotfiles first-login trigger, which
# lives in $HOME/.zprofile and needs to survive failures so the next login
# can retry.
~/.dotfiles/claude/install.sh

echo "Add symbolic links"
ln -sfn ~/.dotfiles/dircolors-solarized/dircolors.256dark ~/.dir_colors
ln -sfn ~/.dotfiles/git/gitconfig ~/.gitconfig
ln -sfn ~/.dotfiles/git/gitignore ~/.gitignore
ln -sfn ~/.dotfiles/vim ~/.vim
ln -sfn ~/.dotfiles/vim/vimrc ~/.vimrc
ln -sfn ~/.dotfiles/tmux ~/.tmux
ln -sfn ~/.dotfiles/tmux/tmux.conf ~/.tmux.conf
ln -sfn ~/.dotfiles/zsh/p10k.zsh ~/.p10k.zsh
ln -sfn ~/.dotfiles/zsh/zlogin ~/.zlogin
ln -sfn ~/.dotfiles/zsh/zshrc ~/.zshrc
mkdir -p ~/.config
# Replace any existing real directory at ~/.config/nvim with a symlink to
# ~/.dotfiles/nvim. Symlinks are overwritten by ln -sfn, but a real directory
# would otherwise cause ln to create the symlink *inside* it.
if [ -d ~/.config/nvim ] && [ ! -L ~/.config/nvim ]; then
  rm -rf ~/.config/nvim
fi
ln -sfn ~/.dotfiles/nvim ~/.config/nvim
# Remove the legacy ~/.local/share/nvim -> ~/.dotfiles/vim symlink (used to
# share vim-plug plugins with nvim). lazy.nvim manages its own data dir.
if [ -L ~/.local/share/nvim ]; then
  rm ~/.local/share/nvim
fi
mkdir -p ~/.local/share/nvim

# .zprofile last: see comment above. Replacing it is irreversible from this
# script's perspective, so do it after everything else has succeeded.
ln -sfn ~/.dotfiles/zsh/zprofile ~/.zprofile
