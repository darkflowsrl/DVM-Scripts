#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Uso: $0 <version_front> <version_back>"
    exit 1
fi

VERSION_FRONT=$1
VERSION_BACK=$2

TOKEN=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
REPO=darkflowsrl/DVM-front

nmcli dev wifi connect "dvm" password "dvm12345"
if [ $? -ne 0 ]; then
  echo "Error al conectar a la red Wi-Fi"
  exit 1
fi

BACKUP_DIR="/backups/backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

cp -r /root/* "$BACKUP_DIR"

if [ $? -ne 0 ]; then
  echo "Error al hacer el backup de /root"
  exit 1
fi

source download-front.sh $TOKEN $REPO frontend.AppImage $VERSION_FRONT

cd /root/backend || exit 1

git pull

if [ $? -ne 0 ]; then
  echo "Error al actualizar el backend"
  exit 1
fi

reboot
