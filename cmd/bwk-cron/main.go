package main

import (
	"fmt"
	"log"
	"os"

	"github.com/posq-crypto/posq-dash/data"
	"github.com/posq-crypto/posq-dash/model"
	"github.com/posq-crypto/posq-dash/rpc"
	"github.com/posq-crypto/posq-dash/sys"

	_ "github.com/joho/godotenv/autoload"
)

var (
	db   *data.DB
	node *rpc.RPC
)

// getData will return an info response object
// with the required data to be saved into the
// database for use by API.
func getData() (res *model.InfoResponse, err error) {
	// Get rpc information.
	var info *rpc.GetInfo
	info, err = node.GetInfo()
	if err != nil {
		fmt.Println("getData() => GetInfo():")
		return
	}

	// Setup the response object.
	res = new(model.InfoResponse)
	res.Blocks = info.Result.Blocks
	res.Blocks = info.Result.Blocks
	res.Connections = info.Result.Connections
	res.Country = ""
	res.Difficulty = info.Result.Difficulty
	res.DonationAddress = os.Getenv("DASH_DONATION_ADDRESS")
	res.MaxMemory = sys.GetMemorySize()
	res.NetworkHashPS = node.GetNetworkHashPS()
	res.Protocol = info.Result.Protocol
	res.Rank = 0
	res.Status = "Online"
	res.StakingStatus = info.Result.StakingStatus
	res.Subversion = node.GetVersion()
	res.Transactions = node.GetTransactions()
	res.UsedMemory = 0
	res.Version = info.Result.Version

	// Get the .onion address for the node or default
	// back to getting the ip address.
	res.IP, err = sys.GetTOR()
	if err != nil {
		return
	}

	// Setup the network name.
	res.Network = "mainnet"
	if info.Result.Testnet {
		res.Network = "testnet"
	}

	// Get the network traffic.
	res.IncomingData, res.OutgoingData = node.GetNetTotals()
	res.TotalData = res.IncomingData + res.OutgoingData

	// Get the max, mid, and min fees.
	res.MaxFee, res.MidFee, res.MinFee = node.GetFees()

	// Get memory information for the rpc.
	res.UsedMemory = node.GetUsedMemory()

	return
}

func main() {
	var err error

	// Setup database connection.
	db, err = data.NewSQL(os.ExpandEnv(os.Getenv("DASH_DB")))
	if err != nil {
		fmt.Println("DB Connection:")
		log.Fatal(err)
	}
	defer db.Close()

	// Setup the table structure if not found.
	err = db.Setup()
	if err != nil {
		fmt.Println("DB Table Setup:")
		log.Fatal(err)
	}
	fmt.Println("Database is setup!")

	// Setup rpc connection to rpc.
	node, err = rpc.NewRPC()
	if err != nil {
		fmt.Println("RPC Connection:")
		log.Fatal(err)
	}

	// Get information from rpc, apis, etc.
	var info *model.InfoResponse
	info, err = getData()
	if err != nil {
		fmt.Println("GetData():")
		log.Fatal(err)
	}

	// Store in database.
	err = db.Save(info)
	if err != nil {
		fmt.Println("DB Insert:")
		log.Fatal(err)
	}

	fmt.Println("Information saved to database!")
}
