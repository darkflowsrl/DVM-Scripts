# 🛠️ Instalación de DVM en Tablet SMART EMBEDDED

Este instructivo detalla cómo instalar y configurar el sistema DVM en una tablet SMART EMBEDDED desde cero.

---

## 📥 Paso 1: Descargar archivos necesarios

1. Descargar `data.rar` desde la **última versión** del repositorio:
   👉 [https://github.com/darkflowsrl/DVM-front/releases](https://github.com/darkflowsrl/DVM-front/releases)

2. Descargar el repositorio de scripts desde:
   👉 [https://github.com/darkflowsrl/DVM-Scripts/tree/main](https://github.com/darkflowsrl/DVM-Scripts/tree/main)

3. Descomprimir ambos archivos y guardar las carpetas resultantes en un **pendrive USB**.

---

## 🔌 Paso 2: Preparar la tablet

4. Conectar la tablet a la **corriente eléctrica**.

5. Conectar el **USB-C** de la tablet a una PC.

6. Usar un **pin** para presionar el botón del **bootloader**. Mientras lo mantenés presionado, **encender la tablet**.  
   La **luz LED debe parpadear de rojo a verde**.

7. Ejecutar el archivo `run.bat` desde la PC.  
   Esto iniciará el proceso de instalación del sistema operativo.

   > Durante la instalación, en la pantalla de la tablet debe aparecer el logo de **SMART EMBEDDED**.

   Al finalizar, el script debe mostrar el mensaje:
   ```
   Success  1 FBK: DONE
   ```

8. Desconectar la tablet del cable USB-C.

9. Reiniciar la tablet.

---

## 📁 Paso 3: Copiar archivos a la tablet

10. Insertar el **pendrive** en la tablet.

11. Copiar las carpetas descomprimidas (`data` y `DVM-Scripts-main`) al directorio `/root`.

---

## 🌐 Paso 4: Conectarse a WiFi

12. Conectar la tablet a una red WiFi.

   > ⚠️ En algunas versiones de la tablet, el botón para conectarse está **invisible a la izquierda** del botón de Bluetooth.

---

## 💻 Paso 5: Configuración del sistema

13. Abrir una **terminal** y ejecutar:

```bash
setxkbmap es
```

14. Navegar a la carpeta del repositorio:

```bash
cd DVM-Scripts-main
```

15. Dar permisos de ejecución al script:

```bash
chmod +x setup.sh
```

16. Ejecutar el script de instalación:

```bash
./setup.sh
```

17. Cuando aparezca el mensaje **“Enable nodm?”**, seleccionar **Yes**.

---

## 🧹 Paso 6: Reemplazo de datos y limpieza

18. Moverse al directorio raíz:

```bash
cd /root
```

19. Copiar el contenido de la carpeta `data` a `frontend`:

```bash
cp -r data/ frontend/
```

20. Eliminar la carpeta `data` para liberar espacio:

```bash
rm -rf /root/data
```

> ⚠️ **Cuidado** con este comando, asegúrate de que estás en `/root` antes de ejecutarlo.

---

## ⚙️ Paso 7: Autologin al iniciar

21. Editar el servicio `getty`:

```bash
nano /etc/systemd/system/getty.target.wants/getty@tty1.service
```

22. Dentro de la sección `[Service]`, modificar las líneas relacionadas con `ExecStart` como se indica:

```ini
[Service]
# the VT is cleared by TTYVTDisallocate
# The '-o' option value tells agetty to replace 'login' arguments with an
# option to preserve environment (-p), followed by '--' for safety, and then
# the entered username.
ExecStart=
ExecStart=-/sbin/agetty -a root --noclear %I $TERM
```

---

## 🔁 Paso 8: Reiniciar y verificar

23. Reiniciar la tablet:

```bash
reboot
```

24. Verificar que el sistema DVM se haya instalado y se inicie correctamente.
