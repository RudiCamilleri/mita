console.log("Running deploy.js...");
if (typeof web3 === 'undefined')
	web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
else
	web3 = new Web3(web3.currentProvider);
web3.eth.defaultAccount = web3.eth.accounts[0];

console.log("Deploying TenderApi contract...");
loadScript("./build/contracts/TenderApi.js");
var TenderApiAbi = web3.eth.contract(TenderApiBuild.abi);
var TenderApi = TenderApiAbi.new(TenderApiAbi, {from: eth.coinbase, data: TenderApiAbi.bytecode, gas: 2000000}, function(e, contract) {
	if (!e) {
		if (!contract.address)
			console.log("TransactionHash: " + contract.transactionHash + " waiting to be mined...");
		else {
			console.log("Contract mined! Address: " + contract.address);
			console.log(contract);
		}
	} else
		console.log(e);
});

console.log("Deploying Tender contract...");
loadScript("./build/contracts/Tender.js");
var TenderAbi = web3.eth.contract(TenderBuild.abi);
var Tender = TenderAbi.new({from: eth.coinbase, data: TenderAbi.bytecode, gas: 2000000}, function(e, contract) {
	if (!e) {
		if(!contract.address)
			console.log("TransactionHash: " + contract.transactionHash + " waiting to be mined...");
		else {
			console.log("Contract mined! Address: " + contract.address);
			console.log(contract);
		}
	} else
		console.log(e);
});

console.log("deploy.js execution completed\n");