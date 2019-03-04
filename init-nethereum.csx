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

//glue code for scriptcs as it does not support await command
private static void Await(Task task) {
	SpinWait.SpinUntil(() => task.IsCompleted);
}

//glue code for scriptcs as it does not support await command
private static T Await<T>(Task<T> task, bool waitUntilNotNull = false) {
	do {
		SpinWait.SpinUntil(() => task.IsCompleted);
	} while (waitUntilNotNull && task.Result == null);
	return task.Result;
}

Console.WriteLine("Loading wallet address...");
var wallet = ContractUtil.GetWalletAddressFromGanacheLog("ganache-output.txt");
Console.WriteLine("Wallet address detected at " + wallet + "\n");

var password = "password";
Console.WriteLine("Unlocking wallet using password \"" + password + "\"...");
Console.WriteLine("Wallet unlocked: " + Await(ContractUtil.UnlockWallet(wallet, password)) + "\n");

Console.WriteLine("Creating contract...");
var TenderApiDeployment = Await(ContractUtil.DeployContract(@"build\contracts\TenderApi.json", wallet));
var TenderApi = TenderApiDeployment.Contract;
Console.WriteLine("\nTransactionReceipt: " + Newtonsoft.Json.JsonConvert.SerializeObject(TenderApiDeployment.Receipt, Formatting.Indented) + "\n");

//Await(TenderApi.CallRead<string>("setCurrentAddress", "0x82"));
//Await(TenderApi.CallRead<string>("current"));
//Await(TenderApi.GetFunction("incrementTest").CallAsync<byte>());
//Await(TenderApi.GetFunction("test").CallAsync<byte>());
//TenderApi.CallWrite("incrementTest", wallet);