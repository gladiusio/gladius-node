#!/usr/bin/env bash
#
# Build a windows binary from linux

set -eu -o pipefail

export CC=x86_64-w64-mingw32-gcc
export CGO_ENABLED=1
export GOOS=windows
export GOARCH=amd64

echo "Building $TARGET"
go build -o "${TARGET}" "${SOURCE}"
