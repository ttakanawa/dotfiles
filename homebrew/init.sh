#!/bin/bash

cd $HOME/dotfiles
BREWFILE=$HOME/dotfiles/homebrew/Brewfile

if [ $(uname) = "Darwin" ]; then
  # Install homebrew
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Install homebrew all packages I use
  brew bundle --file ${BREWFILE}

  if [ -f ${BREWFILE} ]; then
    rm ${BREWFILE}
  fi
  brew bundle dump --no-vscode --file ${BREWFILE}
fi
