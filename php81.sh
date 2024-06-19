#!/bin/bash

set -e

sudo apt update
sudo apt install software-properties-common

if ! find /etc/apt/ -name "*.list" -print0 | xargs -0 cat | grep "^[[:space:]]*deb" | grep -q "ppa.launchpadcontent.net/ondrej/php/ubuntu"; then
  sudo add-apt-repository ppa:ondrej/php
fi

sudo apt install -y \
  php8.1-fpm \
  php8.1-apcu \
  php8.1-bcmath \
  php8.1-cli \
  php8.1-common \
  php8.1-curl \
  php8.1-gd \
  php8.1-igbinary \
  php8.1-imagick \
  php8.1-intl \
  php8.1-mbstring \
  php8.1-mcrypt \
  php8.1-memcache \
  php8.1-mysql \
  php8.1-opcache \
  php8.1-pgsql \
  php8.1-readline \
  php8.1-redis \
  php8.1-soap \
  php8.1-sqlite3 \
  php8.1-ssh2 \
  php8.1-xdebug \
  php8.1-xhprof \
  php8.1-xml \
  php8.1-yaml \
  php8.1-zip
