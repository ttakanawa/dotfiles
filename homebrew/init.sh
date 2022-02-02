#!/bin/bash

cd $HOME/dotfiles

if [ `uname` = "Darwin" ]; then
  # Install homebrew
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Install homebrew all packages I use
  brew bundle
  rm $HOME/dotfiles/Brewfile
  brew bundle dump
fi
