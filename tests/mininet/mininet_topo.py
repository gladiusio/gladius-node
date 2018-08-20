#!/usr/bin/python

from mininet.topo import Topo
from mininet.net import Mininet
from mininet.link import TCLink
from mininet.util import dumpNodeConnections
from mininet.log import setLogLevel
from mininet.cli import CLI
from mininet.log import info, warn, output
from time import sleep
import argparse


class SingleSwitchTopo(Topo):
    "Single switch connected to n hosts."

    def build(self, n=2, bw=100, lat=10):
        total_nodes = 0
        switch = self.addSwitch('s0')
        for h in range(n):
            host = self.addHost('h%s' % (total_nodes + 1),
                                privateDirs=['/gladius'])
            self.addLink(host, switch)
            total_nodes += 1

        query = self.addHost('qnode')
        self.addLink("s0", "qnode")


def setupNetwork(num_of_hosts=10, bandwidth=100, latency=10):
    topo = SingleSwitchTopo(n=num_of_hosts, bw=bandwidth, lat=latency)

    net = Mininet(topo=topo, link=TCLink)

    net.start()

    between_nodes = 4

    # seed node is always 10.0.0.1
    info("Setting up seed node\n")
    h1 = net.get('h1')
    h1.cmd('python /vagrant/mininet/setup_seed.py ' +
           h1.name + ' >> /tmp/' + h1.name + '_log.out 2>&1 &')
    seed_ip = h1.IP()

    sleep(20)

    info("Setting up accounts\n")
    for node_num in range(1, num_of_hosts):
        h = net.get('h%s' % (node_num + 1))
        h.cmd('python /vagrant/mininet/setup_peer.py ' +
              h.name + ' >> /tmp/' + h.name + '_log.out 2>&1 &')

    sleep(25)

    info("Starting peers\n")
    for node_num in range(1, num_of_hosts):
        info("\rStarting node: %d" % node_num)
        h = net.get('h%s' % (node_num + 1))
        h.cmd('python /vagrant/mininet/start_peer.py ' + h.name + ' ' +
              seed_ip + ' >> /tmp/' + h.name + '_log.out 2>&1 &')
        sleep(between_nodes)

    # Wait for the network to reach equalibrium
    sleep(200)

    info("\nRunning query on all nodes\n")
    query_node = net.get('qnode')
    result = query_node.cmd(
        'python /vagrant/mininet/query_all.py ' + ' '.join([host.IP() for host in net.hosts[:len(net.hosts) - 1]]))

    with open('/tmp/final_output.log', 'w') as f:
        f.write(result)

    CLI(net)
    net.stop()


if __name__ == '__main__':
    setLogLevel('info')

    ap = argparse.ArgumentParser()
    ap.add_argument("--nodes", default=10, action="store",
                    dest="nodes", type=int, help="Number of nodes")
    ap.add_argument("--bw", default=100, action="store", dest="bw",
                    type=int, help="Speed in Mbps of network links")
    ap.add_argument("--latency", default='10', action="store",
                    dest="latency", type=int, help="Latency in ms between links")

    args = ap.parse_args()

    setupNetwork(args.nodes, args.bw, args.latency)
