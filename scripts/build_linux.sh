#!/usr/bin/env bash
#
# Build all linux binaries
cd /src/gladius-cli/
GOOS=linux GOARCH=amd64 go build -o /build/gladius /src/gladius-cli/cmd/main.go 

cd /src/gladius-edged/
GOOS=linux GOARCH=amd64 go build -o /build/gladius-edged /src/gladius-edged/cmd/gladius-edged/main.go

cd /src/gladius-network-gateway/
GOOS=linux GOARCH=amd64 go build -o /build/gladius-network-gateway/src/gladius-network-gateway/cmd/main.go

cd /src/gladius-guardian/
GOOS=linux GOARCH=amd64 go build -o /build/gladius-guardian /src/gladius-guardian/main.go
