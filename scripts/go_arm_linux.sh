#!/usr/bin/env bash
#
# Build a arm linux binary from linux

set -eu -o pipefail

export CC=arm-linux-gnueabihf-gcc
export CGO_ENABLED=1
export GOOS=linux
export GOARCH=arm

echo "Building $TARGET"
cd ${PROJECT_ROOT}
go build -o "${TARGET}" "${SOURCE}"
