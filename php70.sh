#!/bin/bash

set -e

sudo apt update
sudo apt install software-properties-common

if ! find /etc/apt/ -name "*.list" -print0 | xargs -0 cat | grep "^[[:space:]]*deb" | grep -q "ppa.launchpadcontent.net/ondrej/php/ubuntu"; then
  sudo add-apt-repository ppa:ondrej/php
fi

sudo apt install -y \
  php7.0-fpm \
  php7.0-apcu \
  php7.0-bcmath \
  php7.0-cli \
  php7.0-common \
  php7.0-curl \
  php7.0-gd \
  php7.0-igbinary \
  php7.0-imagick \
  php7.0-intl \
  php7.0-mbstring \
  php7.0-mcrypt \
  php7.0-memcache \
  php7.0-mysql \
  php7.0-opcache \
  php7.0-pgsql \
  php7.0-readline \
  php7.0-redis \
  php7.0-soap \
  php7.0-sqlite3 \
  php7.0-ssh2 \
  php7.0-xdebug \
  php7.0-xhprof \
  php7.0-xml \
  php7.0-yaml \
  php7.0-zip
