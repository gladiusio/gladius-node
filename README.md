# Gladius Node (Golang version)

The full suite of Gladius binaries ([controld](https://github.com/gladiusio/gladius-control-daemon), [networkd](https://github.com/gladiusio/gladius-networkd), [cli](https://github.com/gladiusio/gladius-cli)) to run a node.
## Install

### macOS

- Download .dmg from releases, [gladius-0.5.0-mac.dmg](https://github.com/gladiusio/gladius-node/releases/download/0.5.0/gladius-0.5.0-mac.dmg)
- Click the menu bar Gladius icon in the top right
- In Beta options
  - Click "Add gladius to Path"
  - Click "Open Terminal" to open the Terminal to run `gladius`
- The Profile UI is included in this app
- Once done installing software please follow these usage guidelines [HERE](https://github.com/gladiusio/gladius-node#gladius-cli)


### Linux

(latest release)

- Run this in the terminal

  `curl -s https://raw.githubusercontent.com/gladiusio/gladius-node/master/installers/install.sh | sudo bash`

- Download Profile UI (Optional)
  - [Debian (Ubuntu)](https://github.com/gladiusio/gladius-node/releases/download/0.5.0/Gladius-0.5.0-Linux-GUI.zip)


### Windows
1. [Download the native windows installer!](https://github.com/gladiusio/gladius-node/releases/download/0.5.0/Gladius-0.5.0-windows-setup.exe) (includes the UI)
2. Run the installer


## Usage

**Ports that need to be forwarded**

| Port  | Service |
| ------------- | ------------- |
| 8080  | Networkd - Content server  |
| 7946  | Controld - P2P Network  |

**Important notes**

*Windows users:* `gladius-networkd` and `gladius-controld` are automatically added as system services. You should **NOT** attempt to run `gladius-networkd` and `gladius-controld` as commands because they are **already running**.

*Non-Windows users:* You need to run both the Gladius Control and Gladius Network daemons **and then** you can interact with them through the Gladius CLI


### Manually run networkd or controld as a service
You can also install networkd and controld as a system service. This should work with Windows XP+, Linux/(systemd | Upstart | SysV), and macOS/Launchd. These will then start at login.

**Important Note** The GladiusBase directory will be located under the user that
installs the service, so issues may come up if installed from a different user
than the one that is running the service.

```shell
# install networkd or controld as a service
gladius-<networkd|controld> install

# start the networkd or controld service
gladius-<networkd|controld> start

# stop the networkd or controld service
gladius-<networkd|controld> stop
```

### Run networkd or controld as a non service

One good way to do this would be to use something like [screen](https://www.gnu.org/software/screen/manual/screen.html) to run in the
background

#### Gladius Control Daemon
```
$ gladius-controld

Starting server at http://localhost:3001
```

#### Gladius Networking Daemon
```
$ gladius-networkd

Loading config
Starting...
```

### Gladius CLI

Use `--help` on the base command to see the help menu. Use `--help` any other command for a description of that command

#### Full list of commands (in order of usage)

**base**
```
$ gladius

Welcome to the Gladius CLI!

Here are the commands to create a node and apply to a pool in order:

$ gladius create
$ gladius apply
$ gladius check

After you are accepted into a pool, you can become an edge node:

$ gladius node start

Use the -h flag to see the help menu
```

**create**

Deploys a new Gladius Node smart contract containing the encrypted version of the data you submitted. If you enter in the wrong information you can just run the command again to make a new node.
```
$ gladius create

[Gladius] What is your name? Marcelo Test
[Gladius] What is your email? email@test.com
[Gladius] Please type your password:  ********

Tx: 0xb37a017d2877ab7350e0c7199326bc97bda32e4d8ae46c6aaecc2f9b0cd3b133	 Status: Pending...
Tx: 0xb37a017d2877ab7350e0c7199326bc97bda32e4d8ae46c6aaecc2f9b0cd3b133	 Status: Successful
Node created!

Tx: 0x6931f0394684ebef6c0fa9c83ccf1ae7fa2811b93b4480fcf0ba163e8eb03ff6	 Status: Pending...
Tx: 0x6931f0394684ebef6c0fa9c83ccf1ae7fa2811b93b4480fcf0ba163e8eb03ff6	 Status: Successful
Node data set!

Node Address: 0xb04578990b1cbb515b8764ca8778e5ba7f6eb8e5

Use gladius apply to apply to a pool
```

**apply**

Submits the data to a specific pool, allowing them to accept or reject you to become a part of the pool
```
$ gladius apply

[Gladius] Pool Address:  0xC88a29cf8F0Baf07fc822DEaA24b383Fc30f27e4
[Gladius] Please type your password:  ********

Tx: 0x14e796ce7939c035586ff2b6f26e1ad9db71be7a760715debbad68b4cb9d9496	 Status: Pending
Tx: 0x14e796ce7939c035586ff2b6f26e1ad9db71be7a760715debbad68b4cb9d9496	 Status: Successful

Application sent to pool!
Use gladius check to check your application status
```

**check**

Check your application status to a specific pool
```
$ gladius check

[Gladius] Pool Address:  0xC88a29cf8F0Baf07fc822DEaA24b383Fc30f27e4
Pool: 0xC88a29cf8F0Baf07fc822DEaA24b383Fc30f27e4	 Status: Pending

Use gladius node start to start the node networking software
```

**node [start | stop | status]**

Start/stop or check the status of the node networking software
```
$ gladius node start
Network Daemon:	 Started the server

Use gladius node stop to stop the node networking software
Use gladius node status to check the status of the node networking software
```

```
$ gladius node stop
Network Daemon:	 Stopped the server

Use gladius node start to start the node networking software
Use gladius node status to check the status of the node networking software
```

```
$ gladius node status
Network Daemon:	 Server is Running

Use gladius node start to start the node networking software
Use gladius node stop to stop the node networking software
```
**profile**

See information regarding your node
```
$ gladius profile

Account Address: 0x8C3650F01aA308e0B56F12530378748190c6b454
Node Address: 0xf15aea30341982b117583f36cf516f6cea5ddf91
Node Name: Marcelo
Node Email: marcelo@test.com
Node IP: 12.12.123.12
```

### Beta Node Manager
After you are done creating a Node you can check the status of it with our manager app. This displays your node information from the blockchain and is what's sent to the pool manager. You can find a link to install it in the install section.



![](https://i.imgur.com/cKl4vZ1.png)

---

## Development
If you want to contribute to the project, please clone, modify, and make a pull request to the respective [controld](https://github.com/gladiusio/gladius-control-daemon), [networkd](https://github.com/gladiusio/gladius-networkd), [cli](https://github.com/gladiusio/gladius-cli) repositories
### Dependencies
To test and build the gladius binaries you need go, go-dep and the make on your machine.

- Install [go](https://golang.org/doc/install)
- Install [go-dep](https://golang.github.io/dep/docs/installation.html)
- *Mac Users:* Install xcode for make `xcode-select --install`
- *Windows Users:* Install [Linux Subsystem](https://docs.microsoft.com/en-us/windows/wsl/install-win10)

### Install dependencies
We use [go-dep](https://golang.github.io/dep/docs/installation.html) to manage the go dependencies.
To install the dependencies you need to execute the `dependencies` target.

```shell
# install depdencies for the project with go-dep
make dependencies
```
This will also configure the Ethereum bindings to work with go-dep.

### Build
To build all binaries for your current os and architecture simply execute `make`.
After the build process you will find all binaries in *./build/*.

#### Build specific binary
The Makefile can build single binaries too.
```shell
# build only the cli
make cli

# build the network daemon
make networkd

# build the control daemon
make controld
```

#### Build for a different platform
*Attention: There will be issues cross compiling the controld for other systems due to the go-ethereum CGO bindings, you can try using [xgo](https://github.com/karalabe/xgo) to work around the issues though*
To build for a different platform specify toe GOOS and GOARCH variable.
```shell
# build for windows 64bit
GOOS=windows GOARCH=amd64 make

# build for linux 32bit
GOOS=linux GOARCH=386 make
```

---

## Docker
You can use the provided Dockerfile and docker-compose file to run the gladius networkd and controld as docker containers on your machine. The setup is tested on docker for mac and linux boxes, not yet on arm machines.

### Clone this repository!
```bash

git clone https://github.com/gladiusio/gladius-node.git

cd gladius-node

```

### Mac Vs. Linux Docker

In macOS, most if not all packages are installed, particularly the newest version of docker_compose

Linux requires some setup to get working, especially out of the box.

#### Prepping Linux

##### Install Docker, remove old Docker

```bash
# "If you are used to installing Docker to your development machine with get-docker script, that won't work either. So the solution is to install Docker CE from the zesty package."
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu zesty stable"

sudo apt-get update
sudo apt-get install docker-ce

```
##### Install Docker-Compose
```bash
#Install Docker-compose to run docker_compose commands. Docker compose is not necessary if you don't want to have docker-compose perform the automated actions of starting networkd and controld in separate containers on the same docker network.

sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

$ docker-compose --version
docker-compose version 1.21.2, build 1719ceb
```


#### Instructions from Docker's official documentation do not currently support 18.04
https://docs.docker.com/install/linux/docker-ce/ubuntu/#docker-ee-customers


##### Install Docker compose. version 1.21 or newer required

https://docs.docker.com/compose/install/


### Build and publish an image
You can build and publish a docker gladius image to a registry with the two make targets
```bash
# create a docker image gladiusio/gladius-node with the latest binary (from the most current release tag in git)
sudo make docker_image
# - or create a docker image with a specific release tag and image name
sudo make docker_image DOCKER_RELEASE=0.3.0 DOCKER_IMAGE=gladiusio/gladius-node

# push the image to the docker registry
sudo make docker_push
# or push a specific image
sudo make docker_push DOCKER_IMAGE=gladiusio/gladius-node
```

### Use docker-compose to run gladius-controld and networkd
You can also use the provided docker compose file to build the images and run them locally
```bash
# run docker compose with the latest release
sudo make docker_compose DOCKER_ARCH=amd64

# run docker compose with a specific gladius release
sudo make docker_compose DOCKER_RELEASE=0.3.0 DOCKER_ARCH=amd64
```
### Use docker to run the gladius cli
The image also provides the gladius cli.
```bash
# build the docker image gladiusio/gladius-node with release 0.3.0
make docker_image DOCKER_RELEASE=0.3.0 DOCKER_IMAGE=gladiusio/gladius-node
# use the image to run the cli
docker run --rm --network host -ti gladiusio/gladius-node:0.3.0 gladius --help

or

docker run --rm --network host -ti gladiusio/gladius-node:0.3.0 gladius create

etc...

```

### Cleanup
To remove the created docker containers, volumes and network you can execute the docker_compose_cleanup target
```bash
make docker_compose_cleanup
```

### Persistent Volumes
The docker images exposes three volumes ${GLADIUSBASE}/content, ${GLADIUSBASE}/wallet and ${GLADIUSBASE}/keys.

If you want to keep your configuration even when you recreate the containers from the image you need to have persistent volumes defined for the volumes.

The docker compose file already does that so if a newer images version is used with the docker compose file the wallet, keys and content data will remain.
