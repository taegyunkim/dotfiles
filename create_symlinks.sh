#!/usr/bin/env zsh

echo "Add symbolic links"
ln -s ~/.dotfiles/dircolors-solarized/dircolors.256dark ~/.dir_colors
ln -s ~/.dotfiles/git/gitconfig ~/.gitconfig
ln -s ~/.dotfiles/git/gitignore ~/.gitignore
ln -nfs ~/.dotfiles/vim ~/.vim
ln -s ~/.dotfiles/vim/vimrc ~/.vimrc
ln -nfs ~/.dotfiles/tmux ~/.tmux
ln -s ~/.dotfiles/tmux/tmux.conf ~/.tmux.conf
ln -s ~/.dotfiles/ycm_extra_conf.py ~/.ycm_extra_conf.py
ln -s ~/.dotfiles/zsh/p10k.zsh ~/.p10k.zsh
