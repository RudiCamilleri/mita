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

private static void Await(Task task) {
	SpinWait.SpinUntil(() => task.IsCompleted);
}

private static T Await<T>(Task<T> task, bool waitUntilNotNull = false) {
	do {
		SpinWait.SpinUntil(() => task.IsCompleted);
	} while (waitUntilNotNull && task.Result == null);
	return task.Result;
}

private static string GetWalletAddressFromGanacheLog(string path) {
	while (true) {
		var stream = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.ReadWrite);
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
			return content.Substring(index, end - index).Trim();
		}
	}
	throw new Exception("Wallet address could not be loaded");
}

public static Web3 Web3 = new Web3("http://localhost:8545");
Console.WriteLine("\nWeb3 now loaded using Nethereum!\n");

private static bool UnlockGanacheWallet(string address, string password) {
	return Await<bool>(Web3.Personal.UnlockAccount.SendRequestAsync(address, password, 120));
}

//uses truffle compile output json
public static Contract DeployContract(string jsonPath, string walletOwner, HexBigInteger gas, HexBigInteger gasPrice, HexBigInteger value, params object[] constructorParams) {
	var json = Newtonsoft.Json.JsonConvert.DeserializeObject(File.ReadAllText(jsonPath));
	var abi = ((JObject) json)["abi"].ToString();
	var byteCode = ((JObject) json)["bytecode"].ToString();
	var transactionHash = Await<string>(Web3.Eth.DeployContract.SendRequestAsync(abi, byteCode, walletOwner, gas, gasPrice, value, constructorParams));
	Console.WriteLine("Transaction Hash: " + transactionHash + "\n");
	var receipt = Await<TransactionReceipt>(Web3.Eth.Transactions.GetTransactionReceipt.SendRequestAsync(transactionHash), true);
	return Web3.Eth.GetContract(abi, receipt.ContractAddress);
}

Console.WriteLine("Loading wallet address...");
var walletOwner = GetWalletAddressFromGanacheLog("ganache-output.txt");
Console.WriteLine("Wallet address detected at " + walletOwner + "\n");

var password = "password";
Console.WriteLine("Unlocking wallet using password \"" + password + "\"...");
Console.WriteLine("Wallet unlocked: " + UnlockGanacheWallet(walletOwner, password) + "\n");

Console.WriteLine("Creating contract...");
var gas = new HexBigInteger("0x6691b7");
var gasPrice = new HexBigInteger("0x77359400");
var value = new HexBigInteger("0x0");
var TenderApi = DeployContract(@"build\contracts\TenderApi.json", walletOwner, gas, gasPrice, value);

//var geth = new Web3Geth("http://127.0.0.1:8545");
//Console.WriteLine("Transaction Mined: " + Await<bool>(geth.Miner.Start.SendRequestAsync(6)));

//Await<bool>(geth.Miner.Stop.SendRequestAsync());

/*var setCurrentAddress = contract.GetFunction("setCurrentAddress");
var current = contract.GetFunction("current");
Await<string>(current.CallAsync<string>());
Await(setCurrentAddress.CallAsync<string>("0x82"));
Await<string>(current.CallAsync<string>());*/