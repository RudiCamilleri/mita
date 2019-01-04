console.log("Running deploy.js...");
web3.eth.defaultAccount = web3.eth.accounts[0];

console.log("Deploying TenderApi contract...");
loadScript("./build/contracts/TenderApi.js");
var TenderApiAbi = web3.eth.contract(TenderApiBuild.abi);
var TenderApi = TenderApiAbi.new([], { from: web3.eth.defaultAccount, data: TenderApiAbi.bytecode, gas: 2000000}, function(e, contract) {
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

/*console.log("Deploying Tender contract...");
loadScript("./build/contracts/Tender.js");
var TenderAbi = web3.eth.contract(TenderBuild.abi);
var Tender = TenderAbi.new(['Rama','Nick','Jose'], { from: web3.eth.defaultAccount, data: TenderAbi.bytecode, gas: 2000000}, function(e, contract) {
	if (!e) {
		if(!contract.address)
			console.log("TransactionHash: " + contract.transactionHash + " waiting to be mined...");
		else {
			console.log("Contract mined! Address: " + contract.address);
			console.log(contract);
		}
	} else
		console.log(e);
});*/

//TenderApi.setCurrentAddress(Tender.address);

console.log("deploy.js execution completed\n");