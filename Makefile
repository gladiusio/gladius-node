##
## Makefile to test and build the gladius binaries
##

##
# GLOBAL VARIABLES
##

# if we are running on a windows machine
# we need to append a .exe to the
BINARY_SUFFIX=
ifeq ($(OS),Windows_NT)
	BINARY_SUFFIX=.exe
endif

ifeq ($(GOOS),windows)
	BINARY_SUFFIX=.exe
endif

# code source and build directories
SRC_DIR=./src
DST_DIR=./build

CLI_SRC=$(SRC_DIR)/gladius-cli
EDGED_SRC=$(SRC_DIR)/gladius-edged
GATEWAY_SRC=$(SRC_DIR)/gladius-network-gateway
GUARD_SRC=$(SRC_DIR)/gladius-guardian

CLI_BUILD=$(SRC_DIR)/gladius-cli/build
EDGED_BUILD=$(SRC_DIR)/gladius-edged/build
GATEWAY_BUILD=$(GATEWAY_SRC)/build
GUARD_BUILD=$(GUARD_SRC)/build

CLI_DEST=$(DST_DIR)/gladius$(BINARY_SUFFIX)
EDGED_DEST=$(DST_DIR)/gladius-edged$(BINARY_SUFFIX)
GATEWAY_DEST=$(DST_DIR)/gladius-network-gateway$(BINARY_SUFFIX)
GUARD_DEST=$(DST_DIR)/gladius-guardian$(BINARY_SUFFIX)

##
# MAKE TARGETS
##

# general make targets
all: build-all

# clone repositories
repos:
	# sources
	git clone git@github.com:gladiusio/gladius-guardian.git src/gladius-guardian
	git clone git@github.com:gladiusio/gladius-network-gateway.git src/gladius-network-gateway
	git clone git@github.com:gladiusio/gladius-edged.git src/gladius-edged
	git clone git@github.com:gladiusio/gladius-cli.git src/gladius-cli

	# installers
	git clone git@github.com:gladiusio/gladius-node-installer-macos.git installers/gladius-node-mac-installer
	git clone git@github.com:gladiusio/gladius-node-installer-windows.git installers/gladius-node-win-installer

# define cleanup target for windows and *nix
ifeq ($(OS),Windows_NT)
clean:
	del /Q /F .\\installers\\gladius-node-*\\*
	del /Q /F .\\build\\*
else
clean:
	rm -rf installers/gladius-node-*
	rm -rf ./build/*
endif

# the release target is only available on *nix like systems
ifneq ($(OS),Windows_NT)
release:
	make clean
	sh ./ops/release-all.sh
endif

# build steps
test-cli:# $(CLI_SRC)
	$(GOTEST) $(CLI_SRC)

cli:# test-cli
	cd $(CLI_SRC) && $(MAKE)
	cp $(CLI_BUILD)/* $(CLI_DEST)

test-edged:# $(EDGED_SRC)
	cd $(EDGED_SRC) && $(MAKE) 

edged:# test-edged
	cd $(EDGED_SRC) && $(MAKE)
	cp $(EDGED_BUILD)/* $(EDGED_DEST)

guardian:
	cd $(GUARD_SRC) && $(MAKE)
	cp $(GUARD_BUILD)/* $(GUARD_DEST)

test-network-gateway: $(GATEWAY_SRC)
	$(GOTEST) $(EDGED_CMD)

network-gateway:
	cd $(GATEWAY_SRC) && $(MAKE)
	cp $(GATEWAY_BUILD)/* $(GATEWAY_DEST)

build-all: 
	make clean
	make cli
	make edged
	make guardian 
	make network-gateway

# docker build based on releases
# you must specify the release tag for the build process
# make docker DOCKER_RELEASE=0.2.2
DOCKER_IMAGE ?= gladiusio/gladius-node
DOCKER_RELEASE_COMMIT := $(shell git rev-list --tags --max-count=1)
DOCKER_RELEASE ?= $(shell git describe --tags ${DOCKER_RELEASE_COMMIT})

# get the cpu architecture to choose the correct dockerfile for the build
# https://stackoverflow.com/questions/714100/os-detecting-makefile
ifeq ($(OS),Windows_NT)
	DOCKER_OS ?= windows
	ifeq ($(PROCESSOR_ARCHITEW6432),AMD64)
		DOCKER_ARCH ?= amd64
	else
		ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
			DOCKER_ARCH ?= amd64
		endif
		ifeq ($(PROCESSOR_ARCHITECTURE),x86)
			DOCKER_ARCH ?= 386
		endif
	endif
else
	# check if we are running mac os x - by default we will use amd64 in thise case (docker for mac is a linux 64bit machine)
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Darwin)
		DOCKER_OS ?= linux
		DOCKER_ARCH ?= amd64
	endif
	# if we run linux we need to check which processor arch we run on
	ifeq ($(UNAME_S),Linux)
		DOCKER_OS ?= linux
		UNAME_R := $(shell uname -r)
		ifneq (,$(findstring amd64,$(UNAME_R)))
    		DOCKER_ARCH ?= amd64
    	endif
    	ifneq (,$(findstring i386,$(UNAME_R)))
    		DOCKER_ARCH ?= 386
    	endif
    	ifneq (,$(findstring arm,$(UNAME_R)))
    		DOCKER_ARCH ?= arm
    	endif
    endif
endif
docker_image:
	docker build --tag ${DOCKER_IMAGE}:${DOCKER_RELEASE} \
		--build-arg gladius_release=${DOCKER_RELEASE} \
		--build-arg gladius_os=${DOCKER_OS} \
		--build-arg gladius_architecture=${DOCKER_ARCH} \
		-f ./ops/Dockerfile ./ops

docker_push: docker_image
	docker push ${DOCKER_IMAGE}:${DOCKER_RELEASE}

# execute local docker compose for testing
docker_compose:
	# build docker compose image
	docker-compose -p gladius -f ops/docker-compose.yml build \
		--build-arg gladius_release=${DOCKER_RELEASE} \
		--build-arg gladius_os=${DOCKER_OS} \
		--build-arg gladius_architecture=${DOCKER_ARCH} \

	# start services
	docker-compose -p gladius -f ops/docker-compose.yml up -d

# cleanup local docker compose
docker_compose_cleanup:
	docker-compose -p gladius -f ops/docker-compose.yml rm -fsv
