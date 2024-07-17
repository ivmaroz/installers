#!/bin/bash

set -e

########################################################################################################################

echo "Create Alertmanager system group"
if ! getent passwd alertmanager >/dev/null; then
  sudo groupadd --system alertmanager
  sudo useradd -s /sbin/nologin --system -g alertmanager alertmanager
fi

########################################################################################################################

echo "Create data & configs directories"

if [ ! -d /var/lib/alertmanager ]; then
  sudo mkdir -p /var/lib/alertmanager
  sudo chown alertmanager:alertmanager /var/lib/alertmanager
  sudo mkdir -p /etc/alertmanager
fi

########################################################################################################################

echo "Update required files"

REQUIRED=0

for COMMAND in wget curl vim; do
  if ! command -v "$COMMAND" &>/dev/null; then
    REQUIRED=1
  fi
done

if [[ $REQUIRED -ne 0 ]]; then
  sudo apt update
  sudo apt -y install wget curl vim
fi

########################################################################################################################

VERSION=$(curl -s https://raw.githubusercontent.com/prometheus/alertmanager/master/VERSION)

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  OS="darwin"
else
  echo "Unknown OS"
  exit 1
fi

if [ -f /usr/local/bin/alertmanager ]; then
  ALERT_HASH=$(shasum -a256 /usr/local/bin/alertmanager | awk '{ print $1 }')
else
  ALERT_HASH=""
fi

ARCHITECTURE=""
case $(uname -m) in
i386) ARCHITECTURE="386" ;;
i686) ARCHITECTURE="386" ;;
x86_64) ARCHITECTURE="amd64" ;;
arm) dpkg --print-architecture | grep -q "arm64" && ARCHITECTURE="arm64" || ARCHITECTURE="arm" ;;
esac

########################################################################################################################

echo "Download Alertmanager files"

mkdir -p /tmp/alertmanager
wget "https://github.com/prometheus/alertmanager/releases/download/v${VERSION}/alertmanager-${VERSION}.${OS}-${ARCHITECTURE}.tar.gz" \
  -O /tmp/alertmanager/alertmanager.tar.gz

cd /tmp/alertmanager/
tar -xf alertmanager.tar.gz

cd "alertmanager-${VERSION}.${OS}-${ARCHITECTURE}"

sudo mv alertmanager amtool /usr/local/bin/
if [ ! -f /etc/alertmanager/alertmanager.yml ]; then
  echo "Copy config"
  sudo mv alertmanager.yml /etc/alertmanager/alertmanager.yml
fi

########################################################################################################################

NEW_HASH=$(shasum -a256 /usr/local/bin/alertmanager | awk '{ print $1 }')
echo "$ALERT_HASH"
echo "$NEW_HASH"

if [ ! -f /etc/systemd/system/alertmanager.service ]; then

  sudo tee /etc/systemd/system/alertmanager.service <<EOF
[Unit]
Description=Prometheus
Documentation=https://prometheus.io/docs/introduction/overview/
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=alertmanager
Group=alertmanager
ExecReload=/bin/kill -HUP \$MAINPID
ExecStart=/usr/local/bin/alertmanager \
  --config.file=/etc/alertmanager/alertmanager.yml \
  --storage.path=/var/lib/alertmanager

SyslogIdentifier=alertmanager
Restart=always

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl start alertmanager.service
  sudo systemctl enable alertmanager.service

else

  if [ "${NEW_HASH}" != "${ALERT_HASH}" ]; then
    echo "Restart Alertmanager"

    sudo systemctl restart alertmanager.service
  fi
fi

rm -rf /tmp/alertmanager
