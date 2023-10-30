#!/bin/bash

set -e

########################################################################################################################

[ -d "${TMP_DIR}" ] && sudo rm -rf "${TMP_DIR}"
mkdir -p "${TMP_DIR}"

echo -n "Download VmUtils files... "
wget "https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/v${VERSION}/vmutils-${OS}-${ARCH}-v${VERSION}.tar.gz" \
  -O "${TMP_DIR}/vmutils.tar.gz"
echo -e "${GREEN}Done${NC}"

echo -n "Unpack archive... "
cd "${TMP_DIR}"
tar -xf "vmutils.tar.gz"
rm "vmutils.tar.gz"
cd "$ROOT_DIR"
echo -e "${GREEN}Done${NC}"

