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
  VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | jq -r '.tag_name')

  echo -e "(${VERSION}) ${GREEN}Done${NC}"
fi

if [ -f /usr/local/bin/k9s ]
then
  echo -n "Get current version... "
  CURRENT_VERSION=$(/usr/local/bin/k9s version | grep -P 'Version:' | awk '{ print $2 }')
  echo -e "(${CURRENT_VERSION}) ${GREEN}Done${NC}"
fi

########################################################################################################################

TMP_DIR=/tmp/k9s
APP_SOURCE_DIR="${TMP_DIR}"

if [[ "$VERSION" != "$CURRENT_VERSION" ]]
then
  [[ -d "${TMP_DIR}" ]] && sudo rm -rf "${TMP_DIR}"
  mkdir -p "${TMP_DIR}"

  # https://github.com/google/k9s/releases/download/v3.0.8/k9s_3.0.8_linux_amd64.tar.gz
  echo -n "Download k9s files... "
  wget "https://github.com/derailed/k9s/releases/download/v${VERSION}/k9s_${OS}_${ARCH}.tar.gz" \
    -O "${TMP_DIR}/k9s.tar.gz"
  echo -e "${GREEN}Done${NC}"

  echo -n "Unpack archive... "
  cd "${TMP_DIR}"
  tar -xvf k9s.tar.gz
  cd "$ROOT_DIR"
  echo -e "${GREEN}Done${NC}"

########################################################################################################################

  echo -n "Copy files... "

  sudo cp "${APP_SOURCE_DIR}/k9s" "/usr/local/bin/k9s"
  sudo chmod a+x "/usr/local/bin/k9s"

  echo -e "${GREEN}Done${NC}"

fi

echo ""
echo -e "${GREEN}Installation completed${NC}"

