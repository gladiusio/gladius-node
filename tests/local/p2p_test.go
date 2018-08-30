package main

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/tdewolff/minify"
	mjson "github.com/tdewolff/minify/json"
)

const (
	numToTest        = 10
	controlStartPort = 3001
	contentStartPort = 8080
	p2pStartPort     = 7946
	logFile          = "./test_output.log"
)

var tester *p2pTester

func TestStateEquality(t *testing.T) {
	stateArray, err := tester.getStateOfEachNode()
	if err != nil {
		t.Error(err)
	}

	stateMap := make(map[string]bool)
	for i, state := range stateArray {
		if len(state) > 0 {
			s := string(state)
			m := minify.New()
			m.AddFuncRegexp(regexp.MustCompile("[/+]json$"), mjson.Minify)
			stateMin, err := m.String("text/json", s)
			if err != nil {
				panic(err)
			}
			fmt.Println("----------------------------------")
			fmt.Println(stateMin)
			stateMap[stateMin] = true
		} else {
			t.Errorf("Node %d had a 0 length state", i)
		}
	}

	if len(stateMap) > 0 {
		t.Errorf("There were %d different final states.", len(stateMap))
	}
}

func TestNodeHasFullInformation(t *testing.T) {

}

func TestContentFilesCopied(t *testing.T) {

}

func TestCorrectNumberOfNodes(t *testing.T) {

}

func TestMain(m *testing.M) {
	// Setup
	tester = newP2PTester(numToTest)
	tester.createGladiusBases()
	tester.startDaemonsAndWait()

	// Run the tests
	retCode := m.Run()

	time.Sleep(10 * time.Second)
	// Teardown
	tester.stopDaemons()
	tester.deleteGladiusBases()
	tester.writeLog(logFile)

	// Exit with the test status
	os.Exit(retCode)
}

type p2pTester struct {
	mux          *sync.Mutex
	numOfNodes   int           // How many nodes to start
	contentPorts []int         // The range of networkd ports
	controlPorts []int         // The range of controld ports
	p2pPorts     []int         // P2P port range
	processes    []*os.Process // List of all spawned processes so we can cleanup
	log          []string
}

// Take in a testing object and a number of nodes and create a tester
func newP2PTester(numOfNodes int) *p2pTester {
	if numOfNodes < 2 {
		log.Fatal("Need at least 2 nodes to run test!")
	}

	// Create a tester to return
	tester := &p2pTester{
		mux:          &sync.Mutex{},
		numOfNodes:   numOfNodes,
		processes:    make([]*os.Process, 0),
		contentPorts: make([]int, numOfNodes),
		p2pPorts:     make([]int, numOfNodes),
		controlPorts: make([]int, numOfNodes),
		log:          make([]string, 0),
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
			log.Fatal(err)
		}
	}
}

// Clean the whole "./bases directory"
func (pt *p2pTester) deleteGladiusBases() {
	for i := 0; i < pt.numOfNodes; i++ {
		err := os.RemoveAll("./bases/g" + strconv.Itoa(i))
		if err != nil {
			log.Fatal(err)
		}
	}
}

func (pt *p2pTester) spawnProcess(location string, env []string) {
	p := exec.Command(location)
	p.Env = env

	// Start the process and keep track of the output by logging to a file
	go func(proc *exec.Cmd) {
		stdoutStderr, err := proc.CombinedOutput()
		if err != nil {
			log.Fatal("Couldn't spawn process " + err.Error())
		}
		pt.mux.Lock()
		pt.log = append(pt.log, string(stdoutStderr))
		pt.mux.Unlock()
	}(p)

	// Wait for the process to start
	time.Sleep(1 * time.Second)

	pt.mux.Lock()
	// Add to the list of processes that we started
	pt.processes = append(pt.processes, p.Process)
	pt.mux.Unlock()
}

func (pt *p2pTester) createSeedNetworkd() {
	pt.mux.Lock()
	seedEnv := []string{
		"GLADIUSBASE=" + createBaseDir(0),
		"CONTENTD_OVERRIDEIP=localhost",
		"CONTENTD_DISABLEHEARTBEAT=true",
		"CONTENTD_DISABLEAUTOJOIN=true",
		"CONTENTD_CONTENTPORT=" + strconv.Itoa(pt.contentPorts[0]),
		"CONTENTD_LOGLEVEL=debug",
		"CONTENTD_CONTROLDPORT=" + strconv.Itoa(pt.controlPorts[0]),
	}
	pt.mux.Unlock()

	pt.spawnProcess("../../build/gladius-networkd", seedEnv)
}

