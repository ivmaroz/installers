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

export OS
export ARCH