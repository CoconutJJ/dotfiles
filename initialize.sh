#!/usr/bin/env bash

rm ~/.config/alacritty/alacritty.toml 
rm ~/.hammerspoon/init.lua
rm ~/.config/tmux/tmux.conf
rm ~/.config/helix/config.toml
rm ~/.config/helix/languages.toml
rm ~/.config/starship.toml

mkdir ~/.config/alacritty
ln -s alacritty.toml ~/.config/alacritty/alacritty.toml 
ln -s gitconfig ~/.gitconfig 

mkdir ~/.hammerspoon
ln -s hammerspoon.lua ~/.hammerspoon/init.lua

mkdir ~/.config/tmux
ln -s tmux.conf ~/.config/tmux/tmux.conf

mkdir ~/.config/helix
ln -s helix_config.toml ~/.config/helix/config.toml
ln -s helix_languages.toml ~/.config/helix/languages.toml

ln -s starship.toml ~/.config/starship.toml
