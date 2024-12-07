#!/bin/bash

set -e

# https://www.home-assistant.io/installation/linux#install-home-assistant-core
# https://community.home-assistant.io/t/autostart-using-systemd/199497

# if [ "$EUID" -ne 0 ]; then
#   echo "Скрипт необходимо выполнять от имени суперпользователя"
#   exit 1
# fi

ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$ROOT_DIR"

VERSION=$(curl -s 'https://pypi.org/pypi/homeassistant/json' | jq -r ".info.version")

########################################################################################################################

install_apps() {

  sudo apt-get update
  sudo apt-get upgrade -y

  sudo apt-get install -y \
    python3 \
    python3-dev \
    python3-venv \
    python3-pip \
    bluez \
    libffi-dev \
    libssl-dev \
    libjpeg-dev \
    zlib1g-dev \
    autoconf \
    build-essential \
    libopenjp2-7 \
    libtiff6 \
    libturbojpeg0-dev \
    tzdata \
    ffmpeg \
    liblapack3 \
    liblapack-dev \
    libatlas-base-dev

}

add_user() {
  if ! getent passwd homeassistant >/dev/null; then
    sudo useradd -rm homeassistant
  fi
}

create_homeassistant_directory() {
  if [ ! -d /srv/homeassistant ]; then
    sudo mkdir /srv/homeassistant
    sudo chown homeassistant:homeassistant /srv/homeassistant
  fi

  if [ ! -d /home/homeassistant/.homeassistant ]; then
    sudo mkdir /home/homeassistant/.homeassistant
    sudo chown homeassistant:homeassistant /home/homeassistant/.homeassistant
  fi
}

install_homeassistant() {
  set -e

  cd /srv/homeassistant

  python3 -m venv .
  source bin/activate
  python3 -m pip install wheel
  pip3 install homeassistant==$VERSION

  chown -R homeassistant:homeassistant /srv/homeassistant
}

install_service() {
  if [ -f /etc/systemd/system/home-assistant@homeassistant.service ]; then
    return
  fi

      sudo tee /etc/systemd/system/home-assistant@homeassistant.service > /dev/null <<EOT
[Unit]
Description=Home Assistant
After=network-online.target

[Service]
Type=simple
User=%i
WorkingDirectory=/home/%i/.homeassistant
ExecStart=/srv/homeassistant/bin/hass -c "/home/%i/.homeassistant"
RestartForceExitStatus=100

[Install]
WantedBy=multi-user.target

EOT

sudo systemctl --system daemon-reload
sudo systemctl start home-assistant@homeassistant.service
sudo systemctl enable home-assistant@homeassistant.service

}

#install_apps
#add_user
#create_homeassistant_directory

sudo -u homeassistant bash -c "$(declare -f install_homeassistant); VERSION=$VERSION install_homeassistant"

echo "ok"

#install_service

