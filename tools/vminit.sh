#!/bin/bash

set -e

########################################################################################################################

echo "Create VictoriaMetrics system group"
if ! getent passwd victoriametrics >/dev/null; then
  sudo groupadd --system victoriametrics
  sudo useradd -s /sbin/nologin --system -g victoriametrics victoriametrics
fi

sudo mkdir -pv /etc/victoriametrics

########################################################################################################################

echo "Update required files"

for COMMAND in jq wget curl vim; do
  if ! command -v "$COMMAND" &>/dev/null; then
    sudo apt update
    sudo apt -y install jq wget curl vim
    break
  fi
done

########################################################################################################################

echo "Create data & configs directories"

if [ ! -d /var/lib/victoriametrics ]; then
  sudo mkdir -p /var/lib/victoriametrics
  sudo chown victoriametrics:victoriametrics /var/lib/victoriametrics
fi

sudo mkdir -pv /etc/victoriametrics

