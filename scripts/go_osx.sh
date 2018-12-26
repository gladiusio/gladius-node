#!/usr/bin/env bash
#
# Build an osx binary from linux

set -eu -o pipefail

export CGO_ENABLED=1
export GOOS=darwin
export GOARCH=amd64
export CC=o64-clang
export CXX=o64-clang++
export LDFLAGS="$LDFLAGS -linkmode external -s"
export LDFLAGS_STATIC_DOCKER='-extld='${CC}

echo "Building $TARGET"
cd ${PROJECT_ROOT}
go build -o "${TARGET}" --ldflags "${LDFLAGS}" "${SOURCE}"
