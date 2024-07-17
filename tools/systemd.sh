#!/bin/bash

set -e

echo -n "Install service... "
if [ ! -f "/etc/systemd/system/${SERVICE_NAME}" ]; then

  sudo cp "config/etc/systemd/system/${SERVICE_NAME}" "/etc/systemd/system/${SERVICE_NAME}"

  sudo systemctl daemon-reload > /dev/null
  sudo systemctl enable "${SERVICE_NAME}" 2> /dev/null
  sudo systemctl start "${SERVICE_NAME}" > /dev/null

elif [[ "${SERVICE_STATUS}" == "running" ]]
then
    sudo systemctl start "${SERVICE_NAME}" > /dev/null
fi
echo -e "${GREEN}Done${NC}"
