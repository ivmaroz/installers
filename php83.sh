#!/bin/bash

set -e

sudo apt update
sudo apt install software-properties-common

if ! find /etc/apt/ -name "*.list" -print0 | xargs -0 cat | grep "^[[:space:]]*deb" | grep -q "ppa.launchpadcontent.net/ondrej/php/ubuntu"; then
  sudo add-apt-repository ppa:ondrej/php
fi

sudo apt install -y \
  php8.3-fpm \
  php8.3-apcu \
  php8.3-bcmath \
  php8.3-cli \
  php8.3-common \
  php8.3-curl \
  php8.3-gd \
  php8.3-igbinary \
  php8.3-imagick \
  php8.3-intl \
  php8.3-mbstring \
  php8.3-mcrypt \
  php8.3-memcache \
  php8.3-mysql \
  php8.3-opcache \
  php8.3-pgsql \
  php8.3-readline \
  php8.3-redis \
  php8.3-soap \
  php8.3-sqlite3 \
  php8.3-ssh2 \
  php8.3-xdebug \
  php8.3-xhprof \
  php8.3-xml \
  php8.3-yaml \
  php8.3-zip
