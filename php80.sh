#!/bin/bash

set -e

sudo apt update
sudo apt install software-properties-common

if ! find /etc/apt/ -name "*.list" -print0 | xargs -0 cat | grep "^[[:space:]]*deb" | grep -q "ppa.launchpadcontent.net/ondrej/php/ubuntu"; then
  sudo add-apt-repository ppa:ondrej/php
fi

sudo apt install -y \
  php8.0-fpm \
  php8.0-apcu \
  php8.0-bcmath \
  php8.0-cli \
  php8.0-common \
  php8.0-curl \
  php8.0-gd \
  php8.0-igbinary \
  php8.0-imagick \
  php8.0-intl \
  php8.0-mbstring \
  php8.0-mcrypt \
  php8.0-memcache \
  php8.0-mysql \
  php8.0-opcache \
  php8.0-pgsql \
  php8.0-readline \
  php8.0-redis \
  php8.0-soap \
  php8.0-sqlite3 \
  php8.0-ssh2 \
  php8.0-xdebug \
  php8.0-xhprof \
  php8.0-xml \
  php8.0-yaml \
  php8.0-zip
