#!/bin/bash

set -e

ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$ROOT_DIR"

########################################################################################################################

source tools/vars.sh
tools/soft.sh

########################################################################################################################

echo -n "Create data & configs directories... "
sudo mkdir -p /etc/prometheus
echo -e "${GREEN}Done${NC}"

########################################################################################################################

if [[ "$VERSION" == "" ]]
then
  echo -n "Get latest version... "
  VERSION=$(curl -s https://raw.githubusercontent.com/prometheus/blackbox_exporter/master/VERSION)
  echo -e "(${VERSION}) ${GREEN}Done${NC}"
fi

if [ -f /usr/local/bin/blackbox_exporter ]
then
  echo -n "Get current version... "
  CURRENT_VERSION=$(/usr/local/bin/blackbox_exporter --version | head -1 | grep -Po 'version \S+' | awk '{ print $2 }')
  echo -e "(${CURRENT_VERSION}) ${GREEN}Done${NC}"
fi

########################################################################################################################

SERVICE_NAME="blackbox_exporter.service"
TMP_DIR=/tmp/blackbox_exporter
APP_SOURCE_DIR="${TMP_DIR}/blackbox_exporter-${VERSION}.${OS}-${ARCH}"

if [[ "$VERSION" != "$CURRENT_VERSION" ]]
then
  [[ -d "${TMP_DIR}" ]] && sudo rm -rf "${TMP_DIR}"
  mkdir -p "${TMP_DIR}"

  echo -n "Download Node exporter files... "
  wget "https://github.com/prometheus/blackbox_exporter/releases/download/v${VERSION}/blackbox_exporter-${VERSION}.${OS}-${ARCH}.tar.gz" \
    -O "${TMP_DIR}/blackbox_exporter.tar.gz"
  echo -e "${GREEN}Done${NC}"

  echo -n "Unpack archive... "
  cd "${TMP_DIR}"
  tar -xvf blackbox_exporter.tar.gz
  cd "$ROOT_DIR"
  echo -e "${GREEN}Done${NC}"

########################################################################################################################

  SERVICE_STATUS=$(systemctl list-units -t service --full --all --plain --no-legend --no-pager --output json | jq -r '.[] | select(.unit == "'$SERVICE_NAME'") | .sub')
  [[ "${SERVICE_STATUS}" == "running" ]] && sudo systemctl stop "${SERVICE_NAME}"

  echo -n "Copy files... "

  sudo cp "${APP_SOURCE_DIR}/blackbox_exporter" "/usr/local/bin/blackbox_exporter"
  sudo chmod a+x "/usr/local/bin/blackbox_exporter"

  echo -e "${GREEN}Done${NC}"

fi

if [ ! -f /etc/prometheus/blackbox.yml ]; then
  echo -n "Copy config... "
  sudo cp "config/etc/prometheus/blackbox.yml" "/etc/prometheus/blackbox.yml"
  echo -e "${GREEN}Done${NC}"
fi

########################################################################################################################

SERVICE_NAME="$SERVICE_NAME" SERVICE_STATUS="$SERVICE_STATUS" "tools/systemd.sh"

[[ -d "${TMP_DIR}" ]] && sudo rm -rf "${TMP_DIR}"

echo ""
echo -e "${GREEN}Installation completed${NC}"

echo ""
echo "Open http://localhost:9115 in web browser"
