#!/bin/bash

set -e

########################################################################################################################

for COMMAND in jq wget curl; do
  if ! command -v "$COMMAND" &>/dev/null; then
    echo -n "Install required files... "
    echo ""
    sudo apt update
    sudo apt -y install jq wget curl
    break
    echo -e "${GREEN}Done${NC}"
  fi
done
