#!/bin/bash

set -e

if ! find /etc/apt/ -name "*.list" -print0 | xargs -0 cat | grep "^[[:space:]]*deb" | grep -q "serge-rider/dbeaver-ce"; then
  sudo add-apt-repository ppa:serge-rider/dbeaver-ce
  sudo apt-get update
fi

sudo apt-get install -y dbeaver-ce