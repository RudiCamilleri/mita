console.log("\nObtaining address of TenderApi contract...");
loadScript("./init-tenderapi-address.js");

console.log("\nDeploying Tender contract...");
web3.eth.defaultAccount = web3.eth.accounts[0];
loadScript("./build/contracts/Tender.js");
var TenderAbi = web3.eth.contract(TenderBuild.abi);
var TenderInit = TenderAbi.new([TenderApiAddress, 3], { from: web3.eth.defaultAccount, data: TenderAbi.bytecode, gas: 2000000}, function(e, contract) {
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

console.log("deploy-tender.js execution successful:");