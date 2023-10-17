#!/bin/bash

set -e

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

sudo mkdir -pv /etc/victoriametrics/rules

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

wget "https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/v${VERSION}/vmutils-${OS}-${ARCHITECTURE}-v${VERSION}.tar.gz" \
  -O /tmp/victoriametrics/victoriametrics-vmutils.tar.gz


cd /tmp/victoriametrics/
tar -xf victoriametrics-vmutils.tar.gz

UPDATED=0
if [ ! -f /usr/local/bin/vmalert ] || [ "$(shasum -a256 vmalert-prod | awk '{ print $1 }')" != "$(shasum -a256 /usr/local/bin/vmalert | awk '{ print $1 }')" ]; then
  sudo mv -v vmalert-prod /usr/local/bin/vmalert
  UPDATED=1
fi

########################################################################################################################

if [ ! -f /etc/systemd/system/vmalert.service ]; then

  sudo tee /etc/systemd/system/vmalert.service <<EOF
[Unit]
Description=VMAlert
Documentation=https://prometheus.io/docs/introduction/overview/
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=victoriametrics
Group=victoriametrics
ExecReload=/bin/kill -HUP \$MAINPID
ExecStart=/usr/local/bin/vmalert \\
  -rule=/etc/victoriametrics/rules/*.yml \\
  -datasource.url=http://127.0.0.1:8428 \\
  -remoteWrite.url=http://127.0.0.1:8428 \\
  -remoteRead.url=http://127.0.0.1:8428 \\
  -notifier.url=http://127.0.0.1:9093

SyslogIdentifier=victoriametrics
Restart=always

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl start vmalert.service
  sudo systemctl enable vmalert.service

else

  if [[ $UPDATED -eq 1 ]]; then
    sudo systemctl restart vmalert.service
  fi
fi

########################################################################################################################

rm -rf /tmp/victoriametrics
