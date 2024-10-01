#!/bin/bash

set -e

if ! command -v symfony &>/dev/null; then
  wget https://get.symfony.com/cli/installer -O - | bash

  sudo mv "$HOME/.symfony5/bin/symfony" "/usr/local/bin/symfony"
fi