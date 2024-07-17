#!/bin/bash

set -e

if [[ "$OS" == "" ]]; then
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="darwin"
  else
    echo "Unknown OS"
    exit 1
  fi
fi

if [[ "$ARCH" == "" ]]; then
  case $(uname -m) in
    i386) ARCH="386" ;;
    i686) ARCH="386" ;;
    x86_64) ARCH="amd64" ;;
    arm) dpkg --print-architecture | grep -q "arm64" && ARCH="arm64" || ARCH="arm" ;;
  esac
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

export OS
export ARCH
export GREEN
export RED
export NC