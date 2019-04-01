console.log("\nDeploying TenderAPI contract...");
web3.eth.defaultAccount = web3.eth.accounts[0];
loadScript("./build/contracts/TenderAPI.js");
var TenderAPIAbi = web3.eth.contract(TenderAPIBuild.abi);
var TenderAPIInit = TenderApiAbi.new([], { from: web3.eth.defaultAccount, data: TenderAPIAbi.bytecode, gas: 2000000}, function(e, contract) {
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

console.log("deploy-tenderapi.js execution successful:");