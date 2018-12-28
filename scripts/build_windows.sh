#!/usr/bin/env bash
#
# Build all windows binaries

TARGET=/build/gladius.exe SOURCE=/src/gladius-cli/cmd/main.go PROJECT_ROOT=/src/gladius-cli /scripts/go_windows.sh
TARGET=/build/gladius-edged.exe SOURCE=/src/gladius-edged/cmd/gladius-edged/main.go PROJECT_ROOT=/src/gladius-edged /scripts/go_windows.sh
TARGET=/build/gladius-network-gateway.exe SOURCE=/src/gladius-network-gateway/cmd/main.go PROJECT_ROOT=/src/gladius-cli /scripts/go_windows.sh
TARGET=/build/gladius-guardian.exe SOURCE=/src/gladius-guardian/main.go PROJECT_ROOT=/src/gladius-guardian /scripts/go_windows.sh
