#!/bin/bash

set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

########################################################################################################################

source "${SCRIPT_DIR}/vars.sh"
"${SCRIPT_DIR}/vminit.sh"

########################################################################################################################

VERSION=$(curl -s https://api.github.com/repos/VictoriaMetrics/VictoriaMetrics/releases/latest | jq -r '.tag_name' | sed 's/^v//')

########################################################################################################################

export VM_SOURCE_DIR="/tmp/vmutils-${OS}-${ARCH}-v${VERSION}"

if [ ! -d "${VM_SOURCE_DIR}" ]; then
  echo "Download VictoriaMetrics files"

  if [ -d /tmp/victoriametrics ]; then
    sudo rm -rf /tmp/victoriametrics
  fi
  mkdir -p /tmp/victoriametrics

  wget "https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/v${VERSION}/vmutils-${OS}-${ARCH}-v${VERSION}.tar.gz" \
    -O "/tmp/victoriametrics/vmutils.tar.gz"

  cd "/tmp/victoriametrics"
  tar -xf "vmutils.tar.gz"

  mv -v "/tmp/victoriametrics" "${VM_SOURCE_DIR}"
fi

