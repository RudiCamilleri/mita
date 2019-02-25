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
using System;
using System.Collections;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
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
using Nethereum.Hex.HexConvertors.Extensions;
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

Console.WriteLine("Wallet address detected at " + senderAddress + "\n");
var password = "password";
var tenderApiJson = Newtonsoft.Json.JsonConvert.DeserializeObject(File.ReadAllText(@"build\contracts\TenderApi.json"));
var tenderApiAbi = ((JObject) tenderApiJson)["abi"].ToString();
var tenderApiByteCode = ((JObject) tenderApiJson)["bytecode"].ToString();

Console.WriteLine("Unlocking wallet using password \"password\"...");
var unlockAccountResult = web3.Personal.UnlockAccount.SendRequestAsync(senderAddress, password, 120);
SpinWait.SpinUntil(delegate() { Thread.Sleep(100); return unlockAccountResult.Result; });
Console.WriteLine("Wallet unlocked: " + unlockAccountResult.Result + "\n");

Console.WriteLine("Creating contract...");

var transactionHash = await web3.Eth.DeployContract.SendRequestAsync(tenderApiAbi, tenderApiByteCode, senderAddress /*, constructor parameters come here*/);

var mineResult = await web3.Miner.Start.SendRequestAsync(6);

/*

Assert.True(mineResult);

var receipt = await web3.Eth.Transactions.GetTransactionReceipt.SendRequestAsync(transactionHash);

while (receipt == null)
{
	Thread.Sleep(5000);
	receipt = await web3.Eth.Transactions.GetTransactionReceipt.SendRequestAsync(transactionHash);
}

mineResult = await web3.Miner.Stop.SendRequestAsync();
Assert.True(mineResult);

var contractAddress = receipt.ContractAddress;

var contract = web3.Eth.GetContract(abi, contractAddress);

var multiplyFunction = contract.GetFunction("multiply");

var result = await multiplyFunction.CallAsync<int>(7);

Assert.Equal(49, result);*/