#!/bin/sh

RELEASE_DIR="./build/release"
TAG=0.1.0-beta

mkdir -p $RELEASE_DIR

build() {
  node_dir=$RELEASE_DIR/gladius-node
  mkdir -p $node_dir

  Suffix=

  if [ $1 = "windows" ]
  then
    Suffix=".exe"
  fi

  GOOS=$1 GOARCH=$2 go build -o "$node_dir/gladius-networkd$Suffix" "./cmd/gladius-networkd"
  GOOS=$1 GOARCH=$2 go build -o "$node_dir/gladius$Suffix" "./cmd/gladius-cli"
  GOOS=$1 GOARCH=$2 go build -o "$node_dir/gladius-controld$Suffix" "./cmd/gladius-controld"


  tar -czf "./build/gladius-$TAG-$1-$2.tar.gz" -C $RELEASE_DIR .

  rm -rf $RELEASE_DIR

  echo "Built for $1-$2"
}

# Create some arm packages
build linux arm64
build linux arm

for dist in "linux" "darwin" "windows" "freebsd"; do
  for arch in "amd64" "386"; do
    build $dist $arch
  done
done

rm -rf $RELEASE_DIR
