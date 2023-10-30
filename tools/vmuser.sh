#!/bin/bash

set -e

########################################################################################################################

echo -n "Create VictoriaMetrics system user & group... "
if ! getent passwd victoriametrics >/dev/null; then
  sudo groupadd --system victoriametrics
  sudo useradd -s /sbin/nologin --system -g victoriametrics victoriametrics
fi
echo -e "${GREEN}Done${NC}"

########################################################################################################################
