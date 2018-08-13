#!/bin/sh

RELEASE_DIR="./build/release"

mkdir -p $RELEASE_DIR

build() {
  node_dir=$RELEASE_DIR/gladius-node
  mkdir -p $node_dir

  Suffix=

  if [ $1 = "windows" ]
  then
    suffix=".exe"
  fi

  GOOS=$1 GOARCH=$2 go build -o "$node_dir/gladius-networkd$suffix" "./cmd/gladius-networkd"
  GOOS=$1 GOARCH=$2 go build -o "$node_dir/gladius$suffix" "./cmd/gladius-cli"
  xgo --targets="$1/$2" --out="gladius-controld" --dest="$node_dir" "./cmd/gladius-controld"

  mv $node_dir/gladius-controld-* $node_dir/gladius-controld$suffix

  # Copy bins to Windows Installer
  if [ $1 = "windows" ] && [ $2 = "amd64" ]
  then
    cp $node_dir/* "./installers/gladius-node-win-installer"
  fi

  # Copy bins to macOS Xcode Project
  if [ $1 = "darwin" ] && [ $2 = "amd64" ]
  then
    cp $node_dir/* "./installers/gladius-node-mac-installer/Manager/Shared"
  fi

  tar -czf "./build/gladius-$TAG-$1-$2.tar.gz" -C $RELEASE_DIR .

  rm -rf $RELEASE_DIR

  echo "Built for $1-$2"
}

# Create some arm packages
build linux arm64
build linux arm

for dist in "linux" "darwin" "windows"; do
  for arch in "amd64" "386"; do
    build $dist $arch
  done
done

rm -rf $RELEASE_DIR
