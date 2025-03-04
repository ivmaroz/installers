#!/bin/bash

set -e

ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$ROOT_DIR"

if ! getent passwd minio >/dev/null; then
  sudo groupadd --system minio
  sudo useradd --no-create-home --system --shell /sbin/nologin --gid minio minio
fi

if [ ! -f /usr/local/bin/minio ]; then

  if [ -f /tmp/minio ]; then
    rm /tmp/minio
  fi
  wget https://dl.min.io/server/minio/release/linux-amd64/minio -O /tmp/minio
  chmod +x /tmp/minio

  sudo mv /tmp/minio /usr/local/bin/minio
fi

if [ ! -f /etc/default/minio ]; then
  MINIO_ROOT_USER=$(whiptail --title "Ввод параметров" --inputbox "Введите имя пользователя MINIO_ROOT_USER" 10 60 -- "${MINIO_ROOT_USER:-minioadmin}" 3>&1 1>&2 2>&3)
  MINIO_ROOT_PASSWORD=$(whiptail --title "Ввод параметров" --inputbox "Введите пароль MINIO_ROOT_PASSWORD" 10 60 -- "${MINIO_ROOT_PASSWORD:-minioadmin}" 3>&1 1>&2 2>&3)
  MINIO_VOLUMES=$(whiptail --title "Ввод параметров" --inputbox "Введите директорию с данными MINIO_VOLUMES" 10 60 -- "${MINIO_VOLUMES:-/opt/minio}" 3>&1 1>&2 2>&3)
  MINIO_OPTS=$(whiptail --title "Ввод параметров" --inputbox "Введите дополнительные параметры MINIO_OPTS" 10 60 -- "${MINIO_OPTS:---address :9000 --console-address :9001}" 3>&1 1>&2 2>&3)
  MINIO_OPTS=$(whiptail --title "Ввод параметров" --inputbox "Введите дополнительные параметры MINIO_OPTS" 10 60 -- "${MINIO_OPTS:---address :9000 --console-address :9001}" 3>&1 1>&2 2>&3)
  MINIO_BROWSER_REDIRECT_URL=$(whiptail --title "Ввод параметров" --inputbox "Введите MINIO_BROWSER_REDIRECT_URL" 10 60 -- "${MINIO_BROWSER_REDIRECT_URL}" 3>&1 1>&2 2>&3)

  sudo tee /etc/default/minio <<EOF
# MINIO_ROOT_USER and MINIO_ROOT_PASSWORD sets the root account for the MinIO server.
# This user has unrestricted permissions to perform S3 and administrative API operations on any resource in the deployment.
# Omit to use the default values 'minioadmin:minioadmin'.
# MinIO recommends setting non-default values as a best practice, regardless of environment

MINIO_ROOT_USER="$MINIO_ROOT_USER"
MINIO_ROOT_PASSWORD="$MINIO_ROOT_PASSWORD"

# MINIO_VOLUMES sets the storage volume or path to use for the MinIO server.

MINIO_VOLUMES="$MINIO_VOLUMES"

# MINIO_OPTS sets any additional commandline options to pass to the MinIO server.
# For example, \$(--console-address :9001) sets the MinIO Console listen port
MINIO_OPTS="$MINIO_OPTS"

MINIO_BROWSER_REDIRECT_URL="$MINIO_BROWSER_REDIRECT_URL"
EOF
fi

if [ -f /etc/default/minio ]; then
  set -o allexport; source /etc/default/minio; set +o allexport
fi

if [ ! -d "$MINIO_VOLUMES" ]; then
  sudo mkdir -p "$MINIO_VOLUMES"
  sudo chown minio:minio "$MINIO_VOLUMES"
  sudo chmod u=rwx,g=rwx,o=rx "$MINIO_VOLUMES"
fi

SERVICE_NAME="minio.service" SERVICE_STATUS="$SERVICE_STATUS" "tools/systemd.sh"
