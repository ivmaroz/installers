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
if [ ! -d /var/lib/victoriametrics ]; then
  sudo mkdir -p /var/lib/victoriametrics
  sudo chown victoriametrics:victoriametrics /var/lib/victoriametrics
fi

sudo mkdir -p /etc/victoriametrics

echo -e "${GREEN}Done${NC}"

########################################################################################################################

if [[ "$VERSION" == "" ]]
then
  echo -n "Get latest version... "
  VERSION=$(curl -s https://api.github.com/repos/VictoriaMetrics/VictoriaMetrics/releases/latest | jq -r '.tag_name' | sed 's/^v//')
  echo -e "(${VERSION}) ${GREEN}Done${NC}"
fi

if [ -f /usr/local/bin/victoriametrics ]
then
  echo -n "Get current version... "
  CURRENT_VERSION=$(/usr/local/bin/victoriametrics --version | grep -oP '\-v\d+\.\d+\.\d+' | sed 's/^-v//')
  echo -e "(${CURRENT_VERSION}) ${GREEN}Done${NC}"
fi

########################################################################################################################

SERVICE_NAME="victoriametrics.service"
TMP_DIR=/tmp/victoriametrics
APP_SOURCE_DIR="${TMP_DIR}"

if [[ "$VERSION" != "$CURRENT_VERSION" ]]
then
  [[ -d "${TMP_DIR}" ]] && sudo rm -rf "${TMP_DIR}"
  mkdir -p "${TMP_DIR}"

  echo -n "Download Alertmanager files... "
  wget "https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/v${VERSION}/victoria-metrics-${OS}-${ARCH}-v${VERSION}.tar.gz" \
    -O "${TMP_DIR}/victoriametrics.tar.gz"
  echo -e "${GREEN}Done${NC}"

  echo -n "Unpack archive... "
  cd "${TMP_DIR}"
  tar -xvf victoriametrics.tar.gz > /dev/null
  cd "$ROOT_DIR"
  echo -e "${GREEN}Done${NC}"

########################################################################################################################

  SERVICE_STATUS=$(systemctl list-units -t service --full --all --plain --no-legend --no-pager --output json | jq -r '.[] | select(.unit == "'$SERVICE_NAME'") | .sub')
  [[ "${SERVICE_STATUS}" == "running" ]] && sudo systemctl stop "${SERVICE_NAME}"

  echo -n "Copy files... "

  sudo cp "${APP_SOURCE_DIR}/victoria-metrics-prod" "/usr/local/bin/victoriametrics"
  sudo chmod a+x "/usr/local/bin/victoriametrics"

  sudo cp -n config/etc/victoriametrics/victoriametrics.yml /etc/victoriametrics/victoriametrics.yml

  echo -e "${GREEN}Done${NC}"

fi

SERVICE_NAME="$SERVICE_NAME" SERVICE_STATUS="$SERVICE_STATUS" "tools/systemd.sh"

[[ -d "${TMP_DIR}" ]] && sudo rm -rf "${TMP_DIR}"

echo ""
echo -e "${GREEN}Installation completed${NC}"

echo ""
echo "Open http://localhost:8428 in web browser"
