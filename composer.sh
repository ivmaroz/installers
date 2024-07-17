#!/bin/bash

set -e

ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$ROOT_DIR"

########################################################################################################################

source tools/vars.sh
tools/soft.sh

########################################################################################################################

TMP_DIR=/tmp

function install_composer1 {
  if command -v composer1 >/dev/null; then
    return 0
  fi

  echo "Install composer1"

  local EXPECTED_CHECKSUM
  local ACTUAL_CHECKSUM

  EXPECTED_CHECKSUM="$(curl -s "https://getcomposer.org/download/latest-1.x/composer.phar.sha256")"

  wget "https://getcomposer.org/download/latest-1.x/composer.phar" \
    -O "${TMP_DIR}/composer1.phar"

  ACTUAL_CHECKSUM="$(sha256sum "${TMP_DIR}/composer1.phar" | awk '{print $1}')"

  if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
    >&2 echo 'ERROR: Invalid composer1 checksum'
    rm "${TMP_DIR}/composer1.phar"
    exit 1
  fi

  sudo mv "${TMP_DIR}/composer1.phar" "/usr/local/bin/composer1"
  sudo chmod +x "/usr/local/bin/composer1"

}

function install_composer2 {
  if command -v composer2 >/dev/null; then
    return 0
  fi
  echo "Install composer2"

  local EXPECTED_CHECKSUM
  local ACTUAL_CHECKSUM

  EXPECTED_CHECKSUM="$(curl -s "https://getcomposer.org/download/latest-stable/composer.phar.sha256")"

  wget "https://getcomposer.org/download/latest-stable/composer.phar" \
    -O "${TMP_DIR}/composer2.phar"

  ACTUAL_CHECKSUM="$(sha256sum "${TMP_DIR}/composer2.phar" | awk '{print $1}')"

  if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
    >&2 echo 'ERROR: Invalid composer2 checksum'
    rm "${TMP_DIR}/composer2.phar"
    exit 1
  fi

  sudo mv "${TMP_DIR}/composer2.phar" "/usr/local/bin/composer2"
  sudo chmod +x "/usr/local/bin/composer2"
}

install_composer1
install_composer2

if ! update-alternatives --quiet --list composer > /dev/null; then
  sudo update-alternatives --install /usr/local/bin/composer composer /usr/local/bin/composer1 1
  sudo update-alternatives --install /usr/local/bin/composer composer /usr/local/bin/composer2 2
fi
