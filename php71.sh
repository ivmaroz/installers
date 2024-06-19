#!/bin/bash

set -e

sudo apt update
sudo apt install software-properties-common

if ! find /etc/apt/ -name "*.list" -print0 | xargs -0 cat | grep "^[[:space:]]*deb" | grep -q "ppa.launchpadcontent.net/ondrej/php/ubuntu"; then
  sudo add-apt-repository ppa:ondrej/php
fi

sudo apt install -y \
  php7.1-fpm \
  php7.1-apcu \
  php7.1-bcmath \
  php7.1-cli \
  php7.1-common \
  php7.1-curl \
  php7.1-gd \
  php7.1-igbinary \
  php7.1-imagick \
  php7.1-intl \
  php7.1-mbstring \
  php7.1-mcrypt \
  php7.1-memcache \
  php7.1-mysql \
  php7.1-opcache \
  php7.1-pgsql \
  php7.1-readline \
  php7.1-redis \
  php7.1-soap \
  php7.1-sqlite3 \
  php7.1-ssh2 \
  php7.1-xdebug \
  php7.1-xhprof \
  php7.1-xml \
  php7.1-yaml \
  php7.1-zip
