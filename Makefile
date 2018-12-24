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

binaries: binaries-windows binaries-mac binaries-linux

binaries-windows:
	@docker run -it -e "TARGET=/build/gladius.exe" -e "SOURCE=./cmd/main.go" "cd /src/gladius-cli; ./scripts/build_windows.sh"
	@docker cp builder_windows:/build/gladius.exe ./build/gladius.exe
