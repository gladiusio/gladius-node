package main

import (
	"github.com/gladiusio/gladius-networkd/networkd"
	"github.com/gladiusio/gladius-utils/init/manager"

	"github.com/gladiusio/gladius-utils/config"
)

// Main entry-point for the service
func main() {
	// Setup config handling
	config.SetupConfig("gladius-networkd", config.NetworkDaemonDefaults())

	// Define some variables
	name, displayName, description :=
		"GladiusNetworkDaemon",
		"Gladius Network (Edge) Daemon",
		"Gladius Network (Edge) Daemon"

	// Run the function "run" in newtworkd as a service
	manager.RunService(name, displayName, description, networkd.Run)
}
