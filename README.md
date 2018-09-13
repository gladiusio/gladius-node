# Gladius Node

The full suite of Gladius binaries ([controld](https://github.com/gladiusio/gladius-control-daemon), [networkd](https://github.com/gladiusio/gladius-networkd), [cli](https://github.com/gladiusio/gladius-cli)) to run a node.

## Documentation
Check out our full documentation [here](https://gladius-node.readthedocs.io/en/latest/)

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
