#!/bin/bash

set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

########################################################################################################################

source "${SCRIPT_DIR}/tools/vmutils.sh"

if [ ! -d /var/lib/vmagent-remotewrite-data ]; then
  sudo mkdir -p /var/lib/vmagent-remotewrite-data
  sudo chown victoriametrics:victoriametrics /var/lib/vmagent-remotewrite-data
fi

UPDATED=0
if [ ! -f /usr/local/bin/vmagent ] || [ "$(shasum -a256 "${VM_SOURCE_DIR}/vmagent-prod" | awk '{ print $1 }')" != "$(shasum -a256 /usr/local/bin/vmagent | awk '{ print $1 }')" ]; then
  sudo mv -v "${VM_SOURCE_DIR}/vmagent-prod" /usr/local/bin/vmagent
  UPDATED=1
fi

#########################################################################################################################

if [ ! -f /etc/victoriametrics/vmagent.yml ]; then
  sudo cp "${SCRIPT_DIR}/victoriametrics/etc/victoriametrics/vmagent.yml" /etc/victoriametrics/vmagent.yml
fi

#########################################################################################################################

if [ ! -f /etc/systemd/system/vmagent.service ]; then

  sudo cp -v "${SCRIPT_DIR}/victoriametrics/etc/systemd/system/vmagent.service" /etc/systemd/system/vmagent.service

  sudo systemctl daemon-reload
  sudo systemctl enable vmagent.service
  sudo systemctl start vmagent.service

else
  if [[ $UPDATED -eq 1 ]]; then
    sudo systemctl restart vmagent.service
  fi
fi

