#!/bin/bash -eu

cd $HOME/dotfiles

./ln.sh

if [ `uname` = "Darwin" ]; then
  # Install homebrew
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Install homebrew all packages I use
  brew bundle

  # Set global gitignore file to the home directory
  git config --global core.excludesfile ~/.gitignore_global

  # Install nvm
  /bin/bash -c "$(curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash)"

  # https://getcomposer.org/doc/00-intro.md#globally
  php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
  php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
  php composer-setup.php
  php -r "unlink('composer-setup.php');"
  mv composer.phar /usr/local/bin/composer
fi

git submodule init
git submodule update
