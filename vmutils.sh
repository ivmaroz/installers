#!/bin/bash

set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

########################################################################################################################

"${SCRIPT_DIR}/vminit.sh"

########################################################################################################################

VERSION=$(curl -s https://api.github.com/repos/VictoriaMetrics/VictoriaMetrics/releases/latest | jq -r '.tag_name' | sed 's/^v//')
OS="linux"
ARCHITECTURE="amd64"

########################################################################################################################

echo "Download VictoriaMetrics files"

if [ -d /tmp/victoriametrics ]; then
  sudo rm -rf /tmp/victoriametrics
fi
mkdir -p /tmp/victoriametrics

wget "https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/v${VERSION}/vmutils-${OS}-${ARCHITECTURE}-v${VERSION}.tar.gz" \
  -O "/tmp/victoriametrics/vmutils.tar.gz"

cd /tmp/victoriametrics/
tar -xf "vmutils.tar.gz"
