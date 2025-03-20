#!/bin/bash

cd $HOME/dotfiles
BREWFILE=$HOME/dotfiles/homebrew/Brewfile

if [ $(uname) = "Darwin" ]; then
  if [ -f ${BREWFILE} ]; then
    rm ${BREWFILE}
  fi
  brew bundle dump --no-vscode --file ${BREWFILE}
fi
