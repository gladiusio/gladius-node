package main

import (
	"github.com/gladiusio/gladius-controld/pkg/routing"
	"github.com/gladiusio/gladius-utils/config"
	"github.com/gladiusio/gladius-utils/init/manager"
)

func main() {
	// Setup config handling
	config.SetupConfig("gladius-controld", config.ControlDaemonDefaults())
	// Define some variables
	name, displayName, description :=
		"GladiusControlDaemon",
		"Gladius Control Daemon",
		"Gladius Control Daemon"

	// Run the function "run" in newtworkd as a service
	manager.RunService(name, displayName, description, routing.Start)
}
