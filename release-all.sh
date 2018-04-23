#!/bin/sh

RELEASE_DIR="./build/release"
TAG=0.1.0-beta

mkdir -p $RELEASE_DIR

build() {
  NODE_DIR=$RELEASE_DIR/gladius-node
  mkdir -p $NODE_DIR

  GOOS=$1 GOARCH=$2 go build -o "$NODE_DIR/gladius-networkd" "./cmd/gladius-networkd"
  GOOS=$1 GOARCH=$2 go build -o "$NODE_DIR/gladius-cli" "./cmd/gladius-cli"

  tar -czf "./build/gladius-$TAG-$1-$2.tar.gz" -C $RELEASE_DIR .

  rm -rf $NODE_DIR

  echo "Built for $1-$2"
}

for dist in "linux" "darwin" "windows"; do
  for arch in "amd64" "386"; do
    build $dist $arch
  done
done

# Create some arm packages
build linux arm64
build linux arm

rm -rf $RELEASE_DIR
