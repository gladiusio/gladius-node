# Gladius Node (Golang version)

The full suite of Gladius binaries ([controld](https://github.com/gladiusio/gladius-control-daemon), [networkd](https://github.com/gladiusio/gladius-networkd), [cli](https://github.com/gladiusio/gladius-cli)) to run a node.
## Install

### Linux/Mac

(latest release)

- Run this in the terminal

  `curl -s https://raw.githubusercontent.com/gladiusio/gladius-node/master/installers/install.sh | sudo bash`

- Download Profile UI (Optional)
  - [macOS](https://github.com/gladiusio/gladius-node/releases/download/0.2.0/Gladius-darwin-x64.zip)
  - [Debian (Ubuntu)](https://github.com/gladiusio/gladius-node/releases/download/0.2.0/Gladius_Manager_1.0.0_amd64.deb)


### Windows
Native installer will come soon (you can use the step above with the Linux subsystem for Windows)

## Usage

You need to run both the Gladius Control and Gladius Network daemons and then you can interact with them through the Gladius CLI


### Gladius Control Daemon
```
$ gladius-controld

Starting server at http://localhost:3001
```

### Gladius Networking Daemon
```
$ gladius-networkd

Loading config
Starting...
Started RPC server and HTTP server.
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

$ gladius edge start

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

Use gladius edge start to start the edge node software
```

**edge [start | stop]**

Start or stop the edge node software
```

$ gladius edge start
Edge Daemon:	 Started the server

Use gladius edge stop to stop the edge node software
```

```

$ gladius edge stop
Edge Daemon:	 Stopped the server

Use gladius edge start to start the edge node software
```

### Beta Node Manager
After you are done creating a Node you can check the status of it with our manager app. This displays your node information from the blockchain and is what's sent to the pool manager. You can find a link to install it in the install section.



![](https://i.imgur.com/cKl4vZ1.png)

### Run networkd or controld as a service (optional)
You can also install networkd and controld as a service.
*Attention:* **The service implementation is not thoroughly tested, and may require root privileges.**
```shell
# install networkd as a service
gladius-networkd install

# start the networkd service
gladius-networkd start

# stop the networkd service
gladius-networkd stop
```

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