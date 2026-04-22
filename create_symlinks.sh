#!/usr/bin/env zsh

echo "Add symbolic links"
ln -s ~/.dotfiles/dircolors-solarized/dircolors.256dark ~/.dir_colors
ln -s ~/.dotfiles/git/gitconfig ~/.gitconfig
ln -s ~/.dotfiles/git/gitignore ~/.gitignore
ln -nfs ~/.dotfiles/vim ~/.vim
ln -s ~/.dotfiles/vim/vimrc ~/.vimrc
ln -nfs ~/.dotfiles/tmux ~/.tmux
ln -s ~/.dotfiles/tmux/tmux.conf ~/.tmux.conf
ln -nfs ~/.dotfiles/zsh/p10k.zsh ~/.p10k.zsh
ln -nfs ~/.dotfiles/zsh/zlogin ~/.zlogin
ln -nfs ~/.dotfiles/zsh/zprofile ~/.zprofile
ln -nfs ~/.dotfiles/zsh/zshenv ~/.zshenv
ln -nfs ~/.dotfiles/zsh/zshrc ~/.zshrc
mkdir -p ~/.config/nvim && ln -s ~/.dotfiles/nvim/init.vim ~/.config/nvim/init.vim
mkdir -p ~/.local/share && ln -nfs ~/.dotfiles/vim ~/.local/share/nvim
~/.dotfiles/claude/install.sh
