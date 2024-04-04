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

echo ""
echo "#############################"
echo "# Установка vmagent         #"
echo "#############################"
echo ""

./vmagent.sh

echo ""
echo "#############################"
echo "# Установка vmalert         #"
echo "#############################"
echo ""

./vmalert.sh