#!/bin/bash

PROJECT_NAME="gladius-node"
INSTALL_BIN="/usr/local/bin"

fail() {
  echo "$1"
  exit 1
}


# Architecture detection
initArch() {
  ARCH=$(uname -m)
  case $ARCH in
    armv5*) ARCH="armv5" ;;
    armv6*) ARCH="armv6" ;;
    armv7*) ARCH="armv7" ;;
    aarch64) ARCH="arm64" ;;
    x86) ARCH="386" ;;
    x86_64) ARCH="amd64" ;;
    i686) ARCH="386" ;;
    i386) ARCH="386" ;;
  esac
  echo "Detected architecture: $ARCH"
}

# OS Detection
initOS() {
  OS=$(echo `uname`|tr '[:upper:]' '[:lower:]')
  case "$OS" in
      # Minimalist GNU for Windows
    mingw*) OS='windows' ;;
    msys*) OS='windows' ;;
  esac
  echo "Detected OS: $OS"
}

# Check if curl is installed
initDownloadTool() {
  if type "curl" > /dev/null; then
    DOWNLOAD_TOOL="curl"
  else
    fail "You need curl as a download tool. Please install it first before continue"
  fi
  echo "Using $DOWNLOAD_TOOL as download tool"
}

getLatest(){
  # Get the latest release of the gladius-node
  TAG=$(curl --silent "https://api.github.com/repos/gladiusio/gladius-node/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |               # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'       # Pluck JSON value
  )
}

getFile() {
  local url="$1"
  local filePath="$2"
  if [ "$DOWNLOAD_TOOL" = "curl" ]; then
    httpStatusCode=$(curl -s -w '%{http_code}' -L "$url" -o "$filePath")
  fi
  echo $httpStatusCode
}

downloadFile() {
  # Build URL
  GLADIUS_DIST="gladius-$TAG-$OS-$ARCH.tar.gz"
  echo "Expected tarball is: $GLADIUS_DIST"
  DOWNLOAD_URL="https://github.com/gladiusio/gladius-node/releases/download/$TAG/$GLADIUS_DIST"

  GLADIUS_TMP_FILE="/tmp/$GLADIUS_DIST"
  echo "Attempting to download $DOWNLOAD_URL to $GLADIUS_DIST"
  httpStatusCode=$(getFile "$DOWNLOAD_URL" "$GLADIUS_TMP_FILE")
  echo "HTTPCode: $httpStatusCode"
  if [ "$httpStatusCode" -ne 200 ]; then
    echo "Did not find a release for your system: $OS $ARCH"
    fail "You can build one for your system with the instructions here: https://github.com/gladiusio/gladius-node"
  else
    echo "Downloading $DOWNLOAD_URL..."
    getFile "$DOWNLOAD_URL" "$GLIDE_TMP_FILE"
  fi
}

setupConfig(){
  CONFIG_DIR="$HOME/.config/gladius"
  CONTENT_DIR="$CONFIG_DIR/content/"

  echo -e "\nCreating files in: $CONFIG_DIR"

  mkdir -p "$CONFIG_DIR"
  mkdir -p "$CONTENT_DIR"

  CONFIG_FILE1="$CONFIG_DIR/gladius-networkd.toml"
  CONFIG_FILE2="$CONFIG_DIR/gladius-controld.toml"

  touch $CONFIG_FILE1
  touch $CONFIG_FILE2

  echo "# See the configurable values at github.com/gladiusio/gladius-node" >> $CONFIG_FILE1
  echo "# See the configurable values at github.com/gladiusio/gladius-node" >> $CONFIG_FILE2

}

installFile() {
  GLADIUS_TEMP="/tmp/$PROJECT_NAME"
  mkdir -p "$GLADIUS_TEMP"
  tar xf "$GLADIUS_TMP_FILE" -C "$GLADIUS_TEMP"
  GLADIUS_TMP_BIN="$GLADIUS_TEMP/$PROJECT_NAME"

  # Check if the install bin exists, then copy the files to it.
  mkdir -p $INSTALL_BIN
  cp -a $GLADIUS_TMP_BIN/* $INSTALL_BIN

  if [[ ":$PATH:" == *":$INSTALL_BIN:"* ]]; then
    echo "Perfect, $INSTALL_BIN is in your PATH already!"
  else
    # Ask to add it to the PATH
    read -p "Can I add $INSTALL_BIN (where the gladius executables are) to your PATH in ~/.profile? (y/n)" -n 1 REPLY
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "export PATH=\"\$PATH:$INSTALL_BIN\"" >> $HOME/.profile
      echo "Added to PATH"
    else
      echo "Ok, I won't add $INSTALL_BIN to your PATH"
    fi
  fi

  setupConfig

  echo -e "\nCleaning up temp files..."
  if $DELETE_TEMPS; then
    echo -e "Deleting binaries"
    rm -rf $GLADIUS_TEMP
  else
    echo -e "Leaving binaries intact"
  fi
  rm -f $GLADIUS_TMP_FILE
}


initArch
initOS
echo -e "\nGathering version information..."
getLatest
initDownloadTool
downloadFile
echo -e "\nInstalling"
installFile
