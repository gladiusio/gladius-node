package main

import (
	"github.com/gladiusio/gladius-controld/pkg/config"
	"github.com/gladiusio/gladius-controld/pkg/routing"
	"github.com/gladiusio/gladius-utils/init/manager"
)

func main() {
	// Define some variables
	name, displayName, description := config.Config()

	router := config.NodeRouter()

	cRouter := routing.ControlRouter{
		Router: router,
		Port:   "3001",
	}

	// Run the function "run" in newtworkd as a service
	manager.RunService(name, displayName, description, cRouter.Start)
}
