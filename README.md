### Documentación de instalación
## DVM
---

### **Requisitos previos**
Antes de comenzar, asegúrate de tener acceso a la tablet con un sistema operativo basado en Linux y los privilegios de root habilitados. Además, la tablet debe estar conectada a Internet mediante Wi-Fi o Ethernet.

### **Pasos de instalación**

#### **Paso 1: Conectar la tablet a Internet**
1. Usa la interfaz gráfica del sistema operativo instalado en la tablet para conectarte a una red Wi-Fi.
2. Como alternativa, puedes conectar la tablet mediante un cable Ethernet.

#### **Paso 2: Clonar el repositorio de scripts**

Usa el siguiente comando para clonar el repositorio de scripts en el directorio `/root` de la tablet:
```bash
git clone https://github.com/darkflowsrl/DVM-Scripts.git /root/DVM-Scripts
```
Si `git` no está instalado, usa este comando para instalarlo:
```bash
apt-get install -y git
```
Como alternativa, si no puedes usar `git`, puedes copiar la carpeta `DVM-Scripts` desde un pendrive al directorio `/root` utilizando el gestor de archivos del sistema.

#### **Paso 3: Otorgar permisos de ejecución**

Una vez clonado o copiado el repositorio, otorga permisos de ejecución a todos los scripts dentro de la carpeta con el siguiente comando:
```bash
chmod +x -R /root/DVM-Scripts
```

#### **Paso 4: Ejecutar el script de instalación**

Para comenzar la instalación del software y las dependencias, navega a la carpeta `DVM-Scripts` y ejecuta el archivo `setup.sh`:
```bash
cd /root/DVM-Scripts
./setup.sh
```
Este script instalará el **backend**, **frontend** y otros componentes necesarios, junto con todas las dependencias requeridas.

#### **Paso 5: Reiniciar la tablet**

Una vez finalizada la instalación, reinicia la tablet para que los servicios empiecen a ejecutarse:
```bash
reboot
```

---

### **Detalles adicionales**
- **Autologin de root**: El script configura el autologin del usuario root en la terminal `tty1` para iniciar sesión automáticamente.
- **Configuración del frontend y backend**: El script se encargará de descargar la última versión del frontend desde GitHub y configurará el backend, instalando las dependencias necesarias mediante `pip3`.
- **Dependencias**: Se instalan herramientas adicionales como `htop`, `nodm`, `curl`, y `jq` para gestionar el sistema y la red.
- **Modificaciones del kernel**: Se actualiza la configuración de GRUB para desactivar los logs del kernel durante el arranque y se agrega una imagen de splash personalizada.
