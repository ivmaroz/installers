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

sudo mkdir -p /opt/minio
sudo chown minio:minio /opt/minio
sudo chmod u=rwx,g=rwx,o=rx /opt/minio

MINIO_ROOT_USER=$(whiptail --title "Ввод параметров" --inputbox "Введите имя пользователя MINIO_ROOT_USER" 10 60 -- "${MINIO_ROOT_USER:-minioadmin}" 3>&1 1>&2 2>&3)
MINIO_ROOT_PASSWORD=$(whiptail --title "Ввод параметров" --inputbox "Введите пароль MINIO_ROOT_PASSWORD" 10 60 -- "${MINIO_ROOT_PASSWORD:-minioadmin}" 3>&1 1>&2 2>&3)
MINIO_VOLUMES=$(whiptail --title "Ввод параметров" --inputbox "Введите директорию с данными MINIO_VOLUMES" 10 60 -- "${MINIO_VOLUMES:-/opt/minio}" 3>&1 1>&2 2>&3)
MINIO_OPTS=$(whiptail --title "Ввод параметров" --inputbox "Введите дополнительные параметры MINIO_OPTS" 10 60 -- "${MINIO_OPTS:---address :9000 --console-address :9001}" 3>&1 1>&2 2>&3)

sudo tee /tmp/minio <<EOF
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
EOF

if [ ! -f /etc/default/minio ]; then
  sudo mv /tmp/minio /etc/default/minio
elif ! diff -q /tmp/minio /etc/default/minio; then
  sudo mv /tmp/minio /etc/default/minio
  RESTART_SERVICE=1
fi

if [ -f /tmp/minio ]; then
  sudo rm -f /tmp/minio
fi

SERVICE_NAME="minio.service" SERVICE_STATUS="$SERVICE_STATUS" "tools/systemd.sh"

if [ -n "$RESTART_SERVICE" ]; then
  sudo systemctl restart minio.service
fi

sudo systemctl status minio.service
