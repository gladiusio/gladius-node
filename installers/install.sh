#!/bin/bash

# Variables
Artifact=
Latest=
RepoLink='https://api.github.com/repos/gladiusio/gladius-node/releases/latest'
ReleaseEndpoint='https://github.com/gladiusio/gladius-node/releases/download'
Platform='unknown'
Architecture=
unamestr=$(uname)
MachineType=$(uname -m)

# Platform detection
if [[ "$unamestr" == 'Linux' ]]; then
  Platform='linux'
elif [[ "$unamestr" == 'Darwin' ]]; then
  Platform='macos'
fi

# Detect the architecture
if [ $MachineType == 'x86_64' ]; then
  Architecture='amd64'
else
  Architecture='386'
fi

# Get the latest release of the gladius-node
Latest=$(curl --silent "$RepoLink" | # Get latest release from GitHub api
  grep '"tag_name":' |               # Get tag line
  sed -E 's/.*"([^"]+)".*/\1/'       # Pluck JSON value
)


# Set the correct variables based on the detected platform
if [[ $Platform == 'linux' ]]; then
  Artifact="$ReleaseEndpoint/$Latest/linux_$Architecture.zip"
elif [[ $Platform == 'macos' ]]; then
  Artifact="$ReleaseEndpoint/$Latest/macOS_$Architecture.zip"
else
  echo "Unknown platform... See instructions for manual install on http://github.com/gladiusio/gladius-node"
  exit 1
fi

echo $Artifact
