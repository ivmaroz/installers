#!/bin/bash

set -e

ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$ROOT_DIR"

echo ""
echo "#############################"
echo "# Установка VictoriaMetrics #"
echo "#############################"
echo ""

./victoriametrics.sh

export TMP_DIR=/tmp/vmutils

echo ""
echo "#############################"
echo "# Установка vmagent         #"
echo "#############################"
echo ""

KEEP_SOURCE=1 \
  ./vmagent.sh

echo ""
echo "#############################"
echo "# Установка vmalert         #"
echo "#############################"
echo ""

KEEP_SOURCE=1 \
  ./vmalert.sh

[[ -d "${TMP_DIR}" ]] && sudo rm -rf "${TMP_DIR}"
