console.log("\nObtaining address of TenderAPI contract...");
loadScript("./init-tenderapi-address.js");

console.log("\nDeploying TenderBLL contract...");
web3.eth.defaultAccount = web3.eth.accounts[0];
loadScript("./build/contracts/TenderBLL.js");
var TenderBLLAbi = web3.eth.contract(TenderBLLBuild.abi);
var TenderBLLInit = TenderBLLAbi.new([TenderAPIAddress, 3], { from: web3.eth.defaultAccount, data: TenderABI.bytecode, gas: 2000000}, function(e, contract) {
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

console.log("deploy-tenderbll.js execution successful:");