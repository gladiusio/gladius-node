#!/bin/sh

RELEASE_DIR="./build/release"
TAG=0.1.0-beta

mkdir -p $RELEASE_DIR

for dist in "linux" "darwin" "windows"; do
  for arch in "amd64" "386"; do
    NODE_DIR=$RELEASE_DIR/gladius-node
    mkdir -p $NODE_DIR

    GOOS=$dist GOARCH=$arch go build -o "$NODE_DIR/gladius-networkd" "./cmd/gladius-networkd"
    GOOS=$dist GOARCH=$arch go build -o "$NODE_DIR/gladius-cli" "./cmd/gladius-cli"

    tar -czf "./build/gladius-$TAG-$dist-$arch.tar.gz" -C $RELEASE_DIR .

    rm -rf $NODE_DIR

    echo "Built for $dist-$arch"
  done
done

rm -rf $RELEASE_DIR
