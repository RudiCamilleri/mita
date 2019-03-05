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

var password = "password";
Console.WriteLine("Unlocking wallet using password \"" + password + "\"...");
Console.WriteLine("Wallet unlocked: " + ContractUtil.UnlockWallet(Wallet, password).Await() + "\n");

Console.WriteLine("Deploying TenderApi contract...");
var TenderApiDeployment = ContractUtil.DeployContract(@"build\contracts\TenderApi.json", Wallet).Await();
var TenderApi = TenderApiDeployment.Contract;
var TenderApiReceipt = TenderApiDeployment.Receipt;
Console.WriteLine("\nTenderApiReceipt: " + ToJson(TenderApiReceipt) + "\n");

//TenderApi.CallRead<string>("setCurrentAddress", "0x82").Await();
//TenderApi.CallRead<string>("current").Await();
//TenderApi.CallWrite("incrementTest", Wallet).Await();
//TenderApi.CallRead<byte>("test").Await();