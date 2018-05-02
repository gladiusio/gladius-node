package main

import (
	"github.com/gladiusio/gladius-networkd/networkd"
)

// Main - entry-point for the service
func main() {
	networkd.SetupAndRun()
}
