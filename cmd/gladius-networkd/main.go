package main

import (
	config "github.com/gladiusio/gladius-node/configs"
	"github.com/gladiusio/gladius-node/init/service-manager"
	"github.com/gladiusio/gladius-node/internal/network-daemon"
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
