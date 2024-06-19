#!/bin/bash

set -e

VERSION=$1

if [ -z "$VERSION" ]; then
  echo "Необходимо указать версию PHP, например, ./php.sh 8.1"
  exit 1
fi

case "$VERSION" in
  "7.0") ;;
  "7.1") ;;
  "7.2") ;;
  "7.3") ;;
  "7.4") ;;
  "8.0") ;;
  "8.1") ;;
  "8.2") ;;
  "8.3") ;;
  *)
    echo "Неизвестная версия PHP"
    exit 1
    ;;
esac


sudo apt update
sudo apt install software-properties-common

if ! find /etc/apt/ -name "*.list" -print0 | xargs -0 cat | grep "^[[:space:]]*deb" | grep -q "ppa.launchpadcontent.net/ondrej/php/ubuntu"; then
  sudo add-apt-repository ppa:ondrej/php
fi

sudo apt install -y \
  "php${VERSION}-fpm" \
  "php${VERSION}-apcu" \
  "php${VERSION}-bcmath" \
  "php${VERSION}-cli" \
  "php${VERSION}-common" \
  "php${VERSION}-curl" \
  "php${VERSION}-gd" \
  "php${VERSION}-igbinary" \
  "php${VERSION}-imagick" \
  "php${VERSION}-intl" \
  "php${VERSION}-mbstring" \
  "php${VERSION}-mcrypt" \
  "php${VERSION}-memcache" \
  "php${VERSION}-mysql" \
  "php${VERSION}-opcache" \
  "php${VERSION}-pgsql" \
  "php${VERSION}-readline" \
  "php${VERSION}-redis" \
  "php${VERSION}-soap" \
  "php${VERSION}-sqlite3" \
  "php${VERSION}-ssh2" \
  "php${VERSION}-xdebug" \
  "php${VERSION}-xhprof" \
  "php${VERSION}-xml" \
  "php${VERSION}-yaml" \
  "php${VERSION}-zip"
