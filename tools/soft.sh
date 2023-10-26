#!/bin/bash

set -e

########################################################################################################################

echo "Install required files"

for COMMAND in jq wget curl; do
  if ! command -v "$COMMAND" &>/dev/null; then
    echo "Update required files"

    sudo apt update
    sudo apt -y install jq wget curl
    break
  fi
done