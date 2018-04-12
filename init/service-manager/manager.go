/*
Package manager - Creates the service
*/
package manager

import (
	"fmt"
	"log"
	"os"

	"github.com/kardianos/service"
)

// Get a logger
var logger service.Logger

// Create a program struct to store the run executable
type program struct {
	exec func()
}

// RunService - Main entry-point for the service
func RunService(name string, displayName string, description string, run func()) {
	// Define the service configuration.
	svcConfig := &service.Config{
		Name:        name,
		DisplayName: displayName,
		Description: description,
	}

	// Run the function "run" as a service
	runAsService(svcConfig, run)
}

// Run the program as a service
func runAsService(svcConfig *service.Config, run func()) {
	// Create a new service with the specified config
	s, err := service.New(&program{exec: run}, svcConfig)
	if err != nil {
		log.Fatal(err)
	}

	// Check for arguments, if there are any set it to use controls like:
	// "start", "stop", "install", "uninstall"
	if len(os.Args) > 1 {
		err = service.Control(s, os.Args[1])
		if err != nil {
			log.Fatal(err)
		}
		return // Don't execute the rest of the code
	}

	// Build loggers
	logger, err = s.Logger(nil)
	if err != nil {
		log.Fatal(err)
	}
	err = s.Run()
	if err != nil {
		logger.Error(err)
	}
}

// Start the program (call the exec function)
func (p *program) Start(s service.Service) error {
	// Start should not block. Do the actual work async.
	go p.exec()
	return nil
}

// Stop the program
func (p *program) Stop(s service.Service) error {
	fmt.Println("\nStoping....")
	return nil
}
