#!/bin/bash

set -e

########################################################################################################################

echo "Create VictoriaMetrics system group"
if ! getent passwd victoriametrics >/dev/null; then
  sudo groupadd --system victoriametrics
  sudo useradd -s /sbin/nologin --system -g victoriametrics victoriametrics
fi

########################################################################################################################
