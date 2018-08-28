package main

import (
	"fmt"
	"os"
	"os/exec"
	"strconv"
	"testing"
)

const (
	numToTest        = 10
	controlStartPort = 3001
	contentStartPort = 8080
	p2pStartPort     = 7946
)

func TestP2P(t *testing.T) {
	tester := newP2PTester(numToTest, t)

	tester.createGladiusBases()
	tester.startDaemons()

	tester.stopDaemons()
	tester.deleteGladiusBases()
}

type p2pTester struct {
	numOfNodes   int        // How many nodes to start
	t            *testing.T // So we can run tests
	contentPorts []int      // The range of networkd ports
	controlPorts []int      // The range of controld ports
	p2pPorts     []int      // P2P port range
	contentPIDs  []int      // Networkd PIDs (so we can kill them)
	controlPIDs  []int      // Cotnrold PIDs (so we can kill them)
}

// Take in a testing object and a number of nodes and create a tester
func newP2PTester(numOfNodes int, t *testing.T) *p2pTester {
	if numOfNodes < 2 {
		t.Error("Need at least 2 nodes to run test!")
	}

	// Create a tester to return
	tester := &p2pTester{
		t:            t,
		numOfNodes:   numOfNodes,
		contentPIDs:  make([]int, numOfNodes),
		controlPIDs:  make([]int, numOfNodes),
		contentPorts: make([]int, numOfNodes),
		p2pPorts:     make([]int, numOfNodes),
		controlPorts: make([]int, numOfNodes),
	}

	// Setup our ports
	for i := 0; i < numOfNodes; i++ {
		tester.contentPorts[i] = contentStartPort + i
		tester.controlPorts[i] = controlStartPort + i
		tester.p2pPorts[i] = p2pStartPort + i
	}

	return tester
}

// Create enough base direcories for all of the nodes in the network
func (pt *p2pTester) createGladiusBases() {
	for i := 0; i < pt.numOfNodes; i++ {
		err := os.MkdirAll("./bases/g"+strconv.Itoa(i), os.ModePerm)
		if err != nil {
			pt.t.Error(err)
		}
	}
}

// Clean the whole "./bases directory"
func (pt *p2pTester) deleteGladiusBases() {
	for i := 0; i < pt.numOfNodes; i++ {
		err := os.Remove("./bases/g" + strconv.Itoa(i))
		if err != nil {
			pt.t.Error(err)
		}
	}
}

// Start the daemons
func (pt *p2pTester) startDaemons() {

	for i := 0; i < 10; i++ {
		// Setup controld
		go func(n int) {
			controld := exec.Command("/bin/sh", "-c", "../../build/gladius-controld")
			controldEnv := []string{
				fmt.Sprintf("GLADIUSBASE=\"./bases/g%d\"", n),
				"CONTROLD_P2P_BINDPORT=" + strconv.Itoa(pt.p2pPorts[n]),
				"CONTROLD_NODEMANAGER_CONFIG_PORT=" + strconv.Itoa(pt.controlPorts[n]),
			}
			controld.Env = controldEnv
			pt.t.Errorf(controld.Start().Error())

			// err := controld.Start()
			// if err != nil {
			// 	pt.t.Error("Can't start daemons", err)
			// }
			// fmt.Println(controld.Process.Pid)
		}(i)
	}
}

// Stop the daemons
func (pt *p2pTester) stopDaemons() {
	for i := 0; i < pt.numOfNodes; i++ {
	}
}
