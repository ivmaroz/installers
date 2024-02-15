#!/bin/bash

set -e

ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$ROOT_DIR"

########################################################################################################################

source tools/vars.sh
tools/soft.sh

########################################################################################################################

echo -n "Create Alertmanager system user & group... "
if ! getent passwd alertmanager >/dev/null; then
  sudo groupadd --system alertmanager
  sudo useradd -s /sbin/nologin --system -g alertmanager alertmanager
fi
echo -e "${GREEN}Done${NC}"

########################################################################################################################

echo -n "Create data & configs directories... "
if [ ! -d /var/lib/alertmanager ]; then
  sudo mkdir -p /var/lib/alertmanager
  sudo chown alertmanager:alertmanager /var/lib/alertmanager
fi
sudo mkdir -p /etc/alertmanager

echo -e "${GREEN}Done${NC}"

########################################################################################################################

if [[ "$VERSION" == "" ]]
then
  echo -n "Get latest version... "
  VERSION=$(curl -s https://raw.githubusercontent.com/prometheus/alertmanager/master/VERSION)
  echo -e "(${VERSION}) ${GREEN}Done${NC}"
fi

if [ -f /usr/local/bin/alertmanager ]
then
  echo -n "Get current version... "
  CURRENT_VERSION=$(/usr/local/bin/alertmanager --version | head -1 | grep -Po 'version \S+' | awk '{ print $2 }')
  echo -e "(${CURRENT_VERSION}) ${GREEN}Done${NC}"
fi

########################################################################################################################

SERVICE_NAME="alertmanager.service"
TMP_DIR=/tmp/alertmanager
APP_SOURCE_DIR="${TMP_DIR}/alertmanager-${VERSION}.${OS}-${ARCH}"

if [[ "$VERSION" != "$CURRENT_VERSION" ]]
then
  [[ -d "${TMP_DIR}" ]] && sudo rm -rf "${TMP_DIR}"
  mkdir -p "${TMP_DIR}"

  echo -n "Download Alertmanager files... "
  wget "https://github.com/prometheus/alertmanager/releases/download/v${VERSION}/alertmanager-${VERSION}.${OS}-${ARCH}.tar.gz" \
    -O "${TMP_DIR}/alertmanager.tar.gz"
  echo -e "${GREEN}Done${NC}"

  echo -n "Unpack archive... "
  cd "${TMP_DIR}"
  tar -xvf alertmanager.tar.gz
  cd "$ROOT_DIR"
  echo -e "${GREEN}Done${NC}"

########################################################################################################################

  SERVICE_STATUS=$(systemctl list-units -t service --full --all --plain --no-legend --no-pager --output json | jq -r '.[] | select(.unit == "'$SERVICE_NAME'") | .sub')
  [[ "${SERVICE_STATUS}" == "running" ]] && sudo systemctl stop "${SERVICE_NAME}"

  echo -n "Copy files... "

  sudo cp "${APP_SOURCE_DIR}/alertmanager" "/usr/local/bin/alertmanager"
  sudo cp "${APP_SOURCE_DIR}/amtool" "/usr/local/bin/amtool"

  sudo chmod a+x "/usr/local/bin/alertmanager"
  sudo chmod a+x "/usr/local/bin/amtool"

  echo -e "${GREEN}Done${NC}"

  if [ ! -f /etc/alertmanager/alertmanager.yml ]; then
    echo -n "Copy config... "
    sudo cp -v "${APP_SOURCE_DIR}/alertmanager.yml" "/etc/alertmanager/alertmanager.yml"
    echo -e "${GREEN}Done${NC}"
  fi

fi

########################################################################################################################

SERVICE_NAME="$SERVICE_NAME" SERVICE_STATUS="$SERVICE_STATUS" "tools/systemd.sh"

[[ -d "${TMP_DIR}" ]] && sudo rm -rf "${TMP_DIR}"

echo ""
echo -e "${GREEN}Installation completed${NC}"

echo ""
echo "Open http://localhost:9093 in web browser"
