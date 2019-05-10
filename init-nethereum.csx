#r "System.Numerics"
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
static bool ShowFullReceipt = Environment.GetEnvironmentVariable("MINIMAL") == null;

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

static void ShowTransaction(Task<string> transactionHash) {
	Console.Write("Transaction receipt: ");
	Console.WriteLine(GetReceipt(transactionHash));
}

static void ShowGanacheLog() {
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
	var Wallet = ContractUtil.GetWalletAddressFromGanacheLog(GanacheLogPath, 0);
	Console.WriteLine("Wallet address detected at " + Wallet);

	Console.WriteLine("\nLoading client wallet address...");
	var ClientWallet = ContractUtil.GetWalletAddressFromGanacheLog(GanacheLogPath, 1);
	Console.WriteLine("Client wallet address detected at " + ClientWallet);

	/*var Password = "password";
	Console.WriteLine("Unlocking wallet using password \"" + Password + "\"...");
	Console.WriteLine("Wallet unlocked: " + ContractUtil.UnlockWallet(Wallet, Password).Await() + "\n");*/

	Console.WriteLine("\nDeploying TenderLogic contract...");
	var TenderLogicCompiled = ContractUtil.GetCompiledContractFromFile(@"build\contracts\TenderLogic.json");
	var TenderLogicAbi = TenderLogicCompiled.Abi;
	var TenderLogicByteCode = TenderLogicCompiled.ByteCode;
	var TenderLogicDeployment = ContractUtil.DeployContract(TenderLogicCompiled, Wallet).Await();
	var TenderLogic = TenderLogicDeployment.Contract;
	var TenderLogicReceipt = TenderLogicDeployment.Receipt;
	Console.WriteLine("TenderLogicReceipt: " + ToJson(TenderLogicReceipt));

	Console.WriteLine("\nDeploying TenderData contract...");
	var TenderDataCompiled = ContractUtil.GetCompiledContractFromFile(@"build\contracts\TenderData.json");
	var TenderDataAbi = TenderDataCompiled.Abi;
	var TenderDataByteCode = TenderDataCompiled.ByteCode;
	var TenderDataDeployment = ContractUtil.DeployContract(TenderDataCompiled, Wallet, TenderLogic).Await();
	var TenderData = TenderDataDeployment.Contract;
	var TenderDataReceipt = TenderDataDeployment.Receipt;
	Console.WriteLine("TenderDataReceipt: " + ToJson(TenderDataReceipt));

	string GetContractState(int contractId) {
		return ToJson(new {
			client = TenderData.CallRead("getClient", contractId).Await(),
			state = TenderData.CallRead("getContractState", contractId).Await(),
			smallServerPrice = TenderData.CallRead("getSmallServerPrice", contractId).Await(),
			mediumServerPrice = TenderData.CallRead("getMediumServerPrice", contractId).Await(),
			largeServerPrice = TenderData.CallRead("getLargeServerPrice", contractId).Await(),
			penaltyPerDay = TenderData.CallRead("getPenaltyPerDay", contractId).Await(),
			guaranteeRequired = TenderData.CallRead("getGuaranteeRequired", contractId).Await(),
			clientGuaranteeBalance = TenderData.CallRead("getClientGuaranteeBalance", contractId).Await(),
			clientPenaltyBalance = TenderData.CallRead("getClientPenaltyBalance", contractId).Await(),
			guaranteePaid = (bool) TenderData.CallRead("getGuaranteePaid", contractId).Await(),
			attributes = new {
				small = TenderData.CallRead("getTotalSmallServersOrdered", contractId).Await(),
				medium = TenderData.CallRead("getTotalMediumServersOrdered", contractId).Await(),
				large = TenderData.CallRead("getTotalLargeServersOrdered", contractId).Await(),
				maxSmall = TenderData.CallRead("getMaxSmallServers", contractId).Await(),
				maxMedium = TenderData.CallRead("getMaxMediumServers", contractId).Await(),
				maxLarge = TenderData.CallRead("getMaxLargeServers", contractId).Await(),
				startDate = TenderData.CallRead("getContractStartDate", contractId).Await(),
				deadline = TenderData.CallRead("getContractDeadline", contractId).Await(),
			}
		});
	}

	string GetOrderState(int contractId, int orderId) {
		return ToJson(new {
			state = TenderData.CallRead("getOrderState", contractId, orderId).Await(),
			cancelledDate = TenderData.CallRead("getOrderCancelledDate", contractId, orderId).Await(),
			lastPenaltyDateCount = TenderData.CallRead("getLastPenaltyDateCount", contractId, orderId).Await(),
			orderPaid = (bool) TenderData.CallRead("getOrderPaid", contractId, orderId).Await(),
			attributes = new {
				small = TenderData.CallRead("getSmallServersDelivered", contractId, orderId).Await(),
				medium = TenderData.CallRead("getMediumServersDelivered", contractId, orderId).Await(),
				large = TenderData.CallRead("getLargeServersDelivered", contractId, orderId).Await(),
				maxSmall = TenderData.CallRead("getSmallServersOrdered", contractId, orderId).Await(),
				maxMedium = TenderData.CallRead("getMediumServersOrdered", contractId, orderId).Await(),
				maxLarge = TenderData.CallRead("getLargeServersOrdered", contractId, orderId).Await(),
				startDate = TenderData.CallRead("getOrderCreationDate", contractId, orderId).Await(),
				deadline = TenderData.CallRead("getOrderDeadline", contractId, orderId).Await(),
			}
		});
	}

	/*if (Environment.GetEnvironmentVariable("VERBOSE") != null)
		ShowFullReceipt = true;
	else if (Environment.GetEnvironmentVariable("SILENT") == null) {
		Console.Write("\nWould you like to show full receipt for every function call? y/N (default is N): ");
		switch (ConsoleExt.ReadLine(3000, "").Trim().ToLower()) {
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
	}*/

	Console.WriteLine("\nCalling TenderLogic.replaceTenderData(TenderData, false, false)...");
	ShowTransaction(TenderLogic.CallWrite("replaceTenderData", Wallet, TenderData, false, false));

	Console.WriteLine("\nCalling TenderLogic.createContract(123, ClientWallet, [10, 20, 30, 2, 1, 1555337743, 1655337743], [30, 30, 30])...");
	ShowTransaction(TenderLogic.CallWrite("createContract", Wallet, 123, ClientWallet,
		new BigInteger[] {
			10, 20, 30, //smallServerPrice, mediumServerPrice, largeServerPrice
			2, //penaltyPerDay
			1, //guaranteeRequired
			ContractUtil.Utc, //start date in UTC time
			ContractUtil.ToUtc(DateTime.UtcNow.AddYears(1)) //expiry date in UTC time
		}, new uint[] {
			30, 30, 30 //max small, medium, large
		}
	));

	Console.WriteLine("\nCalling TenderLogic.payGuarantee(ContractUtil.Utc, 123) with value 1 wei...");
	ShowTransaction(TenderLogic.CallWrite("payGuarantee", ClientWallet, ConfigParams.DefaultGas, ConfigParams.DefaultGasPrice, new HexBigInteger("0x1"), ContractUtil.Utc, 123));

	Console.WriteLine("\nCalling TenderLogic.createOrder(ContractUtil.Utc, 123, 12, 0, 3, 1, ContractUtil.Utc, ContractUtil.ToUtc(DateTime.UtcNow.AddYears(1)))...");
	//uint128 currentUtcDate, uint32 contractId, uint32 orderId, uint32 small, uint32 medium, uint32 large, uint128 startDate, uint128 deadline
	ShowTransaction(TenderLogic.CallWrite("createOrder", Wallet, ContractUtil.Utc, 123, 12, 0, 3, 1, ContractUtil.Utc, ContractUtil.ToUtc(DateTime.UtcNow.AddYears(1))));

	Console.WriteLine("\nReady!\n");
//} catch (Exception ex) {
//	ErrorHandler.Show("An error occurred while executing init-nethereum.csx", ex);
//}
