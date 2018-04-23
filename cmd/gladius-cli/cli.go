package main

import (
	"fmt"

	"gopkg.in/AlecAivazis/survey.v1"
)

// the questions to ask
var qs = []*survey.Question{
	{
		Name:      "name",
		Prompt:    &survey.Input{Message: "What is your name?"},
		Validate:  survey.Required,
		Transform: survey.Title,
	},
	{
		Name: "color",
		Prompt: &survey.Select{
			Message: "Choose a color:",
			Options: []string{"red", "blue", "green"},
			Default: "red",
		},
	},
	{
		Name:   "age",
		Prompt: &survey.Input{Message: "How old are you?"},
	},
}

func main() {
	// the answers will be written to this struct
	answers := struct {
		Name          string // survey will match the question and field names
		FavoriteColor string `survey:"color"` // or you can tag fields to match a specific name
		Age           int    // if the types don't match exactly, survey will try to convert for you
	}{}

	// perform the questions
	err := survey.Ask(qs, &answers)
	if err != nil {
		fmt.Println(err.Error())
		return
	}

	fmt.Printf("%s chose %s.", answers.Name, answers.FavoriteColor)
	// commands.Execute()
}

// func theWorks() {
//
// 	myNode.Data.Name = "celo-test-3"
// 	myNode.Data.Email = "celo@gladius.io"
// 	myNode.Data.IPAddress = "1.1.1.1"
// 	myNode.Data.Status = "active"
//
// 	fmt.Println()
// 	// always post settings
// 	node.SetSettings("ropsten", &localSettings)
// 	node.PostSettings(&localSettings)
//
// 	// create a node contract and wait for tx to finish
// 	tx, _ := node.CreateNode()
// 	node.WaitForTx(tx)
// 	fmt.Println("Node created!")
//
// 	// get the address of new node, set its data, and wait
// 	myNode.Address = node.GetNodeAddress()
// 	tx, _ = node.SetNodeData(myNode.Address, myNode)
// 	node.WaitForTx(tx)
// 	fmt.Println("Data set!")
//
// 	// apply to pool
// 	tx, _ = node.ApplyToPool(myNode.Address, poolAddress)
// 	node.WaitForTx(tx)
// 	fmt.Println("Applied to pool!")
//
// 	// check pool application status
// 	fmt.Println(node.CheckPoolApplication(myNode.Address, poolAddress))
// }
//
// func networkDaemon() {
// 	node.StartEdgeNode()
// 	node.StatusEdgeNode()
// 	node.StopEdgeNode()
// }
