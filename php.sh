#!/bin/bash

set -e

VERSION=$1

if ! LANG=en_US apt list -a software-properties-common 2>/dev/null | grep -q installed; then
  sudo apt update
  sudo apt install -y software-properties-common
fi

if ! (
  find /etc/apt/ -name "*.list" -print0
  find /etc/apt/ -name "*.sources" -print0
) | xargs -0 cat | grep -q "ondrej/php/ubuntu"; then
  sudo add-apt-repository ppa:ondrej/php
fi

VERSIONS=$(apt-cache search php | grep -P -o '^php\d\.\d[^-]' | sed 's/php//' | sort -V)

if [ -z "$VERSION" ]; then
  COMMAND='whiptail --title "Выбор версии PHP" --notags --menu "Выберите версию PHP" 18 60 10'

  SELECT=""
  for V in $VERSIONS; do
    SELECT=" $SELECT \"$V\" \"PHP$V\""
  done

  COMMAND="${COMMAND} ${SELECT} 3>&1 1>&2 2>&3"

  VERSION=$(eval "$COMMAND")
fi

if ! echo "$VERSIONS" | grep -q "$VERSION"; then
  echo "Не поддерживаемая версия PHP"
  exit 1
fi

# Список оптимальных пакетов для установки
OPTIONAL="php${VERSION}-fpm
php${VERSION}-apcu
php${VERSION}-bcmath
php${VERSION}-cli
php${VERSION}-curl
php${VERSION}-gd
php${VERSION}-igbinary
php${VERSION}-imagick
php${VERSION}-intl
php${VERSION}-mbstring
php${VERSION}-ldap
php${VERSION}-mcrypt
php${VERSION}-memcache
php${VERSION}-mysql
php${VERSION}-opcache
php${VERSION}-pgsql
php${VERSION}-readline
php${VERSION}-redis
php${VERSION}-soap
php${VERSION}-sqlite3
php${VERSION}-ssh2
php${VERSION}-xml
php${VERSION}-yaml
php${VERSION}-zip"

SELECT=""

COMMAND='whiptail --title "Выбор пакетов" --notags --checklist "Выберите пакеты для установки" 20 60 12'

for PKG in $(apt list -a 2>/dev/null | grep -Po '^php'"$VERSION"'-[^/]+'); do
  COMMAND="$COMMAND \"$PKG\" \"$PKG\""
  if echo "$OPTIONAL" | grep -Pq "\b$PKG\b"; then
     COMMAND="$COMMAND ON"
     else
     COMMAND="$COMMAND OFF"
     fi
done

PACKAGES=$(eval "$COMMAND 3>&1 1>&2 2>&3")

APT="sudo apt install "
for PKG in $PACKAGES; do
  APT="$APT $PKG"
done

eval "$APT"
