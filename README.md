# Gladius Node (Golang version)

The full suite of Gladius Binaries ([controld](https://github.com/gladiusio/gladius-control-daemon), [networkd](https://github.com/gladiusio/gladius-networkd), [cli](https://github.com/gladiusio/gladius-cli)) to run a node.

## Usage
### Install
Execute the script found in the installers folder (for unix systems)

### Run the binaries as a process
Run the executable created by the above step with `gladius-<executable-name>`

### Run networkd or controld as a service
You can also install networkd and controld as a service.
*Attention:* The service implementation is not thoroughly tested, and may require root privileges.
```shell
# install networkd as a service
gladius-networkd install

# start the networkd service
gladius-networkd start

# stop the networkd service
gladius-networkd stop
```

### CLI
TODO

### Network Daemon

#### Test the RPC server (Only Start and Stop work now)
```bash
$ HDR1='Content-type: application/json'
$ HDR2='Accept: application/json'

$ MSG='{"jsonrpc": "2.0", "method": "GladiusEdge.Start", "id": 1}'
$ curl -H $HDR1 -H $HDR2 -d $MSG http://localhost:5000/rpc
{"jsonrpc":"2.0","result":"Started server","id":1}

$ MSG='{"jsonrpc": "2.0", "method": "GladiusEdge.Stop", "id": 1}'
$ curl -H $HDR1 -H $HDR2 -d $MSG http://localhost:5000/rpc
{"jsonrpc":"2.0","result":"Stopped server","id":1}

$ MSG='{"jsonrpc": "2.0", "method": "GladiusEdge.Status", "id": 1}'
$ curl -H $HDR1 -H $HDR2 -d $MSG http://localhost:5000/rpc
{"jsonrpc":"2.0","result":"Not implemented","id":1}
```

#### Set up content delivery

Right now files are loaded from `~/.config/gladius/content/<site_name>` and take
the format of `%2froute%2fname`. This functionality only works on linux right
now, and serving is not backwards compatible with the previous release. Content
can then be accessed at `http://<host>:8080/content?website=test.com&route=%2Froute%2Fhere`

## Development
### Dependencies
To test and build the gladius binaries you need go, go-dep and gnu make on your machine.

- Install [go](https://golang.org/doc/install)
- Install [go-dep](https://golang.github.io/dep/docs/installation.html)
- *Mac Users:* Install xcode for make `xcode-select --install`
- *Windows Users:* Install [make for windows](http://gnuwin32.sourceforge.net/packages/make.htm)
- *Linux Users*: `yum install -y make` or `apt-get install -y build-essential` (depending on your distribution...) 

### Install dependencies
We use [go-dep](https://golang.github.io/dep/docs/installation.html) to manage the go dependencies.
To install the dependencies you need to execute the `dependencies` target.

```shell
# install depdencies for the project with go-dep
make dependencies
```

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

# build the control daemon (not implemented yet)
make controld
```

#### Build for a different platform
To build for a different platform specify toe GOOS and GOARCH variable.
```shell
# build for windows 64bit
GOOS=windows GOARCH=amd64 make

# build for linux 32bit
GOOS=linux GOARCH=386 make
```
