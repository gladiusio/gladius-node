package networkd

import (
	"errors"
	"fmt"
	"io/ioutil"
	"log"
	"net"
	"net/http"
	"net/rpc"
	"path"
	"strings"

	"github.com/gladiusio/gladius-node/internal/rpc-manager"
	"github.com/spf13/viper"

	"github.com/powerman/rpc-codec/jsonrpc2"
	"github.com/valyala/fasthttp"
)

// Run - Start a web server
func Run() {
	fmt.Println("Starting...")
	// Get where the content is stored and load into memory
	bundleMap := loadContentFromDisk()

	// Create some strucs so we can pass info between goroutines
	rpcOut := &rpcmanager.RPCOut{HTTPState: make(chan bool)}
	httpOut := &rpcmanager.HTTPOut{}

	//  -- Content server stuff below --

	// Listen on 8080
	lnContent, err := net.Listen("tcp", ":8080")
	if err != nil {
		panic(err)
	}
	// Create a content server
	server := fasthttp.Server{Handler: requestHandler(httpOut, bundleMap)}
	// Serve the content
	defer lnContent.Close()
	go server.Serve(lnContent)

	// -- RPC Stuff below --

	// Register RPC methods
	rpc.Register(&rpcmanager.GladiusEdge{RPCOut: rpcOut})
	// Setup HTTP handling for RPC on port 5000
	http.Handle("/rpc", jsonrpc2.HTTPHandler(nil))
	lnHTTP, err := net.Listen("tcp", ":5000")
	if err != nil {
		panic(err)
	}
	defer lnHTTP.Close()
	go http.Serve(lnHTTP, nil)

	fmt.Println("Started RPC server and HTTP server.")

	// Forever check through the channels on the main thread
	for {
		select {
		case state := <-(*rpcOut).HTTPState: // If it can be assigned to a variable
			if state {
				lnContent, err = net.Listen("tcp", ":8080")
				if err != nil {
					panic(err)
				}
				go server.Serve(lnContent)
				fmt.Println("Started HTTP server (from RPC command)")
			} else {
				lnContent.Close()
				fmt.Println("Stopped HTTP server (from RPC command)")
			}
		}
	}
}

func getContentDir() (string, error) {
	// TODO: Actually get correct filepath
	// TODO: Add configurable values from a config file
	contentDir := viper.GetString("ContentDirectory")
	if contentDir == "" {
		return contentDir, errors.New("No content directory specified")
	}
	return contentDir, nil
}

// Return a map of the json bundles on disk
func loadContentFromDisk() map[string]string {
	filePath, err := getContentDir()
	if err != nil {
		panic(err)
	}

	files, err := ioutil.ReadDir(filePath)
	if err != nil {
		log.Fatal("Error when reading content dir: ", err)
	}

	m := make(map[string]string)

	for _, f := range files {
		name := f.Name()
		if strings.HasSuffix(name, ".json") {
			b, err := ioutil.ReadFile(path.Join(filePath, name))
			website := strings.Replace(name, ".json", "", 1)
			fmt.Println("Loaded content bundle for: " + website)
			if err != nil {
				log.Fatal(err)
			}
			m[website] = string(b)
		}
	}

	return m
}

// Return a function like the one fasthttp is expecting
func requestHandler(httpOut *rpcmanager.HTTPOut, bundleMap map[string]string) func(ctx *fasthttp.RequestCtx) {
	// The actual serving function
	return func(ctx *fasthttp.RequestCtx) {
		switch string(ctx.Path()) {
		case "/content":
			contentHandler(ctx, bundleMap)
			// TODO: Write stuff to pass back to httpOut
		default:
			ctx.Error("Unsupported path", fasthttp.StatusNotFound)
		}
	}
}

func contentHandler(ctx *fasthttp.RequestCtx, bundleMap map[string]string) {
	// URL format like /content?website=REQUESTED_SITE
	website := string(ctx.QueryArgs().Peek("website"))
	// TODO: Route handling like: route := string(ctx.QueryArgs().Peek("route"))

	ctx.SetContentType("application/json")
	ctx.SetStatusCode(fasthttp.StatusOK)
	// TODO: Verify the website exists on the filesystem
	fmt.Fprintf(ctx, bundleMap[website])
}
