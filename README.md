# Gladius Node

The full suite of Gladius binaries ([Network Gateway](https://github.com/gladiusio/gladius-network-gateway), [EdgeD](https://github.com/gladiusio/gladius-edged), [CLI](https://github.com/gladiusio/gladius-cli), and [Guardian](https://github.com/gladiusio/gladius-guardian)) to run a node.

Current Build Status
* [![Build Status](https://travis-ci.com/gladiusio/gladius-node.svg?branch=master)](https://travis-ci.com/gladiusio/gladius-node) - Node
* [![Build Status](https://travis-ci.com/gladiusio/gladius-network-gateway.svg?branch=master)](https://travis-ci.com/gladiusio/gladius-network-gateway) - Network Gateway
* [![Build Status](https://travis-ci.com/gladiusio/gladius-edged.svg?branch=master)](https://travis-ci.com/gladiusio/gladius-edged) - EdgeD
* [![Build Status](https://travis-ci.com/gladiusio/gladius-cli.svg?branch=master)](https://travis-ci.com/gladiusio/gladius-cli) - CLI

## Install

**Windows and macOS :** https://gladius.io/download
- **Windows:** Open `gladius setup.exe` and use the installer
- **macOS:** Open the DMG and drag `Gladius` to the Applications folder

**Linux :** `curl -s https://raw.githubusercontent.com/gladiusio/gladius-node/master/installers/install.sh | sudo bash`

## Use
**Windows and macOS**
1. Download and install (see above)
2. Open the `Gladius` application
3. Follow the instructions in the user interface
4. You can close the application and it will run in the background

*Windows: To turn off the application completely use the task manager (Kill gladius-guardian/edged/network-gateway) this will be changed in next release.*

*macOS: To turn off the application completely use the menu bar (Right click Gladius -> Quit all)*

**Linux**
1. `sudo gladius-guardian install` (Install guardian as service)
2. `sudo gladius-guardian start` (Start it as a service with `systemd`. It will start up automatically on reboot)
3. `gladius start` (Instruct Guardian to start Gladius services. This needs to be done after reboot)
4. `gladius` Use the CLI!

*NOTE: All install does is create a systemd service for the guardian, if you don't want to do that you can run it in a seperate window by calling `gladius-guardian`*

## Development and Contributions
If you would like to contribute to the project:
1. Fork the repository you would like to edit (likely [Network Gateway](https://github.com/gladiusio/gladius-network-gateway), [EdgeD](https://github.com/gladiusio/gladius-edged), [CLI](https://github.com/gladiusio/gladius-cli), or [Guardian](https://github.com/gladiusio/gladius-guardian))
2. Make your changes
3. Make a pull request
4. Send an email to cla@gladius.io to sign our Contributor Licensing Agreement

### Building the Gladius Node from source
Our builds are done inside containers to allow easier cross platform CGO development, so you will need [docker](https://docs.docker.com/install/) to build the binaries.

To change the git version (or git URL) that is checked out, modify the `.env` file. If you modify the directories or the URLs, you will want to run `make docker-image` to update the image.

- First run `make docker-image` or `docker pull gladiusio/node-env`
- To build (run with `-j 4` to run these jobs in parallel)
    - `make` to build binaries for all supported operating systems
    - `make binaries-<os>` to build for a specific OS
    
- To release
    - `make release-binaries` to build all release tarballs

All output will be placed in your local `./build`
