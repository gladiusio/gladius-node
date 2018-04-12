package rpcmanager

// RPCOut - Transport struct
type RPCOut struct {
	HTTPState chan bool
}

// HTTPOut - Transport struct
type HTTPOut struct {
}

// GladiusEdge - Entry for the RPC interface. Methods take the form GladiusEdge.Method
type GladiusEdge struct {
	RPCOut *RPCOut
}

// Start - Start the gladius edge node
func (g *GladiusEdge) Start(vals [2]int, res *string) error {
	g.RPCOut.HTTPState <- true
	*res = "Started the server"
	return nil
}

// Stop - Stop the gladius edge node
func (g *GladiusEdge) Stop(vals [2]int, res *string) error {
	g.RPCOut.HTTPState <- false
	*res = "Stopped the server"
	return nil
}

// Status - Get the current status of the network node
func (g *GladiusEdge) Status(vals [2]int, res *string) error {
	*res = "Not Implemented"
	return nil
}
