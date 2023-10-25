#!/bin/bash

set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

########################################################################################################################

source "${SCRIPT_DIR}/tools/vmutils.sh"

########################################################################################################################

if [ ! -d /etc/victoriametrics/rules ]; then
  sudo mkdir -p /etc/victoriametrics/rules
fi

UPDATED=0
if [ ! -f /usr/local/bin/vmalert ] || [ "$(shasum -a256 "${VM_SOURCE_DIR}/vmalert-prod" | awk '{ print $1 }')" != "$(shasum -a256 /usr/local/bin/vmalert | awk '{ print $1 }')" ]; then
  sudo cp -v "${VM_SOURCE_DIR}/vmalert-prod" /usr/local/bin/vmalert
  UPDATED=1
fi

########################################################################################################################

if [ ! -f /etc/systemd/system/vmalert.service ]; then

  sudo cp -v "${SCRIPT_DIR}/victoriametrics/etc/systemd/system/vmalert.service" /etc/systemd/system/vmalert.service

  sudo systemctl daemon-reload
  sudo systemctl start vmalert.service
  sudo systemctl enable vmalert.service

else

  if [[ $UPDATED -eq 1 ]]; then
    sudo systemctl restart vmalert.service
  fi
fi
