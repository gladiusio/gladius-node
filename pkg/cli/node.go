package node

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"strings"
	"time"

	"github.com/powerman/rpc-codec/jsonrpc2"
)

// Node - properties of a node
type Node struct {
	Type    string `json:"type"`
	Address string `json:"address"`
	Data    struct {
		Name      string `json:"name"`
		Email     string `json:"email"`
		IPAddress string `json:"ipAddress"`
		Status    string `json:"status"`
	} `json:"data"`
}

// Settings - env for the control daemon
type Settings struct {
	Provider           string `json:"provider"`
	PrivateKey         string `json:"privateKey"`
	PgpKey             string `json:"pgpKey"`
	Passphrase         string `json:"passphrase"`
	MarketAddress      string `json:"marketAddress"`
	NodeFactoryAddress string `json:"nodeFactoryAddress"`
}

// For control over HTTP client headers,
// redirect policy, and other settings,
// create an HTTP client
var client = &http.Client{
	Timeout: time.Second * 10, //10 second timeout
}

// Test ...
func Test(myNode Node) {
	test := myNode.Data
	fmt.Println((test))

	_, err := json.Marshal(test)
	if err != nil {
		fmt.Println(err)
		return
	}
}

// SetSettings settings struct
func SetSettings(network string, localSettings *Settings) {
	if strings.Compare(network, "ropsten") == 0 {
		localSettings.Provider = "https://ropsten.infura.io/tjqLYxxGIUp0NylVCiWw"
		localSettings.PrivateKey = "0xD924E8D4ABAD681BF44DEC204A45A9BEA95F973E61BF09AB22A05572C1FDC46D"
		localSettings.PgpKey = "-----BEGIN PGP PRIVATE KEY BLOCK-----\nVersion: Keybase OpenPGP v1.0.0\nComment: https://keybase.io/crypto\n\n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\nYQEQaqOUQmx2fRoAUlIIuPU=\n=zDgb\n-----END PGP PRIVATE KEY BLOCK-----\n"
		localSettings.Passphrase = "password"
		localSettings.MarketAddress = "0x9f5bd0fd43f2ee2e1ef406cec5936768ab8c587d"
		localSettings.NodeFactoryAddress = "0xb4d68308e81687698cbeb4817cc91a7ede9d8a54"
	} else { // default
		localSettings.Provider = "http://localhost:8545"
		localSettings.PrivateKey = "0x94ea84a628979ce432646082b56fa94ad04bf0dec654f40542926998fe238a03"
		localSettings.PgpKey = "-----BEGIN PGP PRIVATE KEY BLOCK-----\nVersion: Keybase OpenPGP v1.0.0\nComment: https://keybase.io/crypto\n\n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\nYQEQaqOUQmx2fRoAUlIIuPU=\n=zDgb\n-----END PGP PRIVATE KEY BLOCK-----\n"
		localSettings.Passphrase = "password"
		localSettings.MarketAddress = "0x85d52839cb69302b4a654ae4193e32f7c65827d7"
		localSettings.NodeFactoryAddress = "0xac9f90dbc228ca09074cb13fb7986175bc799cc3"
	}
}

// PostSettings - does this ...
func PostSettings(localSettings *Settings) {
	url := "http://localhost:3000/api/settings/start"

	_, err := sendRequest("POST", url, localSettings)
	if err != nil {
		log.Fatal("POST-postSettings(): ", err)
	}

	fmt.Println("Settings Posted!")
}

// GetSettings -get settings from API
func GetSettings() {
	url := "http://localhost:3000/api/settings/"

	res, err := sendRequest("GET", url, nil)
	if err != nil {
		log.Fatal("GET-getSettings(): ", err)
	}

	fmt.Println(res)
}

// CreateNode - create a Node contract
func CreateNode() (string, error) {
	url := "http://localhost:3000/api/node/create/"

	res, err := sendRequest("POST", url, nil)
	if err != nil {
		log.Fatal("POST-createNode(): ", err)
		return "", err
	}

	var data map[string]interface{}

	json.Unmarshal([]byte(res), &data)

	if data["txHash"] == nil {
		return "", errors.New("ERROR CREATING NODE")
	}

	return data["txHash"].(string), nil // tx hash
}

// GetNodeAddress - get node address from owner lookup
func GetNodeAddress() string {
	url := "http://localhost:3000/api/node"

	res, err := sendRequest("GET", url, nil)
	if err != nil {
		log.Fatal("GET-getNodeAddress(): ", err)
	}

	var data map[string]interface{}

	json.Unmarshal([]byte(res), &data)

	return data["address"].(string) // tx hash
}

