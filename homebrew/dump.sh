#!/bin/bash

cd $HOME/dotfiles
BREWFILE=$HOME/dotfiles/homebrew/Brewfile

if [ -f ${BREWFILE} ]; then
  rm ${BREWFILE}
fi
brew bundle dump --no-vscode --no-go --file ${BREWFILE}
