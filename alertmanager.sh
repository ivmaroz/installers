#!/bin/bash

set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

########################################################################################################################

source "${SCRIPT_DIR}/tools/vars.sh"
"${SCRIPT_DIR}/tools/soft.sh"

########################################################################################################################

echo "Create Alertmanager system group"
if ! getent passwd alertmanager >/dev/null; then
  sudo groupadd --system alertmanager
  sudo useradd -s /sbin/nologin --system -g alertmanager alertmanager
fi

########################################################################################################################

echo "Create data & configs directories"

if [ ! -d /var/lib/alertmanager ]; then
  sudo mkdir -p /var/lib/alertmanager
  sudo chown alertmanager:alertmanager /var/lib/alertmanager
fi

sudo mkdir -p /etc/alertmanager

########################################################################################################################

VERSION=$(curl -s https://raw.githubusercontent.com/prometheus/alertmanager/master/VERSION)

########################################################################################################################

APP_SOURCE_DIR="/tmp/alertmanager-${VERSION}.${OS}-${ARCH}"

if [ ! -d "${APP_SOURCE_DIR}" ]; then

  echo "Download Alertmanager files"

  if [ -d /tmp/alertmanager ]; then
    sudo rm -rf /tmp/alertmanager
  fi
  mkdir -p /tmp/alertmanager

  wget "https://github.com/prometheus/alertmanager/releases/download/v${VERSION}/alertmanager-${VERSION}.${OS}-${ARCH}.tar.gz" \
    -O /tmp/alertmanager/alertmanager.tar.gz

  cd "/tmp/alertmanager/"
  tar -xvf alertmanager.tar.gz

  mv -v "/tmp/alertmanager/alertmanager-${VERSION}.${OS}-${ARCH}" "${APP_SOURCE_DIR}"
  rm -rf "/tmp/alertmanager"
fi

UPDATED=0
if [ ! -f /usr/local/bin/alertmanager ] || [ "$(shasum -a256 "${APP_SOURCE_DIR}/alertmanager" | awk '{ print $1 }')" != "$(shasum -a256 /usr/local/bin/alertmanager | awk '{ print $1 }')" ]; then
  sudo cp -v "${APP_SOURCE_DIR}/alertmanager" "/usr/local/bin/alertmanager"
  UPDATED=1
fi

if [ ! -f /usr/local/bin/amtool ] || [ "$(shasum -a256 "${APP_SOURCE_DIR}/amtool" | awk '{ print $1 }')" != "$(shasum -a256 /usr/local/bin/amtool | awk '{ print $1 }')" ]; then
  sudo cp -v "${APP_SOURCE_DIR}/amtool" "/usr/local/bin/amtool"
fi

if [ ! -f /etc/alertmanager/alertmanager.yml ]; then
  sudo cp -v "${APP_SOURCE_DIR}/alertmanager.yml" "/etc/alertmanager/alertmanager.yml"
fi

########################################################################################################################

if [ ! -f /etc/systemd/system/alertmanager.service ]; then

  sudo cp -v "${SCRIPT_DIR}/config/etc/systemd/system/alertmanager.service" /etc/systemd/system/alertmanager.service

  sudo systemctl daemon-reload
  sudo systemctl start alertmanager.service
  sudo systemctl enable alertmanager.service

elif [[ $UPDATED -eq 1 ]]; then
  sudo systemctl restart alertmanager.service
fi
