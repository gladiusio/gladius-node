#!make

# Check if required executables are in the path
EXECUTABLES = docker
K := $(foreach exec,$(EXECUTABLES),\
        $(if $(shell which $(exec)),some string,$(error "You need $(exec) in PATH to build")))

# Make folders we need if they don't already exist
F := $(shell mkdir -p ./build)

# general make targets
all: build-all

clean:
	@rm -rf ./build/*

clean-repos:
	@rm -rf ./src/*
	make repos


build-all:
	make clean
	-make repos
	make cli
	make edged
	make guardian 
	make network-gateway

binaries-windows:
	@TARGET=gladius.exe SOURCE=./src/gladius-cli/cmd/main.go ./scripts/build_windows.sh
	@TARGET=gladius-edged.exe SOURCE=./src/gladius-edged/cmd/ ./scritps/build_windows.sh

binaries-mac:

binaries-linux:

release-binaries: release-mac release-linux release-windows