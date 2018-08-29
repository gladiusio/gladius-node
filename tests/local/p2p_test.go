package main

import (
	"bytes"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"sync"
	"testing"
	"time"
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
	time.Sleep(10 * time.Second)
	// This is where we would run some tests

	tester.stopDaemons()
	tester.deleteGladiusBases()

	time.Sleep(10 * time.Second)

}

type p2pTester struct {
	mux              *sync.Mutex
	numOfNodes       int           // How many nodes to start
	t                *testing.T    // So we can run tests
	contentPorts     []int         // The range of networkd ports
	controlPorts     []int         // The range of controld ports
	p2pPorts         []int         // P2P port range
	contentProcesses []*os.Process // Networkd PIDs (so we can kill them)
	controlProcesses []*os.Process // Cotnrold PIDs (so we can kill them)
}

// Take in a testing object and a number of nodes and create a tester
func newP2PTester(numOfNodes int, t *testing.T) *p2pTester {
	if numOfNodes < 2 {
		t.Error("Need at least 2 nodes to run test!")
	}

	// Create a tester to return
	tester := &p2pTester{
		t:                t,
		mux:              &sync.Mutex{},
		numOfNodes:       numOfNodes,
		contentProcesses: make([]*os.Process, numOfNodes),
		controlProcesses: make([]*os.Process, numOfNodes),
		contentPorts:     make([]int, numOfNodes),
		p2pPorts:         make([]int, numOfNodes),
		controlPorts:     make([]int, numOfNodes),
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
		err := os.MkdirAll("./bases/g"+strconv.Itoa(i)+"/content", os.ModePerm)
		if err != nil {
			pt.t.Error(err)
		}
	}
}

// Clean the whole "./bases directory"
func (pt *p2pTester) deleteGladiusBases() {
	for i := 0; i < pt.numOfNodes; i++ {
		err := os.RemoveAll("./bases/g" + strconv.Itoa(i))
		if err != nil {
			pt.t.Error(err)
		}
	}
}

func (pt *p2pTester) createNetword(n int) {
	// Setup controld
	networkd := exec.Command("../../build/gladius-networkd")
	pt.mux.Lock()
	controldEnv := []string{
		"GLADIUSBASE=" + createBaseDir(n),
		"CONTENTD_DISABLEIPDISCOVERY=true",
		"CONTENTD_DISABLEHEARTBEAT=true",
		"CONTENTD_CONTENTPORT=" + strconv.Itoa(pt.contentPorts[n]),
		"CONTENTD_P2PSEEDNODEADDRESS=localhost:7946",
		"CONTENTD_LOGLEVEL=debug",
		"CONTENTD_CONTROLDPORT=" + strconv.Itoa(pt.controlPorts[n]),
	}
	pt.mux.Unlock()
	networkd.Env = controldEnv
	go func(nd *exec.Cmd) {
		stdoutStderr, err := nd.CombinedOutput()
		if err != nil {
			log.Fatal(err)
		}
		fmt.Printf("%s\n", stdoutStderr)
	}(networkd)
	time.Sleep(500 * time.Millisecond)
	networkd.Start()
	time.Sleep(1 * time.Second)

	pt.mux.Lock()
	// Add each one of these to the list of conrolds that we started
	pt.contentProcesses[n] = networkd.Process
	pt.mux.Unlock()
}

func (pt *p2pTester) createControld(n int) {
	// Setup controld
	controld := exec.Command("../../build/gladius-controld")
	controldEnv := []string{
		fmt.Sprintf("GLADIUSBASE=./bases/g%d", n),
		"CONTROLD_P2P_BINDPORT=" + strconv.Itoa(pt.p2pPorts[n]),
		"CONTROLD_NODEMANAGER_CONFIG_PORT=" + strconv.Itoa(pt.controlPorts[n]),
	}
	controld.Env = controldEnv

	err := controld.Start()
	if err != nil {
		pt.t.Error("Oh boy the test didn't go so well, we couldn't start one of the test controlds", err)
	}

	time.Sleep(1 * time.Second)

	_, err = postToControld("/api/keystore/account/create", strconv.Itoa(pt.controlPorts[n]), `{"passphrase":"password"}`)
	if err != nil {
		pt.t.Error("Error creating account", err)
	}

	_, err = postToControld("/api/keystore/account/open", strconv.Itoa(pt.controlPorts[n]), `{"passphrase":"password"}`)
	if err != nil {
		pt.t.Error("Error unlocking account", err)
	}

	_, err = postToControld("/api/keystore/account/open", strconv.Itoa(pt.controlPorts[n]), `{"passphrase":"password"}`)
	if err != nil {
		pt.t.Error("Error unlocking account", err)
	}

	pt.mux.Lock()
	// Add each one of these to the list of conrolds that we started
	pt.controlProcesses[n] = controld.Process
	pt.mux.Unlock()
}

// Start the daemons
func (pt *p2pTester) startDaemons() {
	for i := 0; i < pt.numOfNodes; i++ {
		go func(n int) {
			pt.createControld(n)
			time.Sleep(2 * time.Second)
			pt.createNetword(n)
			// Start networkds

		}(i)
	}
}

// Stop the daemons
func (pt *p2pTester) stopDaemons() {
	for _, p := range pt.controlProcesses {
		err := p.Signal(os.Interrupt)
		if err != nil {
			pt.t.Log("Oh boy the test didn't go so well, we couldn't kill one of the test controlds", err)
			pt.t.Fail()
		}
	}
	for _, p := range pt.contentProcesses {
		err := p.Signal(os.Interrupt)
		if err != nil {
			pt.t.Log("Oh boy the test didn't go so well, we couldn't kill one of the test networkds", err)
			pt.t.Fail()
		}
	}
}

func postToControld(endpoint, port, message string) (*http.Response, error) {
	byteMessage := []byte(message)
	return http.Post("http://localhost:"+port+endpoint, "application/json", bytes.NewBuffer(byteMessage))
}

func createBaseDir(n int) string {
	dir := fmt.Sprintf("./bases/g%d", n)
	abs, _ := filepath.Abs(dir)
	return abs
}
