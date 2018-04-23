package commands

import (
	"fmt"
	"strings"

	"github.com/gladiusio/gladius-node/pkg/cli"
	"github.com/spf13/cobra"
)

var localSettings = node.Settings{}
var myNode = node.Node{}
var poolAddress = "0xC88a29cf8F0Baf07fc822DEaA24b383Fc30f27e4"

var cmdEcho = &cobra.Command{
	Use:   "echo [string to echo]",
	Short: "Echo anything to the screen",
	Long: `echo is for echoing anything back.
    Echo echo’s.
    `,
	Run: echoRun,
}

var createNode = &cobra.Command{
	Use:   "create",
	Short: "Deploy a new Node smart contract",
	Long:  "Deploys a new Node smart contract to the network with data",
	Run:   createNewNode,
}

var applyPool = &cobra.Command{
	Use:   "apply [node address]",
	Short: "Apply to a Gladius Pool",
	Long:  "Send your Node's data (encrypted) to the pool owner as an application",
	Run:   applyToPool,
}

var checkApp = &cobra.Command{
	Use:   "check [node address]",
	Short: "Check status of your submitted pool application",
	Long:  "Check status of your submitted pool application",
	Run:   checkPoolApp,
}

var netDaemon = &cobra.Command{
	Use:   "edge [start|stop|status]",
	Short: "Start the edge daemon",
	Long:  "Start the edge daemon networking server",
	Run:   edge,
}

func createNewNode(cmd *cobra.Command, args []string) {
	tx, err := node.CreateNode()
	if err != nil {
		fmt.Println(err)
	}

	node.WaitForTx(tx)
	nodeAddress := node.GetNodeAddress()
	fmt.Println("Node created!")

	tx, err = node.SetNodeData(nodeAddress, myNode)
	if err != nil {
		fmt.Println(err)
	}

	node.WaitForTx(tx)
	fmt.Println("Node data set!")

	fmt.Println("\n" + nodeAddress)
}

func applyToPool(cmd *cobra.Command, args []string) {
	tx, err := node.ApplyToPool(args[0], poolAddress)
	if err != nil {
		fmt.Println(err)
	}

	node.WaitForTx(tx)
	fmt.Println("Application sent to pool!")
}

func checkPoolApp(cmd *cobra.Command, args []string) {
	status := node.CheckPoolApplication(args[0], poolAddress)
	fmt.Println("Pool: " + poolAddress + "\t Status: " + status)
}

func edge(cmd *cobra.Command, args []string) {

	var reply string
	switch args[0] {
	case "start":
		reply = node.StartEdgeNode()
	case "stop":
		reply = node.StopEdgeNode()
	case "status":
		reply = node.StatusEdgeNode()
	default:
		reply = "command not recognized"
	}
	fmt.Println("Edge Daemon:\t", reply)
}

func echoRun(cmd *cobra.Command, args []string) {
	fmt.Println(strings.Join(args, " "))
}

func init() {

	// all of this will go in some config file
	myNode.Data.Name = "celo-test-4"
	myNode.Data.Email = "celo@gladius.io"
	myNode.Data.IPAddress = "1.1.1.1"
	myNode.Data.Status = "active"

	node.SetSettings("ropsten", &localSettings)
	node.PostSettings(&localSettings)

	rootCmd.AddCommand(cmdEcho)
	rootCmd.AddCommand(createNode)
	rootCmd.AddCommand(applyPool)
	rootCmd.AddCommand(checkApp)
	rootCmd.AddCommand(netDaemon)
}
