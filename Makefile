#!make

# Check if required executables are in the path
EXECUTABLES = docker tar
K := $(foreach exec,$(EXECUTABLES),\
        $(if $(shell which $(exec)),some string,$(error "You need $(exec) in PATH to build")))

# Wine is only needed for building windows installer
DOT := $(shell command -v dot 2> /dev/null)

# Detect our OS
OS := $(shell uname)

# Make folders we need if they don't already exist
F := $(shell mkdir -p ./build)

RELEASE_VERSION := $(shell git describe --tags)

# general make targets
all: binaries build-uis

clean:
	@rm -rf ./build/*
	-@docker rm node-mac-builder
	-@docker rm node-windows-builder
	-@docker rm node-linux-builder
	-@docker rm node-arm-builder
	-@docker rm node-ui-builder

release-binaries: binaries tar-binaries

build-uis:
	@echo "Building UIs"
	@docker run --name node-ui-builder --env-file .env gladiusio/node-env /bin/bash -c "/scripts/checkout_repos.sh; /scripts/build_ui.sh"
	
	@docker cp node-ui-builder:/src/gladius-node-ui/build/release/macos/Gladius-darwin-x64/Gladius.app ./build/gladius-$(RELEASE_VERSION)-mac-ui.app
	@docker cp node-ui-builder:/src/gladius-node-ui/build/release/windows/gladius-electron-win32-x64 ./build/gladius-$(RELEASE_VERSION)-windows-ui

	@docker rm node-ui-builder

build-windows-installer:
ifeq (, $(shell which wine))
	$(error "No wine in $(PATH), consider doing apt-get install wine")
endif
ifeq (,$(wildcard ./build/gladius-$(RELEASE_VERSION)-windows-amd64))
	$(error "No recent (this git tag) windows binaries found, run make binaries-windows to build them")
endif
ifeq (,$(wildcard ./build/gladius-$(RELEASE_VERSION)-windows-ui))
	$(error "No recent (this git tag) windows UI found, run make build-uis to build it")
endif
	
	@echo "Building windows installer from binaries and ui"

	@echo "Cloning windows installer source"
	@mkdir -p ./src
	-@git clone https://github.com/gladiusio/gladius-node-installer-windows.git ./src/gladius-node-installer-windows
	
	@echo "Copying build files into installer"
	@cp -r ./build/gladius-$(RELEASE_VERSION)-windows-amd64/* ./src/gladius-node-installer-windows
	@mkdir -p ./src/gladius-node-installer-windows/gladius-electron-win32-x64
	@cp -r ./build/gladius-$(RELEASE_VERSION)-windows-ui/* ./src/gladius-node-installer-windows/gladius-electron-win32-x64


	@echo "Downloading and extracting innosetup binaries"
	@curl -o ./src/innosetup.tar.gz https://gladius-development-assets.sfo2.digitaloceanspaces.com/innosetup.tar.gz
	@tar -xzf ./src/innosetup.tar.gz -C ./src

	@echo "Building installer"
	@wine ./src/innosetup/ISCC.exe ./src/gladius-node-installer-windows/install-script.iss

build-mac-app:
ifeq ($(OS), Darwin)
	@echo "macOS detected, building..."
else
	$(error "$(OS) detected - must be macOS for code signing")
endif


binaries: binaries-windows binaries-mac binaries-linux binaries-arm-linux

binaries-windows:
	@mkdir -p ./build/gladius-$(RELEASE_VERSION)-windows-amd64/

	@echo "Building windows binaries"
	@docker run --name node-windows-builder --env-file .env gladiusio/node-env /bin/bash -c "/scripts/checkout_repos.sh; /scripts/build_windows.sh"
	
	@docker cp node-windows-builder:/build/. ./build/gladius-$(RELEASE_VERSION)-windows-amd64/
	@docker rm node-windows-builder

binaries-mac:
	@mkdir -p ./build/gladius-$(RELEASE_VERSION)-darwin-amd64/	
	@echo "Building mac binaries"
	@docker run --name node-mac-builder --env-file .env gladiusio/node-env /bin/bash -c "/scripts/checkout_repos.sh; /scripts/build_osx.sh"
	
	@docker cp node-mac-builder:/build/. ./build/gladius-$(RELEASE_VERSION)-darwin-amd64/
	@docker rm node-mac-builder

binaries-linux:
	@mkdir -p ./build/gladius-$(RELEASE_VERSION)-linux-amd64/
	@echo "Building linux binaries"
	@docker run --name node-linux-builder --env-file .env gladiusio/node-env /bin/bash -c "/scripts/checkout_repos.sh; /scripts/build_linux.sh"
	
	@docker cp node-linux-builder:/build/. ./build/gladius-$(RELEASE_VERSION)-linux-amd64/
	@docker rm node-linux-builder

binaries-arm-linux:
	@mkdir -p ./build/gladius-$(RELEASE_VERSION)-linux-arm/
	@echo "Building arm-linux binaries"
	@docker run --name node-arm-builder --env-file .env gladiusio/node-env /bin/bash -c "/scripts/checkout_repos.sh; /scripts/build_arm_linux.sh"
	
	@docker cp node-arm-builder:/build/. ./build/gladius-$(RELEASE_VERSION)-linux-arm/
	@docker rm node-arm-builder

docker-image:
	@docker build -t gladiusio/node-env .
	@docker push gladiusio/node-env:latest

tar-binaries:
	@find ./build/* -type d -exec ``tar -C {} -czf {}.tar.gz . \;``
	@mkdir -p ./build/releases
	@mv ./build/*.tar.gz ./build/releases