// SetNodeData - set data for a Node contract
func SetNodeData(nodeAddress string, myNode Node) (string, error) {
	url := fmt.Sprintf("http://localhost:3000/api/node/%s/data", nodeAddress)

	res, err := sendRequest("POST", url, myNode.Data)
	if err != nil {
		log.Fatal("POST-setNodeData(): ", err)
	}

	var data map[string]interface{}

	json.Unmarshal([]byte(res), &data)

	if data["txHash"] == nil {
		return "", errors.New("ERROR CREATING NODE")
	}

	return data["txHash"].(string), nil // tx hash
}

// ApplyToPool - apply to a pool
func ApplyToPool(nodeAddress, poolAddress string) (string, error) {
	url := fmt.Sprintf("http://localhost:3000/api/node/%s/apply/%s", nodeAddress, poolAddress)

	res, err := sendRequest("POST", url, nil)
	if err != nil {
		log.Fatal("POST-postSettings(): ", err)
	}

	var data map[string]interface{}

	json.Unmarshal([]byte(res), &data)

	if data["txHash"] == nil {
		return "", errors.New("ERROR APPLYING TO POOL")
	}

	return data["txHash"].(string), nil // tx hash
}

// CheckPoolApplication - check the status of your pool application
func CheckPoolApplication(nodeAddress, poolAddress string) string {
	url := fmt.Sprintf("http://localhost:3000/api/node/%s/status/%s", nodeAddress, poolAddress)

	res, err := sendRequest("GET", url, nil)
	if err != nil {
		log.Fatal("GET-getPoolStatus(): ", err)
	}

	var data map[string]interface{}

	json.Unmarshal([]byte(res), &data)

	return data["status"].(string) // application status
}

// CheckTx - check status of tx hash
func CheckTx(tx string) bool {
	url := fmt.Sprintf("http://localhost:3000/api/status/tx/%s", tx)

	res, err := sendRequest("GET", url, nil)
	if err != nil {
		log.Fatal("POST-postSettings(): ", err)
	}

	in := res

	var data map[string]map[string]interface{} // wtf golang this is gross

	json.Unmarshal([]byte(in), &data)

	receipt := data["receipt"]

	if len(receipt) == 0 {
		return false // tx pending
	}

	return true // tx complete
}

// WaitForTx - wait for the tx to complete
func WaitForTx(tx string) bool {
	status := CheckTx(tx)

	for status == false {
		status = CheckTx(tx)
		fmt.Printf("Tx: %s\t Status: Pending\r", tx)
	}

	fmt.Printf("\nTx: %s\t Status: Successful\n", tx)
	return true
}

// Should add errors for the edge node functions below

// StartEdgeNode - start edge node server
func StartEdgeNode() {
	// Client use HTTP transport.
	clientHTTP := jsonrpc2.NewHTTPClient("http://localhost:5000/rpc")
	defer clientHTTP.Close()

	var reply string

	// Synchronous call using positional params and TCP.
	clientHTTP.Call("GladiusEdge.Start", nil, &reply)
	fmt.Printf("Reply %s", reply)
}

// StopEdgeNode - stop edge node server
func StopEdgeNode() {
	// Client use HTTP transport.
	clientHTTP := jsonrpc2.NewHTTPClient("http://localhost:5000/rpc")
	defer clientHTTP.Close()

	var reply string

	// Synchronous call using positional params and TCP.
	clientHTTP.Call("GladiusEdge.Stop", nil, &reply)
	fmt.Printf("Reply %s", reply)
}

// StatusEdgeNode - status of edge node server
func StatusEdgeNode() {
	// Client use HTTP transport.
	clientHTTP := jsonrpc2.NewHTTPClient("http://localhost:5000/rpc")
	defer clientHTTP.Close()

	var reply string

	// Synchronous call using positional params and TCP.
	clientHTTP.Call("GladiusEdge.Status", nil, &reply)
	fmt.Printf("Reply %s", reply)
}

// send requests
func sendRequest(requestType, url string, data interface{}) (string, error) {

	b := bytes.Buffer{}

	if data != nil {
		jsonPayload, err := json.Marshal(data)
		if err != nil {
			return "", err
		}
		b = *bytes.NewBuffer(jsonPayload)
	}

	// Build the request
	req, err := http.NewRequest(requestType, url, &b)
	if err != nil {
		return "", err
	}

	req.Header.Set("User-Agent", "gladius-cli")
	req.Header.Set("Content-Type", "application/json")

	// Send the request via a client
	res, err := client.Do(req)
	if err != nil {
		return "", err
	}

	body, readErr := ioutil.ReadAll(res.Body)
	if readErr != nil {
		return "", err
	}

	// Defer the closing of the body
	defer res.Body.Close()

	return string(body), nil //tx
}
