#!/usr/bin/env bash
#
# Make the src dir if it doesn't exist
mkdir -p ${SRC_DIR}

# Clone the gladius go repos we need to run a node
git clone ${GUARDIAN_URL} $(eval "echo $GUARDIAN_SRC")
git clone ${GATEWAY_URL} $(eval "echo $GATEWAY_SRC")
git clone ${EDGED_URL} $(eval "echo $EDGED_SRC")
git clone ${CLI_URL} $(eval "echo $CLI_SRC")
git clone ${UI_URL} $(eval "echo $UI_SRC")

# Cache (most of) the dependencies in the image so builds are faster
cd ${CLI_SRC} && go mod download
cd ${EDGED_SRC} && go mod download
cd ${GATEWAY_SRC} && go mod download
cd ${GUARDIAN_SRC} && go mod download
