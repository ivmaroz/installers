#!/bin/bash

set -e

########################################################################################################################

echo "Create Prometheus system group"
if ! getent passwd prometheus >/dev/null; then
  sudo groupadd --system prometheus
  sudo useradd -s /sbin/nologin --system -g prometheus prometheus
fi

########################################################################################################################

echo "Create data & configs directories"

if [ ! -d /var/lib/prometheus ]; then
  sudo mkdir -p /var/lib/prometheus
  sudo chown prometheus:prometheus /var/lib/prometheus
fi

for i in rules rules.d files_sd; do
  sudo mkdir -p /etc/prometheus/${i}
done

########################################################################################################################

echo "Update required files"

REQUIRED=0

for COMMAND in wget curl vim jq; do
  if ! command -v "$COMMAND" &>/dev/null; then
    REQUIRED=1
  fi
done

if [[ $REQUIRED -ne 0 ]]; then
  sudo apt update
  sudo apt -y install wget curl vim jq
fi

########################################################################################################################

VERSION=$(curl -s https://api.github.com/repos/prometheus/prometheus/releases/latest | jq -r '.tag_name' | sed 's/^v//')

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  OS="darwin"
else
  echo "Unknown OS"
  exit 1
fi

if [ -f /usr/local/bin/prometheus ]; then
  PROMETHEUS_HASH=$(shasum -a256 /usr/local/bin/prometheus | awk '{ print $1 }')
else
  PROMETHEUS_HASH=""
fi

ARCHITECTURE=""
case $(uname -m) in
i386) ARCHITECTURE="386" ;;
i686) ARCHITECTURE="386" ;;
x86_64) ARCHITECTURE="amd64" ;;
arm) dpkg --print-architecture | grep -q "arm64" && ARCHITECTURE="arm64" || ARCHITECTURE="arm" ;;
esac

########################################################################################################################

echo "Download Prometheus files"

mkdir -p /tmp/prometheus

wget "https://github.com/prometheus/prometheus/releases/download/v${VERSION}/prometheus-${VERSION}.${OS}-${ARCHITECTURE}.tar.gz" \
  -O /tmp/prometheus/prometheus.tar.gz

cd /tmp/prometheus/
tar -xvf prometheus.tar.gz

cd "prometheus-${VERSION}.${OS}-${ARCHITECTURE}"

sudo mv prometheus promtool /usr/local/bin/
if [ ! -f /etc/prometheus/prometheus.yml ]; then
  sudo mv -v prometheus.yml /etc/prometheus/prometheus.yml
fi

sudo mv -nv consoles/ console_libraries/ /etc/prometheus/

########################################################################################################################

NEW_HASH=$(shasum -a256 /usr/local/bin/prometheus | awk '{ print $1 }')

if [ ! -f /etc/systemd/system/prometheus.service ]; then

    sudo tee /etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus
Documentation=https://prometheus.io/docs/introduction/overview/
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP \$MAINPID
ExecStart=/usr/local/bin/prometheus \
            --config.file=/etc/prometheus/prometheus.yml \
            --storage.tsdb.path=/var/lib/prometheus \
            --web.console.templates=/etc/prometheus/consoles \
            --web.console.libraries=/etc/prometheus/console_libraries \
            --web.listen-address=0.0.0.0:9090 \
            --web.external-url= \
            --storage.tsdb.retention.size=10GB

SyslogIdentifier=prometheus
Restart=always

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl start prometheus.service
  sudo systemctl enable prometheus.service

else

  if [ "${NEW_HASH}" != "${PROMETHEUS_HASH}" ]; then
    sudo systemctl restart prometheus.service
  fi

fi

rm -rf /tmp/prometheus
