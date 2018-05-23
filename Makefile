##
## Makefile to test and build the gladius binaries
##

##
# GLOBAL VARIABLES
##

# if we are running on a windows machine
# we need to append a .exe to the
# compiled binary
BINARY_SUFFIX=
ifeq ($(OS),Windows_NT)
	BINARY_SUFFIX=.exe
endif

ifeq ($(GOOS),windows)
	BINARY_SUFFIX=.exe
endif

# code source and build directories
SRC_DIR=./cmd
DST_DIR=./build

CLI_SRC=$(SRC_DIR)/gladius-cli
NET_SRC=$(SRC_DIR)/gladius-networkd
CTL_SRC=$(SRC_DIR)/gladius-controld

CLI_DEST=$(DST_DIR)/gladius$(BINARY_SUFFIX)
NET_DEST=$(DST_DIR)/gladius-networkd$(BINARY_SUFFIX)
CTL_DEST=$(DST_DIR)/gladius-controld$(BINARY_SUFFIX)

# commands for go
GOBUILD=go build
GOTEST=go test
##
# MAKE TARGETS
##

# general make targets
all: build-all

clean:
	rm -rf ./build/*
	go clean

# dependency management
dependencies:
	# install go packages
	dep ensure

	# Deal with the ethereum cgo bindings
	go get github.com/ethereum/go-ethereum
	cp -r \
  "${GOPATH}/src/github.com/ethereum/go-ethereum/crypto/secp256k1/libsecp256k1" \
  "vendor/github.com/ethereum/go-ethereum/crypto/secp256k1/"

release:
	sh ./ops/release-all.sh

# build steps
test-cli: $(CLI_SRC)
	$(GOTEST) $(CLI_SRC)

cli: test-cli
	$(GOBUILD) -o $(CLI_DEST) $(CLI_SRC)

test-networkd: $(NET_SRC)
	$(GOTEST) $(NET_SRC)

networkd: test-networkd
	$(GOBUILD) -o $(NET_DEST) $(NET_SRC)

test-controld: $(CTL_SRC)
	$(GOTEST) $(CTL_SRC)

controld: test-controld
	$(GOBUILD) -o $(CTL_DEST) $(CTL_SRC)

build-all: cli networkd controld

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
