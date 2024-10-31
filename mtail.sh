#!/bin/bash

set -e

ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$ROOT_DIR"

########################################################################################################################

source tools/vars.sh
tools/soft.sh

########################################################################################################################

if [[ "$VERSION" == "" ]]
then
  echo -n "Get latest version... "
  VERSION=$(curl -s https://api.github.com/repos/google/mtail/releases/latest | jq -r '.tag_name' | sed 's/^v//')

  echo -e "(${VERSION}) ${GREEN}Done${NC}"
fi

if [ -f /usr/local/bin/mtail ]
then
  echo -n "Get current version... "
  CURRENT_VERSION=$(/usr/local/bin/mtail --version | grep -Po 'version \S+' | head -1 | awk '{ print $2 }')
  echo -e "(${CURRENT_VERSION}) ${GREEN}Done${NC}"
fi

########################################################################################################################

TMP_DIR=/tmp/mtail
APP_SOURCE_DIR="${TMP_DIR}"

if [[ "$VERSION" != "$CURRENT_VERSION" ]]
then
  [[ -d "${TMP_DIR}" ]] && sudo rm -rf "${TMP_DIR}"
  mkdir -p "${TMP_DIR}"

  # https://github.com/google/mtail/releases/download/v3.0.8/mtail_3.0.8_linux_amd64.tar.gz
  echo -n "Download Mtail files... "
  wget "https://github.com/google/mtail/releases/download/v${VERSION}/mtail_${VERSION}_${OS}_${ARCH}.tar.gz" \
    -O "${TMP_DIR}/mtail.tar.gz"
  echo -e "${GREEN}Done${NC}"

  echo -n "Unpack archive... "
  cd "${TMP_DIR}"
  tar -xvf mtail.tar.gz
  cd "$ROOT_DIR"
  echo -e "${GREEN}Done${NC}"

########################################################################################################################

  echo -n "Copy files... "

  sudo cp "${APP_SOURCE_DIR}/mtail" "/usr/local/bin/mtail"
  sudo chmod a+x "/usr/local/bin/mtail"

  echo -e "${GREEN}Done${NC}"

fi

echo ""
echo -e "${GREEN}Installation completed${NC}"

