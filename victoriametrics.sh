#!/bin/bash

set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

########################################################################################################################

echo "Create VictoriaMetrics system group"
if ! getent passwd victoriametrics >/dev/null; then
  sudo groupadd --system victoriametrics
  sudo useradd -s /sbin/nologin --system -g victoriametrics victoriametrics
fi

########################################################################################################################

echo "Create data & configs directories"

if [ ! -d /var/lib/victoriametrics ]; then
  sudo mkdir -p /var/lib/victoriametrics
  sudo chown victoriametrics:victoriametrics /var/lib/victoriametrics
fi

sudo mkdir -pv /etc/victoriametrics

########################################################################################################################

echo "Update required files"

for COMMAND in jq wget curl vim; do
  if ! command -v "$COMMAND" &>/dev/null; then
    sudo apt update
    sudo apt -y install jq wget curl vim
    break
  fi
done

########################################################################################################################

VERSION=$(curl -s https://api.github.com/repos/VictoriaMetrics/VictoriaMetrics/releases/latest | jq -r '.tag_name' | sed 's/^v//')

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  OS="darwin"
else
  echo "Unknown OS"
  exit 1
fi

ARCHITECTURE=""
case $(uname -m) in
i386) ARCHITECTURE="386" ;;
i686) ARCHITECTURE="386" ;;
x86_64) ARCHITECTURE="amd64" ;;
arm) dpkg --print-architecture | grep -q "arm64" && ARCHITECTURE="arm64" || ARCHITECTURE="arm" ;;
esac

########################################################################################################################

echo "Download VictoriaMetrics files"

if [ -d /tmp/victoriametrics ]; then
  sudo rm -rf /tmp/victoriametrics
fi
mkdir -p /tmp/victoriametrics

wget "https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/v${VERSION}/victoria-metrics-${OS}-${ARCHITECTURE}-v${VERSION}.tar.gz" \
  -O /tmp/victoriametrics/victoriametrics.tar.gz

cd /tmp/victoriametrics/
tar -xf victoriametrics.tar.gz

########################################################################################################################

if [ ! -f /usr/local/bin/victoriametrics ] || [ "$(shasum -a256 victoria-metrics-prod | awk '{ print $1 }')" != "$(shasum -a256 /usr/local/bin/victoriametrics | awk '{ print $1 }')" ]; then
  sudo mv -v victoria-metrics-prod /usr/local/bin/victoriametrics
  UPDATED=1
else
  UPDATED=0
fi

if [ ! -f /etc/victoriametrics/victoriametrics.yml ]; then
  sudo cp "${SCRIPT_DIR}/victoriametrics/etc/victoriametrics/victoriametrics.yml" /etc/victoriametrics/victoriametrics.yml
fi

########################################################################################################################

if [ ! -f /etc/systemd/system/victoriametrics.service ]; then

  sudo cp "${SCRIPT_DIR}/victoriametrics/etc/systemd/system/victoriametrics.service" /etc/systemd/system/victoriametrics.service

  sudo systemctl daemon-reload
  sudo systemctl start victoriametrics.service
  sudo systemctl enable victoriametrics.service

else

  if [[ $UPDATED -eq 1 ]]; then
    sudo systemctl restart victoriametrics.service
  fi
fi

########################################################################################################################

rm -rf /tmp/victoriametrics
