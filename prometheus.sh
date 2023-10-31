#!/bin/bash

set -e

ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$ROOT_DIR"

########################################################################################################################

source tools/vars.sh
tools/soft.sh

########################################################################################################################

echo -n "Create Prometheus system user & group... "
if ! getent passwd prometheus >/dev/null; then
  sudo groupadd --system prometheus
  sudo useradd -s /sbin/nologin --system -g prometheus prometheus
fi
echo -e "${GREEN}Done${NC}"

########################################################################################################################

echo -n "Create data & configs directories... "
if [ ! -d /var/lib/prometheus ]; then
  sudo mkdir -p /var/lib/prometheus
  sudo chown prometheus:prometheus /var/lib/prometheus
fi
for i in rules rules.d files_sd; do
  sudo mkdir -p /etc/prometheus/${i}
done
echo -e "${GREEN}Done${NC}"

########################################################################################################################


if [[ "$VERSION" == "" ]]
then
  VERSION=$(curl -s https://api.github.com/repos/prometheus/prometheus/releases/latest | jq -r '.tag_name' | sed 's/^v//')
fi

if [ -f /usr/local/bin/prometheus ]
then
  CURRENT_VERSION=$(/usr/local/bin/prometheus --version | head -1 | grep -Po 'version \S+' | awk '{ print $2 }')
fi

########################################################################################################################

SERVICE_NAME="prometheus.service"
TMP_DIR=/tmp/prometheus
APP_SOURCE_DIR="${TMP_DIR}/prometheus-${VERSION}.${OS}-${ARCH}"

if [[ "$VERSION" != "$CURRENT_VERSION" ]]
then
  [[ -d "${TMP_DIR}" ]] && sudo rm -rf "${TMP_DIR}"
  mkdir -p "${TMP_DIR}"

  echo "Download Prometheus files... "
  wget "https://github.com/prometheus/prometheus/releases/download/v${VERSION}/prometheus-${VERSION}.${OS}-${ARCH}.tar.gz" \
    -O "${TMP_DIR}/prometheus.tar.gz"

  echo "Unpack archive... "
  cd "${TMP_DIR}"
  tar -xvf prometheus.tar.gz
  cd "$ROOT_DIR"

########################################################################################################################

  SERVICE_STATUS=$(systemctl list-units -t service --full --all --plain --no-legend --no-pager --output json | jq -r '.[] | select(.unit == "'$SERVICE_NAME'") | .sub')
  [[ "${SERVICE_STATUS}" == "running" ]] && sudo systemctl stop "${SERVICE_NAME}"

  echo -n "Copy files... "

  sudo cp "${APP_SOURCE_DIR}/prometheus" "/usr/local/bin/prometheus"
  sudo cp "${APP_SOURCE_DIR}/promtool" "/usr/local/bin/promtool"

  sudo chmod a+x "/usr/local/bin/prometheus"
  sudo chmod a+x "/usr/local/bin/promtool"

  sudo cp -nr "${APP_SOURCE_DIR}/consoles" "/etc/prometheus/"
  sudo cp -nr "${APP_SOURCE_DIR}/console_libraries" "/etc/prometheus/"

  echo -e "${GREEN}Done${NC}"

  if [ ! -f /etc/prometheus/prometheus.yml ]; then
    echo -n "Copy config... "
    sudo cp "${APP_SOURCE_DIR}/prometheus.yml" "/etc/prometheus/prometheus.yml"
    echo -e "${GREEN}Done${NC}"
  fi

fi

########################################################################################################################

SERVICE_NAME="$SERVICE_NAME" SERVICE_STATUS="$SERVICE_STATUS" tools/systemd.sh

[[ -d "${TMP_DIR}" ]] && sudo rm -rf "${TMP_DIR}"

echo ""
echo -e "${GREEN}Installation completed${NC}"
