#!/bin/bash

set -e

sudo apt update
sudo apt install software-properties-common

if ! find /etc/apt/ -name "*.list" -print0 | xargs -0 cat | grep "^[[:space:]]*deb" | grep -q "ppa.launchpadcontent.net/ondrej/php/ubuntu"; then
  sudo add-apt-repository ppa:ondrej/php
fi

sudo apt install -y \
  php7.4-fpm \
  php7.4-apcu \
  php7.4-bcmath \
  php7.4-cli \
  php7.4-common \
  php7.4-curl \
  php7.4-gd \
  php7.4-igbinary \
  php7.4-imagick \
  php7.4-intl \
  php7.4-mbstring \
  php7.4-mcrypt \
  php7.4-memcache \
  php7.4-mysql \
  php7.4-opcache \
  php7.4-pgsql \
  php7.4-readline \
  php7.4-redis \
  php7.4-soap \
  php7.4-sqlite3 \
  php7.4-ssh2 \
  php7.4-xdebug \
  php7.4-xhprof \
  php7.4-xml \
  php7.4-yaml \
  php7.4-zip
