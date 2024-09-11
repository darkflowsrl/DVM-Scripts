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

find /root -name "*.AppImage" -type f -delete
if [ $? -ne 0 ]; then
  echo "Error al eliminar los archivos .AppImage"
  exit 1
fi

chmod a+x download-front.sh

source download-front.sh $TOKEN $REPO dvm-app-front.AppImage $VERSION_FRONT

cd /root/Darkflow-HMI-Backend || exit 1
git pull
if [ $? -ne 0 ]; then
  echo "Error al hacer git pull en /root/Darkflow-HMI-Backend"
  exit 1
fi


# BASHRC="/root/.bashrc"
# NEW_LINE="startx /root/dvm-app-front.AppImage --no-sandbox -- -nocursor"

# if grep -q "startx /root/dvm-app-front.AppImage --no-sandbox -- -nocursor" "$BASHRC"; then
#   sed -i "s|startx /root/dvm-app-front.AppImage --no-sandbox -- -nocursor|$NEW_LINE|" "$BASHRC"
# else
#   echo "$NEW_LINE" >> "$BASHRC"
# fi

# if [ $? -ne 0 ]; then
#   echo "Error al actualizar el archivo .bashrc."
#   exit 1
# fi

# echo "Archivo .bashrc actualizado exitosamente."

reboot
