package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"strings"
	"time"
)

type node struct {
	Type    string `json:"type"`
	Address string `json:"address"`
	Data    struct {
		Name      string `json:"name"`
		Email     string `json:"email"`
		IPAddress string `json:"ipAddress"`
		Status    string `json:"status"`
	} `json:"data"`
}

type settings struct {
	Provider           string `json:"provider"`
	PrivateKey         string `json:"privateKey"`
	PgpKey             string `json:"pgpKey"`
	Passphrase         string `json:"passphrase"`
	MarketAddress      string `json:"marketAddress"`
	NodeFactoryAddress string `json:"nodeFactoryAddress"`
}

// For control over HTTP client headers,
// redirect policy, and other settings,
// create a Client
// A Client is an HTTP client
var client = &http.Client{
	Timeout: time.Second * 10, //10 second timeout
}

var localSettings = settings{}
var myNode = node{}

func main() {

	myNode.Data.Name = "celo-test-1"
	myNode.Data.Email = "celo@gladius.io"
	myNode.Data.IPAddress = "1.1.1.1"
	myNode.Data.Status = "active"

	// setSettings("ropsten")
	// postSettings()
	// test()
	// getSettings()
	// createNode()
	// setNodeData("0xE41aD0A56d340E258A367dF6fAD7813134757842")
}

func test() {
	// test := myNode.Data
	//
	// jsonPayload, err := json.Marshal(test)
	// if err != nil {
	// 	fmt.Println(err)
	// 	return
	// }
	// fmt.Println(string(jsonPayload))
}

// initialize settings struct
func setSettings(network string) {
	if strings.Compare(network, "ropsten") == 0 {
		localSettings.Provider = "https://ropsten.infura.io/tjqLYxxGIUp0NylVCiWw"
		localSettings.PrivateKey = "0xD924E8D4ABAD681BF44DEC204A45A9BEA95F973E61BF09AB22A05572C1FDC46D"
		localSettings.PgpKey = "-----BEGIN PGP PRIVATE KEY BLOCK-----\nVersion: Keybase OpenPGP v1.0.0\nComment: https://keybase.io/crypto\n\n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\nYQEQaqOUQmx2fRoAUlIIuPU=\n=zDgb\n-----END PGP PRIVATE KEY BLOCK-----\n"
		localSettings.Passphrase = "password"
		localSettings.MarketAddress = "0xc4dfb5c9e861eeae844795cfb8d30b77b78bbc38"
		localSettings.NodeFactoryAddress = "0xDB0ce2B1A59a443771eD7F02Bd2C51da734EDF0C"
	} else { // default
		localSettings.Provider = "http://localhost:8545"
		localSettings.PrivateKey = "0xD924E8D4ABAD681BF44DEC204A45A9BEA95F973E61BF09AB22A05572C1FDC46D"
		localSettings.PgpKey = "-----BEGIN PGP PRIVATE KEY BLOCK-----\nVersion: Keybase OpenPGP v1.0.0\nComment: https://keybase.io/crypto\n\n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\nYQEQaqOUQmx2fRoAUlIIuPU=\n=zDgb\n-----END PGP PRIVATE KEY BLOCK-----\n"
		localSettings.Passphrase = "password"
		localSettings.MarketAddress = "0xc4dfb5c9e861eeae844795cfb8d30b77b78bbc38"
		localSettings.NodeFactoryAddress = "0xDB0ce2B1A59a443771eD7F02Bd2C51da734EDF0C"
	}
	fmt.Println("Settings Set!")
}

// POST settings to API
func postSettings() {
	url := "http://localhost:3000/api/settings/start"

	jsonPayload, err := json.Marshal(localSettings)
	if err != nil {
		fmt.Println(err)
		return
	}

	// Build the request
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonPayload))
	if err != nil {
		log.Fatal("NewRequest: ", err)
	}

	req.Header.Set("User-Agent", "gladius-cli")
	req.Header.Set("Content-Type", "application/json")

	// Send the request via a client
	res, err := client.Do(req)
	if err != nil {
		log.Fatal("Do: ", err)
	}

	_, readErr := ioutil.ReadAll(res.Body)
	if readErr != nil {
		log.Fatal(readErr)
	}
	// Defer the closing of the body
	defer res.Body.Close()

	fmt.Println("Settings Posted!")
}

// GET settings from API
func getSettings() {
	url := "http://localhost:3000/api/settings/"

	// Build the request
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		log.Fatal("NewRequest: ", err)
	}

	req.Header.Set("User-Agent", "gladius-cli")
	req.Header.Set("Content-Type", "application/json")

	// Send the request via a client
	res, err := client.Do(req)
	if err != nil {
		log.Fatal("Do: ", err)
	}

	fmt.Println(res)

	body, readErr := ioutil.ReadAll(res.Body)
	if readErr != nil {
		log.Fatal(readErr)
	}
	// Defer the closing of the body
	defer res.Body.Close()

	fmt.Println(string(body))
}

// Create a Node contract
func createNode() {
	url := "http://localhost:3000/api/node/create/"

	// Build the request
	req, err := http.NewRequest("POST", url, nil)
	if err != nil {
		log.Fatal("NewRequest: ", err)
	}

	req.Header.Set("User-Agent", "gladius-cli")
	req.Header.Set("Content-Type", "application/json")

	// Send the request via a client
	res, err := client.Do(req)
	if err != nil {
		log.Fatal("Do: ", err)
	}

	body, readErr := ioutil.ReadAll(res.Body)
	if readErr != nil {
		log.Fatal(readErr)
	}

	// close body when done
	defer res.Body.Close()

	fmt.Println(string(body)) //tx
}

// Set data for a Node contract
func setNodeData(nodeAddress string) {
	url := fmt.Sprintf("http://localhost:3000/api/node/%s/data", nodeAddress)

	jsonPayload, err := json.Marshal(myNode.Data)
	if err != nil {
		log.Fatal("NewRequest: ", err)
	}

	// Build the request
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonPayload))
	if err != nil {
		log.Fatal("NewRequest: ", err)
	}

	req.Header.Set("User-Agent", "gladius-cli")
	req.Header.Set("Content-Type", "application/json")

	// Send the request via a client
	res, err := client.Do(req)
	if err != nil {
		log.Fatal("Do: ", err)
	}

	body, readErr := ioutil.ReadAll(res.Body)
	if readErr != nil {
		log.Fatal(readErr)
	}

	// Defer the closing of the body
	defer res.Body.Close()

	fmt.Println(string(body)) //tx
}

func applyToPool(poolAddress string) {

}
