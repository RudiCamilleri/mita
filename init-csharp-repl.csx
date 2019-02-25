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
//using Nethereum.Contracts;
//using Nethereum.Contracts.CQS;
//using Nethereum.Contracts.Extensions;
//using Nethereum.Hex.HexConvertors.Extensions;
using Nethereum.Util;
using Nethereum.Web3;
using Nethereum.Web3.Accounts;
using Newtonsoft;

var web3 = new Web3("http://localhost:8545");
Console.WriteLine("\n'web3' object now loaded using Nethereum, C# console loaded successfully.\n");

var senderAddress = "0x5fbf49e66af350556c6186cb5e053fc22eecbde4";
var password = "password";
var tenderApiAbi = Newtonsoft.Json.JsonConvert.DeserializeObject(File.ReadAllText(@"build\contracts\TenderApi.json"));

/*var senderAddress = "0x12890d2cce102216644c59daE5baed380d84830c";
var password = "password";
var abi = @"[{""constant"":false,""inputs"":[{""name"":""val"",""type"":""int256""}],""name"":""multiply"",""outputs"":[{""name"":""d"",""type"":""int256""}],""type"":""function""},{""inputs"":[{""name"":""multiplier"",""type"":""int256""}],""type"":""constructor""}]";
var byteCode =
	"0x60606040526040516020806052833950608060405251600081905550602b8060276000396000f3606060405260e060020a60003504631df4f1448114601a575b005b600054600435026060908152602090f3";

var multiplier = 7;

var web3 = new Web3.Web3();
var unlockAccountResult =
	await web3.Personal.UnlockAccount.SendRequestAsync(senderAddress, password, 120);
Assert.True(unlockAccountResult);

var transactionHash =
	await web3.Eth.DeployContract.SendRequestAsync(abi, byteCode, senderAddress, multiplier);

var mineResult = await web3.Miner.Start.SendRequestAsync(6);

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