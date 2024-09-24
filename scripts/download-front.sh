#!/usr/bin/csh

if [ $# -lt 1 ] ;then
    echo "Usage: <version or 'latest'>"
    exit 1
fi

VERSION="$1" # tag name or the word "latest"
REPO=darkflowsrl/DVM-front
FILE=frontend.AppImage
GITHUB_API_ENDPOINT="api.github.com"

USER="giulicrenna"
alias errcho='>&2 echo'

# apt install -y jq curl unrar

function gh_curl() {
  curl -u "$USER:$TOKEN" \
       $@
}

if [ "$VERSION" = "latest" ]; then
  # Github should return the latest release first.
  PARSER=".[0].assets | map(select(.name == \"$FILE\"))[0].id"
else
  PARSER=". | map(select(.tag_name == \"$VERSION\"))[0].assets | map(select(.name == \"$FILE\"))[0].id"
fi

ASSET_ID=`gh_curl https://$GITHUB_API_ENDPOINT/repos/$REPO/releases | jq "$PARSER"`
echo "ASSET_ID: $ASSET_ID"
if [ "$ASSET_ID" = "null" ]; then
  errcho "ERROR: version not found $VERSION"
  exit 1
fi


m=$(curl -sL --header 'Accept: application/octet-stream' -u $USER:$TOKEN https://$GITHUB_API_ENDPOINT/repos/$REPO/releases/assets/$ASSET_ID > /root/frontend/$FILE.temp 2>&1)

if [ $? -ne 0 ] ; then
  echo "Error: ""$m"
  exit 1
fi

yes | cp -f "/root/frontend/$FILE.temp" "/root/frontend/$FILE"

rm "/root/frontend/$FILE.temp"

chmod +x "/root/frontend/$FILE"

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

  m=$(curl -sL --header 'Accept: application/octet-stream' -u $USER:$TOKEN https://$GITHUB_API_ENDPOINT/repos/$REPO/releases/assets/$ASSET_ID > /root/data.rar 2>&1)

  if [ $? -ne 0 ] ; then
    echo "Error: ""$m"
    exit 1
  fi

  mkdir -p "/root/frontend/data"
  unrar x -y -r /root/data.rar /root/frontend/data
  rm /root/data.rar
  chmod -R 777 "/root/frontend"
  echo "Agregando archivos de configuración"
fi

