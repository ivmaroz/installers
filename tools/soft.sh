#!/bin/bash

set -e

########################################################################################################################


echo -n "Install required files... "
for COMMAND in jq wget curl; do
  if ! command -v "$COMMAND" &>/dev/null; then
    echo ""
    sudo apt update
    sudo apt -y install jq wget curl
    break
  fi
done
echo -e "${GREEN}Done${NC}"
