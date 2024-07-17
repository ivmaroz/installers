#!/bin/bash

set -e

sudo apt update
sudo apt install software-properties-common

if ! find /etc/apt/ -name "*.list" -print0 | xargs -0 cat | grep "^[[:space:]]*deb" | grep -q "ppa.launchpadcontent.net/ondrej/php/ubuntu"; then
  sudo add-apt-repository ppa:ondrej/php
fi

sudo apt install -y \
  php7.3-fpm \
  php7.3-apcu \
  php7.3-bcmath \
  php7.3-cli \
  php7.3-common \
  php7.3-curl \
  php7.3-gd \
  php7.3-igbinary \
  php7.3-imagick \
  php7.3-intl \
  php7.3-mbstring \
  php7.3-mcrypt \
  php7.3-memcache \
  php7.3-mysql \
  php7.3-opcache \
  php7.3-pgsql \
  php7.3-readline \
  php7.3-redis \
  php7.3-soap \
  php7.3-sqlite3 \
  php7.3-ssh2 \
  php7.3-xdebug \
  php7.3-xhprof \
  php7.3-xml \
  php7.3-yaml \
  php7.3-zip
