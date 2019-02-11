#r "nuget: Nethereum.Web3"
using System;
using System.Threading.Tasks;
using Nethereum.Web3;
var web3 = new Web3("http://localhost:8545");
Console.WriteLine("'web3' object now loaded");
