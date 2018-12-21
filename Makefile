#!make
include .config

# Check if required executables are in the path
EXECUTABLES = xgo docker git
K := $(foreach exec,$(EXECUTABLES),\
        $(if $(shell which $(exec)),some string,$(error "You need $(exec) in PATH to build")))

# Make folders we need if they don't already exist
F := $(shell mkdir -p ./src ./build)

# general make targets
all: build-all

# clone and checkout the right tag on each repo
repos:
	@git clone $(GUARDIAN_URL) $(GUARIDAN_SRC)
	@git clone $(GATEWAY_URL) $(GATEWAY_SRC)
	@git clone $(EDGED_URL) $(EDGED_SRC)
	@git clone $(CLI_URL) $(CLI_SRC)
	@git clone $(UI_URL) $(UI_SRC)

	@git -C $(GUARIDAN_SRC) checkout $(GUARDIAN_VERSION)
	@git -C $(GATEWAY_SRC) checkout $(GATEWAY_VERSION)
	@git -C $(EDGED_SRC) checkout $(EDGED_VERSION)
	@git -C $(CLI_SRC) checkout $(CLI_VERSION)
	@git -C $(UI_SRC) checkout $(UI_VERSION)

clean:
	@rm -rf ./build/*

clean-repos:
	@rm -rf ./src/*
	make repos

# build steps
test-cli:# $(CLI_SRC)
	$(GOTEST) $(CLI_SRC)

cli:# test-cli
	cd $(CLI_SRC) && $(MAKE)
	cp $(CLI_BUILD)/* $(CLI_DEST)

edged:# test-edged
	cd $(EDGED_SRC) && $(MAKE)
	cp $(EDGED_BUILD)/* $(EDGED_DEST)

guardian:
	cd $(GUARD_SRC) && $(MAKE)
	cp $(GUARD_BUILD)/* $(GUARD_DEST)

network-gateway:
	cd $(GATEWAY_SRC) && $(MAKE)
	cp $(GATEWAY_BUILD)/* $(GATEWAY_DEST)

build-all:
	make clean
	-make repos
	make cli
	make edged
	make guardian 
	make network-gateway

# Made for macOS at the moment
# Install gcc cross compilers for macOS
# `brew install mingw-w64` - windows
# `brew install FiloSottile/musl-cross/musl-cross` - linux
# `brew install wine` - for compiling electron-ui for windows

release-binaries: release-mac release-linux release-windows

release-clean: clean clean-repos release-binaries

release-ui: release-mac-with-ui release-linux-with-ui release-windows-with-ui

release-clean-ui: release-clean release-ui

# Full cleaned release with binaries and UI for all platforms
release: release-clean-ui

release-mac:
	rm -rf $(RELEASE_DIR)/macos
	mkdir -p $(RELEASE_DIR)/macos

	cd $(CLI_SRC) && $(MAKE) release-mac
	cp $(CLI_BUILD)/release/macos/* $(RELEASE_DIR)/macos/

	cd $(EDGED_SRC) && $(MAKE) release-mac
	cp $(EDGED_BUILD)/release/macos/* $(RELEASE_DIR)/macos/

	cd $(GUARD_SRC) && $(MAKE) release-mac
	cp $(GUARD_BUILD)/release/macos/* $(RELEASE_DIR)/macos/

	cd $(GATEWAY_SRC) && $(MAKE) release-mac
	cp $(GATEWAY_BUILD)/release/macos/* $(RELEASE_DIR)/macos/

	# Copy Go Binaries to Installers
	cp $(RELEASE_DIR)/macos/* installers/gladius-node-mac-installer/Manager/Shared/

	# Create tarballs
	cd build/release/macos && tar -czf "gladius-$(VERSION)-darwin-amd64.tar.gz" gladius*

release-mac-with-ui: release-mac
	cd $(UI_SRC) && npm install && npm run build && npm run package-mac
	cp -r $(UI_BUILD)/release/macos/* $(RELEASE_DIR)/macos/

	# Copy Electron app to Installers
	rm -rf installers/gladius-node-mac-installer/Manager/Electron/Gladius.app
	cp -r build/release/macos/Gladius-darwin-x64/Gladius.app installers/gladius-node-mac-installer/Manager/Electron/Gladius.app

release-linux:
	rm -rf $(RELEASE_DIR)/linux
	mkdir -p $(RELEASE_DIR)/linux

	cd $(CLI_SRC) && $(MAKE) release-linux
	cp $(CLI_BUILD)/release/linux/* $(RELEASE_DIR)/linux/

	cd $(EDGED_SRC) && $(MAKE) release-linux
	cp $(EDGED_BUILD)/release/linux/* $(RELEASE_DIR)/linux/

	cd $(GUARD_SRC) && $(MAKE) release-linux
	cp $(GUARD_BUILD)/release/linux/* $(RELEASE_DIR)/linux/

	cd $(GATEWAY_SRC) && $(MAKE) release-linux
	cp $(GATEWAY_BUILD)/release/linux/* $(RELEASE_DIR)/linux/

	# Copy Go Binaries to Installers
	cp $(RELEASE_DIR)/linux/* installers/gladius-node-mac-installer/Manager/Shared/

	# Create tarballs
	cd build/release/linux && tar -czf "gladius-$(VERSION)-linux-amd64.tar.gz" gladius*

release-linux-with-ui:
	cd $(UI_SRC) && npm install && npm run build && npm run package-linux
	cp -r $(UI_BUILD)/release/linux/* $(RELEASE_DIR)/linux/

release-windows:
	rm -rf $(RELEASE_DIR)/windows
	mkdir -p $(RELEASE_DIR)/windows

	cd $(CLI_SRC) && $(MAKE) release-win
	cp $(CLI_BUILD)/release/windows/* $(RELEASE_DIR)/windows/

	cd $(EDGED_SRC) && $(MAKE) release-win
	cp $(EDGED_BUILD)/release/windows/* $(RELEASE_DIR)/windows/

	cd $(GUARD_SRC) && $(MAKE) release-win
	cp $(GUARD_BUILD)/release/windows/* $(RELEASE_DIR)/windows/

	cd $(GATEWAY_SRC) && $(MAKE) release-win
	cp $(GATEWAY_BUILD)/release/windows/* $(RELEASE_DIR)/windows/

	# Copy Go Binaries to Installers
	cp build/release/windows/* installers/gladius-node-win-installer/

	# Create tarballs
	cd build/release/windows && tar -czf "gladius-$(VERSION)-windows-amd64.tar.gz" gladius*

release-windows-with-ui: release-windows
	cd $(UI_SRC) && npm install && npm run build && npm run package-win
	cp -r $(UI_BUILD)/release/windows/* $(RELEASE_DIR)/windows/

	# Copy Electron app to Installers
	cp -r build/release/windows/gladius-electron-win32-x64 installers/gladius-node-win-installer/gladius-electron-win32-x64