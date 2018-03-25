#!/usr/bin/env zsh

echo "Create symlink for zprezto"

ln -s "${ZDOTDIR:-$HOME}"/.dotfiles/zsh/prezto ~/.zprezto

echo "Copy zprezto override files to home directory"

setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.dotfiles/zsh/prezto-override/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
