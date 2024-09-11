#!/bin/bash

# -----------> LEER <-----------
# Este script se debe ejecutar ¡UNICAMENTE! cuando la tablet
# está completamente en blanco

# Variables
USERNAME="giulicrenna"
T_HEADER="github_pat_11AOFTWNQ05Gi4jvuznnWX_"
T_MID="alggVnUiXFFAFgipboQujyXQh4kl"
T_TAIL="Ne9zTzceUF2bakoGA23BWHERx5eXpbA"
TOKEN="$T_HEADER$T_MID$T_TAIL"
FRONTEND_API_URL="https://api.github.com/repos/darkflowsrl/DVM-front/releases/latest"
FRONTEND_DIR="/root/frontend"
FRONTEND_PATH="$FRONTEND_DIR/frontend.AppImage"
BACKEND_REPO_URL="https://$USERNAME:$TOKEN@github.com/darkflowsrl/DVM-Backend.git"
BACKEND_DIR="/root/backend"
REQUIREMENTS_FILE="$BACKEND_DIR/requirements.txt"
NEW_BASHRC="./files/.bashrc"
SCRIPTS_SRC="./scripts/scripts"
SCRIPTS_DST="/root/scripts"
SPLASH_IMAGE="./assets/splash.jpg"
GRUB_CFG="/etc/default/grub"


# -----------> INSTALACION DE PAQUETES <-----------
timedatectl set-ntp true

#apt -y update
#apt -y upgrade
#apt install -y software-properties-common
apt install -y python3-pip --fix-missing
apt install -y htop
apt install -y nodm
apt install -y git

# -----------> CONFIGURACION DEL AUTOLOGIN <-----------

# Define la ruta al archivo de unidad de systemd para el servicio getty en la terminal tty1
SERVICE_FILE="/etc/systemd/system/getty.target.wants/getty@tty1.service"

# Define una nueva línea para el parámetro ExecStart en el archivo de unidad
# - ExecStart especifica el comando a ejecutar para iniciar el servicio.
# - -/sbin/agetty es el comando para gestionar la terminal.
# - --noissue indica que no se debe mostrar un mensaje de inicio (issue).
# - --autologin root configura el servicio para iniciar sesión automáticamente como el usuario root.
# - --noclear evita que se limpie la pantalla al iniciar sesión.
# - %I es un placeholder que se reemplaza con el identificador de la instancia de getty (por ejemplo, tty1).
# - $TERM pasa la variable de tipo de terminal al comando.
NEW_EXECSTART="ExecStart=-/sbin/agetty --noissue --autologin root --noclear %I $TERM"

# ORIGINAL (BAK): -/sbin/agetty -o '-p -- \\u' --noclear %I $TERM

# Backup del servicio
cp "$SERVICE_FILE" "$SERVICE_FILE.bak"

# Usa el comando sed para editar el archivo de unidad de systemd en línea
# - -i indica que se debe editar el archivo en el lugar (in-place).
# - "s|^ExecStart=.*|$NEW_EXECSTART|" es una expresión de sustitución:
#   - s|...|...| especifica la sustitución, utilizando el carácter '|' como delimitador.
#   - ^ExecStart=.* busca una línea que comience con "ExecStart=" seguido de cualquier cosa (.*).
#   - $NEW_EXECSTART es el nuevo valor que reemplazará a la línea que coincide con la expresión de búsqueda.
# - "$SERVICE_FILE" es la ruta del archivo de unidad que se está editando.
sed -i "s|^ExecStart=.*|$NEW_EXECSTART|" "$SERVICE_FILE"

# -----------> CONFIGURACION DEL FRONTEND <-----------

# Descargar la versión latest del frontend y guardarla en /root/frontend/frontend.AppImage
VERSION=$(curl -s -u "$USERNAME:$TOKEN" "$FRONTEND_API_URL" | grep 'tag_name' | sed 's/.*"tag_name": "\(.*\)",/\1/')
FRONTEND_URL="https://github.com/darkflowsrl/DVM-front/releases/download/$VERSION/dvm-app-front-$VERSION.AppImage"

# Descargar la última versión del frontend
echo "Descargando la última versión del frontend ($VERSION)..."

mkdir -p "$FRONTEND_DIR"

wget "$FRONTEND_URL" -O "$FRONTEND_PATH"

chmod +x "$FRONTEND_PATH"

# Creo la carpeta de data
sudo mkdir -p /root/frontend/data

# Copio el contenido de data en el servicio del frontend
sudo cp -r ./scripts/data/* /root/frontend/data/

# -----------> CONFIGURACION DEL BACKEND <-----------

# Descargar el backend y renombrar la carpeta Darkflow-HMI-Backend a backend
git clone "$BACKEND_REPO_URL" /root/DVM-Backend
mv /root/DVM-Backend "$BACKEND_DIR"

# Instalo dependencias
pip3 install -r "$REQUIREMENTS_FILE"


# -----------> CONFIGURACION DEL BASHRC (ARRANQUE) <-----------
# Reemplazar el .bashrc del root por el .bashrc en la carpeta DVM-Scripts
cp "$NEW_BASHRC" /root/.bashrc

# Copiar todos los scripts de la carpeta DVM-Scripts/scripts en /root/scripts y crear las carpetas si no existen
mkdir -p "$SCRIPTS_DST"
cp -r "$SCRIPTS_SRC"/* "$SCRIPTS_DST"

# -----------> CONFIGURACION DEL KERNEL <-----------
# Deshabilitar el loglevel del kernel en GRUB
if grep -q "GRUB_CMDLINE_LINUX_DEFAULT" "$GRUB_CFG"; then
    sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet loglevel=0 splash"/' "$GRUB_CFG"
else
    echo 'GRUB_CMDLINE_LINUX_DEFAULT="quiet loglevel=0 splash"' >> "$GRUB_CFG"
fi

# Actualizar el GRUB después de cambiar la configuración
update-grub

# -----------> CONFIGURACION DE IMAGEN SPLASH DE BOOT <-----------
# Actualizar la imagen de boot con splash.png
if [ -f "$SPLASH_IMAGE" ]; then
    cp "$SPLASH_IMAGE" /boot/grub/splash.png
fi

# -----------> CONFIGURACION DE PERMISOS <-----------
# Le doy permisos a todos los archivos
chmod +x "$BACKEND_DIR/clean.sh"
chmod +x "$BACKEND_DIR/update.sh"
chmod +x "$BACKEND_DIR/restore.sh"
chmod +x "$BACKEND_DIR/download-front.sh"

systemctl set-default multi-user.target

systemctl enable getty@tty1.servie

