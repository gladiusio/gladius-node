#!/usr/bin/env bash
#

# Check if the version is provided to checkout, if not use master
if [[ -z "${EDGED_VERSION}" ]]; then
  EDGED_VERSION="master"
fi

if [[ -z "${GUARDIAN_VERSION}" ]]; then
  GUARDIAN_VERSION="master"
fi

if [[ -z "${GATEWAY_VERSION}" ]]; then
  GATEWAY_VERSION="master"
fi

if [[ -z "${CLI_VERSION}" ]]; then
  CLI_VERSION="master"
fi

if [[ -z "${UI_VERSION}" ]]; then
  UI_VERSION="master"
fi

# Checkout the right versions
git -C $(eval "echo $GUARDIAN_SRC") checkout --quiet ${GUARDIAN_VERSION}
git -C $(eval "echo $GATEWAY_SRC") checkout --quiet ${GATEWAY_VERSION}
git -C $(eval "echo $EDGED_SRC") checkout --quiet ${EDGED_VERSION}
git -C $(eval "echo $CLI_SRC") checkout --quiet ${CLI_VERSION}
git -C $(eval "echo $UI_SRC") checkout --quiet ${UI_VERSION}
