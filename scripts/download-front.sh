#!/bin/bash

if [ $# -lt 4 ] ;then
    echo "Usage: <github token> <org/repo> <filename> <version or 'latest'>"
    exit 1
fi

TOKEN="$1"
REPO="$2"
FILE="$3"      # the name of your release asset file, e.g. build.tar.gz
VERSION="$4"                       # tag name or the word "latest"
GITHUB_API_ENDPOINT="api.github.com"

alias errcho='>&2 echo'

# dpkg --configure -a
# apt update && apt upgrade

# apt install -y jq curl unrar

function gh_curl() {
  curl -sL -H "Authorization: token $TOKEN" \
       -H "Accept: application/vnd.github.v3.raw" \
       $@
}

if [ "$VERSION" = "latest" ]; then
  # Github should return the latest release first.
  PARSER=".[0].assets | map(select(.name == \"$FILE\"))[0].id"
else
  PARSER=". | map(select(.tag_name == \"$VERSION\"))[0].assets | map(select(.name == \"$FILE\"))[0].id"
fi

ASSET_ID=`gh_curl https://$GITHUB_API_ENDPOINT/repos/$REPO/releases | jq "$PARSER"`
if [ "$ASSET_ID" = "null" ]; then
  errcho "ERROR: version not found $VERSION"
  exit 1
fi

m=$(curl -sL --header "Authorization: token $TOKEN" --header 'Accept: application/octet-stream' https://$TOKEN:@$GITHUB_API_ENDPOINT/repos/$REPO/releases/assets/$ASSET_ID > /root/$FILE 2>&1)
#m=$(curl -sL --header "Authorization: token $TOKEN" --header 'Accept: application/octet-stream' https://$TOKEN:@$GITHUB_API_ENDPOINT/repos/$REPO/releases/assets/$ASSET_ID > $FILE 2>&1)
if [ $? -ne 0 ] ; then
  echo "Error: ""$m"
  exit 1  
fi

chmod +x "/root/$FILE"
#chmod +x "$FILE"
if [ $? -ne 0 ]; then
  echo "Error al asignar permisos de ejecución al archivo AppImage"
  exit 1
fi

if [ "$VERSION" = "latest" ]; then
  # Github should return the latest release first.
  PARSER=".[0].assets | map(select(.name == \"data.rar\"))[0].id"
else
  PARSER=". | map(select(.tag_name == \"$VERSION\"))[0].assets | map(select(.name == \"data.rar\"))[0].id"
fi

ASSET_ID=`gh_curl https://$GITHUB_API_ENDPOINT/repos/$REPO/releases | jq "$PARSER"`
if [ "$ASSET_ID" != "null" ]; then
  m=$(curl -sL --header "Authorization: token $TOKEN" --header 'Accept: application/octet-stream' https://$TOKEN:@$GITHUB_API_ENDPOINT/repos/$REPO/releases/assets/$ASSET_ID > /root/data.rar 2>&1)
  if [ $? -ne 0 ] ; then
    echo "Error: ""$m"
    exit 1
  fi

  # BACKUP_FILES_CONFIG_DIR="/root/backup_files_config_$(date +%Y%m%d_%H%M%S)"
  # mkdir -p "$BACKUP_FILES_CONFIG_DIR" 
  # cp -r /root/dvm-app-front/* "$BACKUP_FILES_CONFIG_DIR" 
  
  mkdir -p "/root/dvm-app-front"
  #mkdir -p "dvm-app-front"
  unrar x -y -r /root/data.rar /root/dvm-app-front
  #unrar x -y -r data.rar dvm-app-front
  chmod -R 777 "/root/dvm-app-front"
  #chmod -R 777 "dvm-app-front"
  echo "Agregando archivos de configuración"
fi

  