##
## Makefile to test and build the gladius binaries
##

##
# GLOBAL VARIABLES 
##

# golang requirements
# thanks to: https://gist.github.com/azer/7c83d0b59de8328355ad
GOPATH=$(CURDIR)/vendor:$(CURDIR)

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
# control daemon source is not yet available
CTL_SRC=$(SRC_DIR)/gladius-controld

CLI_DEST=$(DST_DIR)/gladius-cli$(BINARY_SUFFIX)
NET_DEST=$(DST_DIR)/gladius-networkd$(BINARY_SUFFIX)
# control daemon source is not yet available
CTL_DEST=$(DST_DIR)/gladius-controld$(BINARY_SUFFIX)

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
	glide install
	# creae a softlink referencing the current directory in
	# vendor/github.com. this is needed so we can compile
	# networkd 
	# @TODO: implement proper dpendency paths
	mkdir -p vendor/src/github.com/gladiusio/
	ln -s $(CURDIR) vendor/src/github.com/gladiusio/gladius-node

# build steps
test-cli: dependencies $(CLI_SRC)
	echo "tests not implemented yet"

cli: test-cli
	go build -o $(CLI_DEST) $(CLI_SRC)

test-networkd: dependencies $(NET_SRC)
	echo "tests not implemented yet"

networkd: #test-networkd
	GOPATH=$(GOPATH) go build -o $(NET_DEST) $(NET_SRC)

test-controld: dependencies $(CTL_SRC)
	echo "tests not implemented yet"

controld: test-controld
	go build -o $(CTL_DEST) $(CTL_SRC)

build-all: dependencies cli networkd controld
