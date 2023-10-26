#!/bin/bash

set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

########################################################################################################################

source "${SCRIPT_DIR}/tools/vars.sh"
"${SCRIPT_DIR}/tools/soft.sh"

########################################################################################################################

echo "Create Prometheus system group"
if ! getent passwd prometheus >/dev/null; then
  sudo groupadd --system prometheus
  sudo useradd -s /sbin/nologin --system -g prometheus prometheus
fi

########################################################################################################################

echo "Create data & configs directories"

if [ ! -d /var/lib/prometheus ]; then
  sudo mkdir -p /var/lib/prometheus
  sudo chown prometheus:prometheus /var/lib/prometheus
fi

for i in rules rules.d files_sd; do
  sudo mkdir -p /etc/prometheus/${i}
done

########################################################################################################################

VERSION=$(curl -s https://api.github.com/repos/prometheus/prometheus/releases/latest | jq -r '.tag_name' | sed 's/^v//')

########################################################################################################################

APP_SOURCE_DIR="/tmp/prometheus-${VERSION}.${OS}-${ARCH}"

if [ ! -d "${APP_SOURCE_DIR}" ]; then

  echo "Download Prometheus files"

  if [ -d /tmp/prometheus ]; then
    sudo rm -rf /tmp/prometheus
  fi
  mkdir -p /tmp/prometheus

  wget "https://github.com/prometheus/prometheus/releases/download/v${VERSION}/prometheus-${VERSION}.${OS}-${ARCH}.tar.gz" \
    -O /tmp/prometheus/prometheus.tar.gz

  cd /tmp/prometheus/
  tar -xvf prometheus.tar.gz

  mv -v "/tmp/prometheus/prometheus-${VERSION}.${OS}-${ARCH}" "${APP_SOURCE_DIR}"
  rm -rf "/tmp/prometheus"
fi

UPDATED=0
if [ ! -f /usr/local/bin/prometheus ] || [ "$(shasum -a256 "${APP_SOURCE_DIR}/prometheus" | awk '{ print $1 }')" != "$(shasum -a256 /usr/local/bin/prometheus | awk '{ print $1 }')" ]; then
  sudo cp -v "${APP_SOURCE_DIR}/prometheus" "/usr/local/bin/prometheus"
  UPDATED=1
fi

if [ ! -f /usr/local/bin/promtool ] || [ "$(shasum -a256 "${APP_SOURCE_DIR}/promtool" | awk '{ print $1 }')" != "$(shasum -a256 /usr/local/bin/promtool | awk '{ print $1 }')" ]; then
  sudo cp -v "${APP_SOURCE_DIR}/promtool" "/usr/local/bin/promtool"
fi

if [ ! -f /etc/prometheus/prometheus.yml ]; then
  sudo cp -v "${APP_SOURCE_DIR}/prometheus.yml" "/etc/prometheus/prometheus.yml"
fi
sudo cp -nrv "${APP_SOURCE_DIR}/consoles" "/etc/prometheus/"
sudo cp -nrv "${APP_SOURCE_DIR}/console_libraries" "/etc/prometheus/"

########################################################################################################################

if [ ! -f /etc/systemd/system/prometheus.service ]; then

  sudo cp -v "${SCRIPT_DIR}/config/etc/systemd/system/prometheus.service" /etc/systemd/system/prometheus.service

  sudo systemctl daemon-reload
  sudo systemctl start prometheus.service
  sudo systemctl enable prometheus.service

elif [[ $UPDATED -eq 1 ]]; then
    sudo systemctl restart prometheus.service
fi
