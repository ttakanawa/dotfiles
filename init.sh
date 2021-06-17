#!/bin/bash -eu

cd $HOME/dotfiles

./ln.sh

if [ `uname` = "Darwin" ]; then
  # Install homebrew
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Install homebrew all packages I use
  brew bundle
fi

git submodule init
git submodule update
