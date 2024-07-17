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
fi

sudo mkdir -p /etc/alertmanager

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

VERSION=$(curl -s https://raw.githubusercontent.com/prometheus/alertmanager/master/VERSION)

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

echo "Download Alertmanager files"

if [ -d /tmp/alertmanager ]; then
  sudo rm -rf /tmp/alertmanager
fi
mkdir -p /tmp/alertmanager

wget "https://github.com/prometheus/alertmanager/releases/download/v${VERSION}/alertmanager-${VERSION}.${OS}-${ARCHITECTURE}.tar.gz" \
  -O /tmp/alertmanager/alertmanager.tar.gz

cd /tmp/alertmanager/
tar -xvf alertmanager.tar.gz

cd "alertmanager-${VERSION}.${OS}-${ARCHITECTURE}"

if [ ! -f /usr/local/bin/alertmanager ] || [ "$(shasum -a256 alertmanager | awk '{ print $1 }')" != "$(shasum -a256 /usr/local/bin/alertmanager | awk '{ print $1 }')" ]; then
  sudo mv -v alertmanager /usr/local/bin/
  UPDATED=1
else
  UPDATED=0
fi

if [ ! -f /usr/local/bin/amtool ] || [ "$(shasum -a256 amtool | awk '{ print $1 }')" != "$(shasum -a256 /usr/local/bin/amtool | awk '{ print $1 }')" ]; then
  sudo mv -v amtool /usr/local/bin/
fi

if [ ! -f /etc/alertmanager/alertmanager.yml ]; then
  sudo mv -v alertmanager.yml /etc/alertmanager/alertmanager.yml
fi

########################################################################################################################

if [ ! -f /etc/systemd/system/alertmanager.service ]; then

  sudo tee /etc/systemd/system/alertmanager.service <<EOF
[Unit]
Description=Alertmanager
Documentation=https://prometheus.io/docs/introduction/overview/
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=alertmanager
Group=alertmanager
ExecReload=/bin/kill -HUP \$MAINPID
ExecStart=/usr/local/bin/alertmanager \\
  --config.file=/etc/alertmanager/alertmanager.yml \\
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

  if [[ $UPDATED -eq 1 ]]; then
    sudo systemctl restart alertmanager.service
  fi
fi

rm -rf /tmp/alertmanager
