#!/bin/bash

cd $HOME/dotfiles
BREWFILE=$HOME/dotfiles/homebrew/Brewfile

# Install homebrew all packages I use
if [ -f "${BREWFILE}" ]; then
    brew bundle --file ${BREWFILE}
fi