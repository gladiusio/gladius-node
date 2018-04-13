# Gladius Node (Golang version)

The full suite of binaries for running a Gladius Node

### Build yourself
Install [go](https://golang.org/doc/install)

Build executables for all platforms with `./build-all` and move the appropriate
executables to your preferred install path, and add them to your PATH. An
install folder structure could look like this
```
your/install/path/gladius/
│   gladius-cli
│   gladius-networkd
│   gladius-control-daemon (not yet included in this repo)
```

##### Some untested stuff with services
Setup the networking daemon (or control-daemon when implemented) service on your
 machine with:
`gladius-networkd install`
Start with: `gladius-networkd start`
Stop with: `gladius-networkd stop`


### Run
Run the executable created by the above step with `gladius-<executable-name>`
(Or use the steps above and make it a service)

## CLI
TODO

## Network Daemon

### Test the RPC server (Only Start and Stop work now)
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

### Set up content delivery

Right now files are loaded from `~/.config/gladius/gladius-networkd/` and take
the format of `example.com.json`. This functionality only works on linux right
now, and serving is not backwards compatible with the previous release.
