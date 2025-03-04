#!/bin/bash

set -e

ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$ROOT_DIR"

########################################################################################################################

source tools/vars.sh
tools/vmuser.sh
tools/soft.sh

########################################################################################################################

echo -n "Create data & configs directories... "
sudo mkdir -p /etc/victoriametrics/rules
echo -e "${GREEN}Done${NC}"

########################################################################################################################

if [[ "$VERSION" == "" ]]
then
  echo -n "Get latest version... "
  VERSION=$(curl -s https://api.github.com/repos/VictoriaMetrics/VictoriaMetrics/releases/latest | jq -r '.tag_name' | sed 's/^v//')
  echo -e "(${VERSION}) ${GREEN}Done${NC}"
fi

if [ -f /usr/local/bin/vmalert ]
then
  echo -n "Get current version... "
  CURRENT_VERSION=$(/usr/local/bin/vmalert --version | grep -oP '\-v\d+\.\d+\.\d+' | sed 's/^-v//')
  echo -e "(${CURRENT_VERSION}) ${GREEN}Done${NC}"
fi

########################################################################################################################

SERVICE_NAME="vmalert.service"

if [ -z "$TMP_DIR" ]; then
  TMP_DIR=/tmp/vmutils
fi
APP_SOURCE_DIR="${TMP_DIR}"


if [[ "$VERSION" != "$CURRENT_VERSION" ]]
then
########################################################################################################################
  SERVICE_STATUS=$(systemctl list-units -t service --full --all --plain --no-legend --no-pager --output json | jq -r '.[] | select(.unit == "'$SERVICE_NAME'") | .sub')
  [[ "${SERVICE_STATUS}" == "running" ]] && sudo systemctl stop "${SERVICE_NAME}"
########################################################################################################################
  VERSION="${VERSION}" \
  TMP_DIR="${TMP_DIR}" \
  KEEP_SOURCE="$KEEP_SOURCE" \
    tools/vmutils.sh
########################################################################################################################

  echo -n "Copy files... "

  sudo cp "${APP_SOURCE_DIR}/vmalert-prod" "/usr/local/bin/vmalert"
  sudo chmod a+x "/usr/local/bin/vmalert"

  echo -e "${GREEN}Done${NC}"

fi

SERVICE_NAME="$SERVICE_NAME" SERVICE_STATUS="$SERVICE_STATUS" "tools/systemd.sh"

if [ -z "$KEEP_SOURCE" ]; then
  [[ -d "${TMP_DIR}" ]] && sudo rm -rf "${TMP_DIR}"
fi

echo ""
echo -e "${GREEN}Installation completed${NC}"

echo ""
echo "Open http://localhost:8880 in web browser"
