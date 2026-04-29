#!/usr/bin/env zsh

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
ln -sfn ~/.dotfiles/zsh/zprofile ~/.zprofile
ln -sfn ~/.dotfiles/zsh/zshrc ~/.zshrc
mkdir -p ~/.config/nvim && ln -sfn ~/.dotfiles/nvim/init.vim ~/.config/nvim/init.vim
mkdir -p ~/.local/share && ln -sfn ~/.dotfiles/vim ~/.local/share/nvim
~/.dotfiles/claude/install.sh
