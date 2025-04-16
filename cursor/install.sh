#!/bin/bash

cat $HOME/dotfiles/cursor/extensions | while read line; do
  cursor --install-extension $line
done