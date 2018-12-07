# Gladius Node

The full suite of Gladius binaries ([Network Gateway](https://github.com/gladiusio/gladius-network-gateway), [EdgeD](https://github.com/gladiusio/gladius-edged), [CLI](https://github.com/gladiusio/gladius-cli), and [Guardian](https://github.com/gladiusio/gladius-guardian)) to run a node.

Current Build Status
* [![Build Status](https://travis-ci.com/gladiusio/gladius-node.svg?branch=master)](https://travis-ci.com/gladiusio/gladius-node) - Node
* [![Build Status](https://travis-ci.com/gladiusio/gladius-network-gateway.svg?branch=master)](https://travis-ci.com/gladiusio/gladius-network-gateway) - Network Gateway
* [![Build Status](https://travis-ci.com/gladiusio/gladius-edged.svg?branch=master)](https://travis-ci.com/gladiusio/gladius-edged) - EdgeD
* [![Build Status](https://travis-ci.com/gladiusio/gladius-cli.svg?branch=master)](https://travis-ci.com/gladiusio/gladius-cli) - CLI

## Download and Installation

**Windows/macOS :** https://gladius.io/download
- **Windows:** Open `gladius setup.exe` and use the installer
- **macOS:** Open the DMG and drag `Gladius` to the Applications folder

**Linux :** `curl -s https://raw.githubusercontent.com/gladiusio/gladius-node/master/installers/install.sh | sudo bash`

## Use
**Windows/macOS**
1. Download and install (see above)
2. Open the application
3. Follow the instructions inside
4. You can close the application and it will run in the background

*Windows: To turn off the application completely use the task manager (Kill gladius-guardian/edged/network-gateway) this will be changed in next release.*

*macOS: To turn off the application completely use the menu bar (Right click Gladius -> Quit all)*

**Linux**
1. `sudo gladius-guardian install` (Install guardian as service)
2. `sudo gladius-guardian start` (Start it as a service. It will start up automatically on reboot)
3. `gladius start` (Instruct Guardian to start Gladius services. This needs to be done after reboot)
4. `gladius` Use the CLI!

*NOTE: You don't have to use the guardian as a service you can just call `gladius-guardian` (SKIP STEPS 1 & 2) BUT this will require another window or screen session and will not start up on reboot*

## Development
If you would like to contribute to the project:
1. `git clone`
2. `make repos` (will clone all the modules into the `./src` directory)
3. Code!
4. Make a PR in the respective repo (probably not this one)
5. Send an email to cla@gladius.io to sign our Contributor Licensing Agreement

### Go
- Using `Go 1.11.1`
- Using go modules

### Build
- `make`: builds for your architecture and places binaries in `./build`
- You can go into `./src/gladius-(repo)` and call `make` to build that repo only.
It will place the bin in `./src/gladius-(repo)/build`
