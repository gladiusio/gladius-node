#!make

# Check if required executables are in the path
EXECUTABLES = docker tar
K := $(foreach exec,$(EXECUTABLES),\
        $(if $(shell which $(exec)),some string,$(error "You need $(exec) in PATH to build")))

# Make folders we need if they don't already exist
F := $(shell mkdir -p ./build)

RELEASE_VERSION := $(shell git describe --tags)

# general make targets
all: binaries

clean:
	@rm -rf ./build/*
	-@docker rm node-mac-builder
	-@docker rm node-windows-builder
	-@docker rm node-linux-builder
	-@docker rm node-arm-builder

releases: binaries tar-binaries

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

tar-binaries:
	pwd
	@find ./build/* -type d -exec ``tar -C {} -czf {}.tar.gz . \;``
	@mkdir -p ./build/releases
	@mv ./build/*.tar.gz ./build/releases