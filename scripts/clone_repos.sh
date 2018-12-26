#!/usr/bin/env bash
#

# Setup our variables
export SRC_DIR=/src

export CLI_SRC=${SRC_DIR}/gladius-cli
export EDGED_SRC=${SRC_DIR}/gladius-edged
export GATEWAY_SRC=${SRC_DIR}/gladius-network-gateway
export GUARDIAN_SRC=${SRC_DIR}/gladius-guardian

# Git URLs
export GUARDIAN_URL=https://github.com/gladiusio/gladius-guardian.git
export GATEWAY_URL=https://github.com/gladiusio/gladius-network-gateway.git
export EDGED_URL=https://github.com/gladiusio/gladius-edged.git
export CLI_URL=https://github.com/gladiusio/gladius-cli.git

# Which tags to checkout
export EDGED_VERSION=0.7.1
export GUARDIAN_VERSION=0.7.1
export GATEWAY_VERSION=0.7.1
export CLI_VERSION=0.7.1

# Make the src dir if it doesn't exist
mkdir -p ${SRC_DIR}

# Clone the gladius go repos we need to run a node
git clone ${GUARDIAN_URL} ${GUARDIAN_SRC}
git clone ${GATEWAY_URL} ${GATEWAY_SRC}
git clone ${EDGED_URL} ${EDGED_SRC}
git clone ${CLI_URL} ${CLI_SRC}

# Checkout the right versions
git -C ${GUARDIAN_SRC} checkout ${GUARDIAN_VERSION}
git -C ${GATEWAY_SRC} checkout ${GATEWAY_VERSION}
git -C ${EDGED_SRC} checkout ${EDGED_VERSION}
git -C ${CLI_SRC} checkout ${CLI_VERSION}

# Cache the dependencies in the image so builds are faster
cd ${CLI_SRC} && go mod download
cd ${EDGED_SRC} && go mod download
cd ${GATEWAY_SRC} && go mod download
cd ${GUARDIAN_SRC} && go mod download
