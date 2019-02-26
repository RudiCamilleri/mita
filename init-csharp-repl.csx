//#r "nuget:Nethereum.Web3"
//#r "nuget:Nethereum.Accounts"
//#r "nuget:Nethereum.JsonRpc.Client"
//#r "nuget:Nethereum.RPC"
//#r "nuget:Newtonsoft.Json"
#r "Nethereum.Web3"
#r "Nethereum.Accounts"
#r "Nethereum.JsonRpc.Client"
#r "Nethereum.RPC"
#r "Newtonsoft.Json"
#r "Nethereum.Geth"
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

var web3 = new Web3("http://localhost:8545");
Console.WriteLine("\n'web3' object now loaded using Nethereum, C# console loaded successfully.\n");

Console.WriteLine("Loading wallet address...");
string senderAddress;

while (true) {
	var stream = new FileStream("ganache-output.txt", FileMode.Open, FileAccess.Read, FileShare.ReadWrite);
	var reader = new StreamReader(stream);
	var content = reader.ReadToEnd();
	reader.Dispose();
	stream.Dispose();
	var search_string = "(0)";
	var index = content.IndexOf(search_string);
	if (index == -1) {
		Thread.Sleep(1000);
	} else {
		index += search_string.Length + 1;
		var end = index;
		while ((end < content.Length) && !(string.IsNullOrWhiteSpace(content.Substring(end, 1)))) {
			end++;
		}
		senderAddress = content.Substring(index, end - index).Trim();
		break;
	}
}

private static void Await<T>(Task task) {
	SpinWait.SpinUntil(() => task.IsCompleted);
}

private static T Await<T>(Task<T> task, bool waitUntilNotNull = false) {
	do {
		SpinWait.SpinUntil(() => task.IsCompleted);
	} while (waitUntilNotNull && task.Result == null);
	return task.Result;
}

Console.WriteLine("Wallet address detected at " + senderAddress + "\n");
var password = "password";
var tenderApiJson = Newtonsoft.Json.JsonConvert.DeserializeObject(File.ReadAllText(@"build\contracts\TenderApi.json"));
var tenderApiAbi = ((JObject) tenderApiJson)["abi"].ToString();
var tenderApiByteCode = ((JObject) tenderApiJson)["bytecode"].ToString();

Console.WriteLine("Unlocking wallet using password \"password\"...");
Console.WriteLine("Wallet unlocked: " + Await<bool>(web3.Personal.UnlockAccount.SendRequestAsync(senderAddress, password, 120)) + "\n");

Console.WriteLine("Creating contract...");
var gas = new HexBigInteger("0x6691b7");
var gasPrice = new HexBigInteger("0x77359400");
var value = new HexBigInteger("0x0");
var transactionHash = Await<string>(web3.Eth.DeployContract.SendRequestAsync(tenderApiAbi, tenderApiByteCode, senderAddress, gas, gasPrice, value/*, constructor parameters come here*/));
Console.WriteLine("Transaction Hash: " + transactionHash + "\n");

//var geth = new Web3Geth();
//Console.WriteLine("Transaction Mined: " + Await<bool>(geth.Miner.Start.SendRequestAsync(6)));

var receipt = Await<TransactionReceipt>(web3.Eth.Transactions.GetTransactionReceipt.SendRequestAsync(transactionHash), true);

//Await<bool>(geth.Miner.Stop.SendRequestAsync());

var contract = web3.Eth.GetContract(tenderApiAbi, receipt.ContractAddress);
var setCurrentAddress = contract.GetFunction("setCurrentAddress");
var current = contract.GetFunction("current");
Await<string>(current.CallAsync<string>());
Await(setCurrentAddress.CallAsync<string>("0x82"));
Await<string>(current.CallAsync<string>());