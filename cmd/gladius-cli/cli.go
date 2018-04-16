package main

import (
	"github.com/gladiusio/gladius-node/pkg/cli"
)

func main() {
	var localSettings = node.Settings{}
	var myNode = node.Node{}

	myNode.Data.Name = "celo-test-2"
	myNode.Data.Email = "celo@gladius.io"
	myNode.Data.IPAddress = "1.1.1.1"
	myNode.Data.Status = "active"

	// always post settings
	node.SetSettings("ropsten", &localSettings)
	node.PostSettings(&localSettings)

	// // create a node contract and wait for tx to finish
	// tx := node.CreateNode()
	// node.WaitForTx(tx)
	//
	// // get the address of new node, set its data, and wait
	// nodeAddress := node.GetNodeAddress()
	// tx = node.SetNodeData(nodeAddress, myNode)
	// node.WaitForTx(tx)
	//
	// // apply to pool
	// tx = node.ApplyToPool(nodeAddress, "0xC88a29cf8F0Baf07fc822DEaA24b383Fc30f27e4")
	// node.WaitForTx(tx)
	//
	// node.StartEdgeNode()
	// node.StopEdgeNode()
	// node.StatusEdgeNode()

	// test()
	// getSettings()
	// fmt.Println(getNodeAddress())
	// res := createNode()
	// checkTx("0x3e1514aa08b0dcf9058893fef05c15aae6986ec64eddcbf0f5b30b9694233e73")
}
