#!/bin/bash

set -e

sudo apt update
sudo apt install software-properties-common

if ! find /etc/apt/ -name "*.list" -print0 | xargs -0 cat | grep "^[[:space:]]*deb" | grep -q "ppa.launchpadcontent.net/ondrej/php/ubuntu"; then
  sudo add-apt-repository ppa:ondrej/php
fi

sudo apt install -y \
  php8.2-fpm \
  php8.2-apcu \
  php8.2-bcmath \
  php8.2-cli \
  php8.2-common \
  php8.2-curl \
  php8.2-gd \
  php8.2-igbinary \
  php8.2-imagick \
  php8.2-intl \
  php8.2-mbstring \
  php8.2-mcrypt \
  php8.2-memcache \
  php8.2-mysql \
  php8.2-opcache \
  php8.2-pgsql \
  php8.2-readline \
  php8.2-redis \
  php8.2-soap \
  php8.2-sqlite3 \
  php8.2-ssh2 \
  php8.2-xdebug \
  php8.2-xhprof \
  php8.2-xml \
  php8.2-yaml \
  php8.2-zip
