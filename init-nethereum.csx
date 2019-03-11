//#r "nuget:Nethereum.Web3"
//#r "nuget:Nethereum.Accounts"
//#r "nuget:Nethereum.JsonRpc.Client"
//#r "nuget:Nethereum.RPC"
//#r "nuget:Newtonsoft.Json"
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

private static string ToJson(object obj) {
	return JsonConvert.SerializeObject(obj, Formatting.Indented);
}

Console.WriteLine("\nLoading Web3...");
var Web3 = ContractUtil.Web3;
var Node = ContractUtil.Node;
var Convert = ContractUtil.Convert;
Console.WriteLine("Web3 configuration initialized successfully!");

Console.WriteLine("\nLoading wallet address...");
var Wallet = ContractUtil.GetWalletAddressFromGanacheLog("ganache-output.txt");
Console.WriteLine("Wallet address detected at " + Wallet + "\n");

var Password = "password";
Console.WriteLine("Unlocking wallet using password \"" + Password + "\"...");
Console.WriteLine("Wallet unlocked: " + ContractUtil.UnlockWallet(Wallet, Password).Await() + "\n");

Console.WriteLine("Deploying TenderApi contract...");
var TenderApiCompiled = ContractUtil.GetCompiledContract(@"build\contracts\TenderApi.json");
var TenderApiAbi = TenderApiCompiled.Abi;
var TenderApiByteCode = TenderApiCompiled.ByteCode;
var TenderApiDeployment = ContractUtil.DeployContract(TenderApiCompiled, Wallet).Await();
var TenderApi = TenderApiDeployment.Contract;
var TenderApiReceipt = TenderApiDeployment.Receipt;
Console.WriteLine("\nTenderApiReceipt: " + ToJson(TenderApiReceipt) + "\n");

Console.WriteLine("Deploying Tender contract...");
var TenderCompiled = ContractUtil.GetCompiledContract(@"build\contracts\Tender.json");
var TenderAbi = TenderCompiled.Abi;
var TenderByteCode = TenderCompiled.ByteCode;
var TenderDeployment = ContractUtil.DeployContract(TenderCompiled, Wallet,
	TenderApi.Address, //the Tender owner address
	"10", "20", "30", //smallServerPrice, mediumServerPrice, largeServerPrice
	"1", "100", //min, max server order numbers
	"25", //daysForDelivery
	"2", //penaltyPerDay
	"200", //penaltyCap
	"2000", //maximumCostofExtras
	"21102020", //expiryDate
	"10987", //operatorId
	"1" //guaranteeRequired
).Await();
var Tender = TenderDeployment.Contract;
var TenderReceipt = TenderDeployment.Receipt;
Console.WriteLine("\nTenderReceipt: " + ToJson(TenderReceipt) + "\n");

Console.WriteLine("Calling TenderApi.setCurrentAddress(Tender.Address)...\n");
Console.WriteLine("Function call transaction hash:");
Console.WriteLine(TenderApi.CallWrite("setCurrentAddress", Wallet, Tender.Address).Await());
Console.WriteLine("\nReady!\n");

//TenderApi.CallRead<string>("current").Await();