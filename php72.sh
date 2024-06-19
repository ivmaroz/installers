#!/bin/bash

set -e

sudo apt update
sudo apt install software-properties-common

if ! find /etc/apt/ -name "*.list" -print0 | xargs -0 cat | grep "^[[:space:]]*deb" | grep -q "ppa.launchpadcontent.net/ondrej/php/ubuntu"; then
  sudo add-apt-repository ppa:ondrej/php
fi

sudo apt install -y \
  php7.2-fpm \
  php7.2-apcu \
  php7.2-bcmath \
  php7.2-cli \
  php7.2-common \
  php7.2-curl \
  php7.2-gd \
  php7.2-igbinary \
  php7.2-imagick \
  php7.2-intl \
  php7.2-mbstring \
  php7.2-mcrypt \
  php7.2-memcache \
  php7.2-mysql \
  php7.2-opcache \
  php7.2-pgsql \
  php7.2-readline \
  php7.2-redis \
  php7.2-soap \
  php7.2-sqlite3 \
  php7.2-ssh2 \
  php7.2-xdebug \
  php7.2-xhprof \
  php7.2-xml \
  php7.2-yaml \
  php7.2-zip
