#!/bin/bash

set -e

########################################################################################################################

source tools/vars.sh
tools/soft.sh

########################################################################################################################

for COMMAND in ca-certificates curl; do
  if ! apt list --installed 2> /dev/null| grep -q "$COMMAND"; then
    echo -n "Install required files... "
    echo ""
    sudo apt update
    sudo apt -y install ca-certificates curl
    break
    echo -e "${GREEN}Done${NC}"
  fi
done

if [ ! -d /etc/apt/keyrings ]; then
  sudo install -m 0755 -d /etc/apt/keyrings
fi

if [ ! -f /etc/apt/keyrings/docker.asc ]; then
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
fi

if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
fi

sudo apt-get update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

if ! id -nGz "$USER" | grep -q -z --color docker ; then
  sudo usermod -a -G docker "$USER";
  echo -e "${YELLOW}Пользователь $USER был добавлени в группу docker. Чтобы изменения вступили в силу необходимо перезагрузить компьютер"
fi