#!/usr/bin/env bash
#
# Build all UI apps

cd $(eval "echo $UI_SRC")
npm install && npm run build && npm run package-mac && npm run package-win
