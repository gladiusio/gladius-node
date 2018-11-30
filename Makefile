#!make
include .env

# general make targets
all: build-all

# clone repositories
repos:
	# sources
	git clone git@github.com:gladiusio/gladius-guardian.git src/gladius-guardian
	git clone git@github.com:gladiusio/gladius-network-gateway.git src/gladius-network-gateway
	git clone git@github.com:gladiusio/gladius-edged.git src/gladius-edged
	git clone git@github.com:gladiusio/gladius-cli.git src/gladius-cli
	git clone git@github.com:gladiusio/gladius-node-ui.git src/gladius-node-ui

	# installers
	git clone git@github.com:gladiusio/gladius-node-installer-macos.git installers/gladius-node-mac-installer
	git clone git@github.com:gladiusio/gladius-node-installer-windows.git installers/gladius-node-win-installer

# define cleanup target for windows and *nix
ifeq ($(OS),Windows_NT)
clean:
	del /Q /F .\\build\\*
else
clean:
	rm -rf ./build/*
endif

ifeq ($(OS),Windows_NT)
clean-repos:
	del /Q /F .\\installers\\gladius-node-*\\*
	del /Q /F .\\src\\*
	make repos
else
clean-repos:
	rm -rf installers/gladius-node-*
	rm -rf ./src/*
	make repos
endif

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