func (pt *p2pTester) createNetworkd(n int) {
	pt.mux.Lock()
	networkEnv := []string{
		"GLADIUSBASE=" + createBaseDir(n),
		"CONTENTD_OVERRIDEIP=localhost",
		"CONTENTD_DISABLEHEARTBEAT=true",
		"CONTENTD_CONTENTPORT=" + strconv.Itoa(pt.contentPorts[n]),
		"CONTENTD_P2PSEEDNODEADDRESS=localhost:7946",
		"CONTENTD_LOGLEVEL=debug",
		"CONTENTD_CONTROLDPORT=" + strconv.Itoa(pt.controlPorts[n]),
	}
	pt.mux.Unlock()

	pt.spawnProcess("../../build/gladius-networkd", networkEnv)
}

func (pt *p2pTester) createControld(n int) {
	controldEnv := []string{
		fmt.Sprintf("GLADIUSBASE=./bases/g%d", n),
		"CONTROLD_P2P_BINDPORT=" + strconv.Itoa(pt.p2pPorts[n]),
		"CONTROLD_P2P_ADVERTISEPORT=" + strconv.Itoa(pt.p2pPorts[n]),
		"CONTROLD_NODEMANAGER_CONFIG_PORT=" + strconv.Itoa(pt.controlPorts[n]),
	}

	pt.spawnProcess("../../build/gladius-controld", controldEnv)

	_, err := postToControld("/api/keystore/account/create", strconv.Itoa(pt.controlPorts[n]), `{"passphrase":"password"}`)
	if err != nil {
		log.Fatal("Error creating account", err)
	}

	_, err = postToControld("/api/keystore/account/open", strconv.Itoa(pt.controlPorts[n]), `{"passphrase":"password"}`)
	if err != nil {
		log.Fatal("Error unlocking account", err)
	}
}

// Start the daemons
func (pt *p2pTester) startDaemonsAndWait() {
	pt.createControld(0)
	time.Sleep(2 * time.Second)
	pt.createSeedNetworkd()
	for i := 1; i < pt.numOfNodes; i++ {
		time.Sleep(3 * time.Second) // Sleep to give it a break
		go func(n int) {
			pt.createControld(n)
			time.Sleep(2 * time.Second)
			pt.createNetworkd(n)
		}(i)
	}

	time.Sleep(60 * time.Second)
}

// Stop the daemons
func (pt *p2pTester) stopDaemons() {
	for _, p := range pt.processes {
		err := p.Signal(os.Interrupt)
		if err != nil {
			log.Fatal("Oh boy the test didn't go so well, we couldn't kill one of the processes.", err)
		}
	}
}

func (pt *p2pTester) writeLog(logFile string) {
	f, err := os.Create(logFile)
	if err != nil {
		log.Fatal(err)
	}
	_, err = f.Write([]byte(strings.Join(pt.log, "\n")))
	if err != nil {
		log.Fatal(err)
	}
}

func (pt *p2pTester) getStateOfEachNode() ([]string, error) {
	toReturn := make([]string, pt.numOfNodes)
	for i := 0; i < pt.numOfNodes; i++ {
		resp, err := getFromControld("/api/p2p/state", strconv.Itoa(pt.controlPorts[i]))
		if err != nil {
			return []string{}, err
		}
		bodyBytes, err := ioutil.ReadAll(resp.Body)
		if err != nil {
			return []string{}, err
		}
		toReturn[i] = string(bodyBytes)
	}

	return toReturn, nil
}

func postToControld(endpoint, port, message string) (*http.Response, error) {
	byteMessage := []byte(message)
	return http.Post("http://localhost:"+port+endpoint, "application/json", bytes.NewBuffer(byteMessage))
}

func getFromControld(endpoint, port string) (*http.Response, error) {
	return http.Get("http://localhost:" + port + endpoint)
}

func createBaseDir(n int) string {
	dir := fmt.Sprintf("./bases/g%d", n)
	abs, _ := filepath.Abs(dir)
	return abs
}
