#!/bin/bash

set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

########################################################################################################################

source "${SCRIPT_DIR}/tools/vars.sh"
source "${SCRIPT_DIR}/tools/vminit.sh"

########################################################################################################################

VERSION=$(curl -s https://api.github.com/repos/VictoriaMetrics/VictoriaMetrics/releases/latest | jq -r '.tag_name' | sed 's/^v//')

########################################################################################################################

VM_SOURCE_DIR="/tmp/victoria-metrics-${OS}-${ARCH}-v${VERSION}"

if [ ! -d "${VM_SOURCE_DIR}" ]; then
  echo "Download VictoriaMetrics files"

  if [ -d /tmp/victoriametrics ]; then
    sudo rm -rf /tmp/victoriametrics
  fi
  mkdir -p /tmp/victoriametrics

  wget "https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/v${VERSION}/victoria-metrics-${OS}-${ARCH}-v${VERSION}.tar.gz" \
    -O /tmp/victoriametrics/victoriametrics.tar.gz

  cd "/tmp/victoriametrics"
  tar -xf "victoriametrics.tar.gz"

  mv -v "/tmp/victoriametrics" "${VM_SOURCE_DIR}"
fi

########################################################################################################################

if [ ! -f /usr/local/bin/victoriametrics ] || [ "$(shasum -a256 "${VM_SOURCE_DIR}/victoria-metrics-prod" | awk '{ print $1 }')" != "$(shasum -a256 /usr/local/bin/victoriametrics | awk '{ print $1 }')" ]; then
  sudo cp -v "${VM_SOURCE_DIR}/victoria-metrics-prod" /usr/local/bin/victoriametrics
  UPDATED=1
else
  UPDATED=0
fi

if [ ! -f /etc/victoriametrics/victoriametrics.yml ]; then
  sudo cp "${SCRIPT_DIR}/victoriametrics/etc/victoriametrics/victoriametrics.yml" /etc/victoriametrics/victoriametrics.yml
fi

########################################################################################################################

if [ ! -f /etc/systemd/system/victoriametrics.service ]; then

  sudo cp "${SCRIPT_DIR}/victoriametrics/etc/systemd/system/victoriametrics.service" /etc/systemd/system/victoriametrics.service

  sudo systemctl daemon-reload
  sudo systemctl start victoriametrics.service
  sudo systemctl enable victoriametrics.service

else

  if [[ $UPDATED -eq 1 ]]; then
    sudo systemctl restart victoriametrics.service
  fi
fi

########################################################################################################################
