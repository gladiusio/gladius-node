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

CLI_DEST=$(DST_DIR)/gladius-cli$(BINARY_SUFFIX)
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
