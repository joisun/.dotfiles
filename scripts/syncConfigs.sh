#!/bin/bash

echo "Sync configurations start..."

# Removes .zshrc from $HOME (if it exists) and symlinks the .zshrc file from the .dotfiles
echo "Sync .zshrc"
rm -rf $HOME/.zshrc
ln -sf $HOME/.dotfiles/.zshrc $HOME/.zshrc

# Removes .zshrc from $HOME (if it exists) and symlinks the .zshrc file from the .dotfiles
echo "Sync .config/clash"
rm -rf $HOME/.config/clash
ln -sf $HOME/.dotfiles/dot.configs/clash $HOME/.config/clash

