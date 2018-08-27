# Gladius Node test suite

#### What are these testing?
This test suite is designed to test high level network functionality like
file sharing, state updates, controld http endpoint testing, and p2p performance. It doesn't run our unit tests or anything like that, this is really meant to create a mock network and look for issues there.

## Running the tests
#### Host setup
We use [mininet](http://mininet.org/) inside of
[vagrant](https://www.vagrantup.com/) to simulate the network, you'll need
vagrant and virtualbox installed on your host machine. For some of the more
demanding tests (with hundreds of nodes) you will likely also need a pretty beefy
machine with at least 16gb of RAM and 8 cpu cores to spare.
To give and example, our office
development machine with 32gb of RAM and an AMD threadripper 1900x works
really well.

#### Setting up the VM
Make sure you have the most recent build inside of the build directory, run
`make dependencies` and `make` to ensure that you do. Once that is done you can
run `vagrant up` inside of this directory to clone and build the test VM. This
might take a few minutes to compile.

#### Running the tests
Get inside the VM by running `vagrant ssh` from the tests directory. Once you're
inside, you can run `sudo python /vagrant/tests/mininet/mininet_topo.py`.

## Checking output
All of the standard output of the nodes is stored in the `/tmp/` directory,
so after a run you can browse through the files there. The `final_output` file
contains the output and the if the state across all nodes was consistent or not.

## Cleaning up
Run `sudo mn -c` to clean up anything left over (if something crashed etc.)
