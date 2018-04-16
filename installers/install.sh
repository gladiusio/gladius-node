#!/bin/bash

# Platform detection
Platform='unknown'
unamestr = $(uname)
if [[ "$unamestr" == 'Linux' ]]; then
   Platform='linux'
elif [[ "$unamestr" == 'FreeBSD' ]]; then
   Platform='freebsd'
fi

MachingType=`uname -m`
Architecture=''
if [ ${MACHINE_TYPE} == 'x86_64' ]; then
  Architecture='amd64'
else
  Architecture='386'
fi

Latest=get_latest_release

# Set the correct variables based on the detected platform
if [[ $Platform == 'linux' ]]; then
  Artifact="https://github.com/gladiusio/gladius-node/releases/download/$Latest/linux_${Architecture}.zip"
elif [[ $Platform == 'darwin' ]]; then
  Artifact="https://github.com/gladiusio/gladius-node/releases/download/$Latest/macOS_${Architecture}.zip"
else
  echo "Unknown platform... See instructions for manual install on http://github.com/gladiusio/gladius-node"
  exit 1
fi


# Get the latest release of the gladius-node
get_latest_release() {
  curl --silent "https://api.github.com/repos/gladiusio/gladius-node/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}
