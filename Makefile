#!make

# Check if required executables are in the path
EXECUTABLES = docker
K := $(foreach exec,$(EXECUTABLES),\
        $(if $(shell which $(exec)),some string,$(error "You need $(exec) in PATH to build")))

# Make folders we need if they don't already exist
F := $(shell mkdir -p ./build)

# general make targets
all: binaries

clean:
	@rm -rf ./build/*
	@docker rm node-builder

releases: binaries tar-binaries

binaries: binaries-windows binaries-mac binaries-linux

binaries-windows:
	@mkdir -p ./build/windows

	@echo "Building windows binaries"
	@docker run --name node-builder gladiusio/node-env "/scripts/build_windows.sh"
	
	@docker cp node-builder:/build/. ./build/windows/
	@docker rm node-builder

binaries-mac:
	@mkdir -p ./build/mac	
	@echo "Building mac binaries"
	@docker run --name node-builder gladiusio/node-env "/scripts/build_osx.sh"
	
	@docker cp node-builder:/build/. ./build/mac/
	@docker rm node-builder

binaries-linux:
	@mkdir -p ./build/linux	
	@echo "Building linux binaries"
	@docker run --name node-builder gladiusio/node-env "/scripts/build_linux.sh"
	
	@docker cp node-builder:/build/. ./build/linux/
	@docker rm node-builder

docker-image:
	@docker build -t gladiusio/node-env .

tar-binaries:
	@find ./build/* -type d -exec ``tar -C {} -czvf {}.tar.gz . \;``
	@mkdir -p ./build/releases
	@mv ./build/*.tar.gz ./build/releases