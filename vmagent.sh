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
if [ ! -d /var/lib/vmagent-remotewrite-data ]; then
  sudo mkdir -p /var/lib/vmagent-remotewrite-data
  sudo chown victoriametrics:victoriametrics /var/lib/vmagent-remotewrite-data
fi

sudo mkdir -p /etc/victoriametrics/vmagent.d

echo -e "${GREEN}Done${NC}"

########################################################################################################################

if [[ "$VERSION" == "" ]]
then
  echo -n "Get latest version... "
  VERSION=$(curl -s https://api.github.com/repos/VictoriaMetrics/VictoriaMetrics/releases/latest | jq -r '.tag_name' | sed 's/^v//')
  echo -e "(${VERSION}) ${GREEN}Done${NC}"
fi


if [ -f /usr/local/bin/vmagent ]
then
  echo -n "Get current version... "
  CURRENT_VERSION=$(/usr/local/bin/vmagent --version | grep -oP '\-v\d+\.\d+\.\d+' | sed 's/^-v//')
  echo -e "(${CURRENT_VERSION}) ${GREEN}Done${NC}"
fi

########################################################################################################################

SERVICE_NAME="vmagent.service"

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

  sudo cp "${APP_SOURCE_DIR}/vmagent-prod" "/usr/local/bin/vmagent"
  sudo chmod a+x "/usr/local/bin/vmagent"

  for CFG in "vmagent.yml" "vmagent.d/vmagent.yml" "vmagent.d/node_exporter.yml"
  do
    sudo cp -n "config/etc/victoriametrics/${CFG}" "/etc/victoriametrics/${CFG}"
  done
  echo -e "${GREEN}Done${NC}"

fi

SERVICE_NAME="$SERVICE_NAME" SERVICE_STATUS="$SERVICE_STATUS" "tools/systemd.sh"

if [ -z "$KEEP_SOURCE" ]; then
  [[ -d "${TMP_DIR}" ]] && sudo rm -rf "${TMP_DIR}"
fi

echo ""
echo -e "${GREEN}Installation completed${NC}"

echo ""
echo "Open http://localhost:8429 in web browser"
