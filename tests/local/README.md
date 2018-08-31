# Local tests
Local tests are smaller scale and run fewer simulations of the network (no
latency simulation etc.) but are easier to run and give a good idea of how the network is preforming

## Running the tests
### Setup
Build the executables first with `make dependencies` and `make`. If you're
running on the development branch, you shuld run `dep ensure -update` first to
make sure you're at the most recent development branch for all services.
### Testing
run `go test` in this directory
*note* the test for state equality may not pass, this is due to heartbeat and
propagation times in the network.
