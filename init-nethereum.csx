//#r "nuget:Nethereum.Web3"
//#r "nuget:Nethereum.Accounts"
//#r "nuget:Nethereum.JsonRpc.Client"
//#r "nuget:Nethereum.RPC"
//#r "nuget:Newtonsoft.Json"
//#r "nuget:Nethereum.Geth"
//#r "ContractUtils"
#r "Nethereum.Web3"
#r "Nethereum.Accounts"
#r "Nethereum.JsonRpc.Client"
#r "Nethereum.RPC"
#r "Newtonsoft.Json"
#r "Nethereum.Geth"
#r "ContractUtils"
using System;
using System.Collections;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.Linq;
using System.IO;
using System.Reflection;
using System.Reflection.Emit;
using System.Runtime;
using System.Runtime.InteropServices;
using System.Numerics;
using System.Text;
using System.Timers;
using System.Threading;
using System.Threading.Tasks;
using System.Web;
using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.ABI.Model;
using Nethereum.Contracts;
using Nethereum.Contracts.CQS;
using Nethereum.Contracts.Extensions;
using Nethereum.Geth;
using Nethereum.Geth.RPC;
using Nethereum.Geth.RPC.Miner;
using Nethereum.Hex.HexConvertors;
using Nethereum.Hex.HexConvertors.Extensions;
using Nethereum.Hex.HexTypes;
using Nethereum.RPC;
using Nethereum.RPC.Eth;
using Nethereum.RPC.Eth.DTOs;
using Nethereum.RPC.Eth.Transactions;
using Nethereum.Util;
using Nethereum.Web3;
using Nethereum.Web3.Accounts;
using Newtonsoft;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using ContractUtils;

static string GanacheLogPath = "ganache-output.txt";
static bool ShowFullReceipt = false;

//Utility method that converts an object to a pretty JSON string
static string ToJson(object obj) {
	return JsonConvert.SerializeObject(obj, Formatting.Indented);
}

static string GetReceipt(string transactionHash) {
	return ShowFullReceipt ? ToJson(ContractUtil.GetReceipt(transactionHash).Await()) : transactionHash;
}

static string GetReceipt(Task<string> transactionHash) {
	return GetReceipt(transactionHash.Await());
}

static void ViewGanacheLog() {
	Process.Start(GanacheLogPath);
}

//Starts the contract deployment
//try {
	Console.WriteLine("\nLoading Web3...");
	var Web3 = ContractUtil.Web3;
	var Node = ContractUtil.Node;
	var Convert = ContractUtil.Convert;
	Console.WriteLine("Web3 configuration initialized successfully!");

	Console.WriteLine("\nLoading wallet address...");
	var Wallet = ContractUtil.GetWalletAddressFromGanacheLog(GanacheLogPath);
	Console.WriteLine("Wallet address detected at " + Wallet);

	/*var Password = "password";
	Console.WriteLine("Unlocking wallet using password \"" + Password + "\"...");
	Console.WriteLine("Wallet unlocked: " + ContractUtil.UnlockWallet(Wallet, Password).Await() + "\n");*/

	Console.WriteLine("\nDeploying TenderAPI contract...");
	var TenderAPICompiled = ContractUtil.GetCompiledContract(@"build\contracts\TenderAPI.json");
	var TenderAPIAbi = TenderAPICompiled.Abi;
	var TenderAPIByteCode = TenderAPICompiled.ByteCode;
	var TenderAPIDeployment = ContractUtil.DeployContract(TenderAPICompiled, Wallet).Await();
	var TenderAPI = TenderAPIDeployment.Contract;
	var TenderAPIReceipt = TenderAPIDeployment.Receipt;
	Console.WriteLine("\nTenderAPIReceipt: " + ToJson(TenderAPIReceipt));

	Console.WriteLine("\nDeploying TenderBLL contract...");
	var TenderBLLCompiled = ContractUtil.GetCompiledContract(@"build\contracts\TenderBLL.json");
	var TenderBLLAbi = TenderBLLCompiled.Abi;
	var TenderBLLByteCode = TenderBLLCompiled.ByteCode;
	var TenderBLLDeployment = ContractUtil.DeployContract(TenderBLLCompiled, Wallet, TenderAPI.Address).Await();
	var TenderBLL = TenderBLLDeployment.Contract;
	var TenderBLLReceipt = TenderBLLDeployment.Receipt;
	Console.WriteLine("\nTenderBLLReceipt: " + ToJson(TenderBLLReceipt));

	Console.WriteLine("\nDeploying TenderData contract...");
	var TenderDataCompiled = ContractUtil.GetCompiledContract(@"build\contracts\TenderData.json");
	var TenderDataAbi = TenderDataCompiled.Abi;
	var TenderDataByteCode = TenderDataCompiled.ByteCode;
	var TenderDataDeployment = ContractUtil.DeployContract(TenderDataCompiled, Wallet, TenderBLL.Address).Await();
	var TenderData = TenderDataDeployment.Contract;
	var TenderDataReceipt = TenderDataDeployment.Receipt;
	Console.WriteLine("\nTenderDataReceipt: " + ToJson(TenderDataReceipt));

	if (Environment.GetEnvironmentVariable("VERBOSE") != null)
		ShowFullReceipt = true;
	else if (Environment.GetEnvironmentVariable("SILENT") == null) {
		Console.Write("\nWould you like to show full receipt for every function call? y/N (default is N): ");
		switch (Console.ReadLine().Trim().ToLower()) {
			case "1":
			case "true":
			case "yes":
			case "y":
			case "ye":
				ShowFullReceipt = true;
				break;
			default:
				ShowFullReceipt = false;
				break;
		}
	}

	Console.WriteLine("\nCalling TenderAPI.replaceTenderBLL(TenderBLL.Address)...");
	Console.Write("Function call transaction: ");
	Console.WriteLine(GetReceipt(TenderAPI.CallWrite("replaceTenderBLL", Wallet, TenderBLL.Address)));

	Console.WriteLine("\nCalling TenderAPI.replaceTenderData(TenderData.Address, false, false)...");
	Console.Write("Function call transaction: ");
	Console.WriteLine(GetReceipt(TenderAPI.CallWrite("replaceTenderData", Wallet, TenderData.Address, false, false)));

	Console.WriteLine("\nCalling TenderAPI.createContract([10, 20, 30, 2, 21102018, 21102020, 1], [123, 10987], [1])...");
	Console.Write("Function call transaction: ");
	Console.WriteLine(GetReceipt(TenderAPI.CallWrite("createContract", Wallet, new BigInteger[] {
			10, 20, 30, //smallServerPrice, mediumServerPrice, largeServerPrice
			2, //penaltyPerDay
			21102018, //creationDate
			21102020, //expiryDate
			1 //guaranteeRequired
		}, new uint[] {
			123, //contractId
			10987, //operatorId
		}, new ushort[] { 1 } //daysForDelivery
	)));

	Console.WriteLine("\nCalling TenderAPI.createOrder(123, 12, 0, 3, 1)...");
	Console.Write("Function call transaction: ");
	//uint32 contractId, uint32 orderId, uint16 small, uint16 medium, uint16 large
	Console.WriteLine(GetReceipt(TenderAPI.CallWrite("createOrder", Wallet, 123, 12, 0, 3, 1)));
	Console.WriteLine("\nReady!\n");
//} catch (Exception ex) {
//	ErrorHandler.Show("An error occurred while executing init-nethereum.csx", ex);
//}

//TenderAPI.CallRead<string>("tenderBLL").Await();