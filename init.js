console.log("\nInitalizing Web3 console environment... ");
web3.eth.defaultAccount = web3.eth.accounts[0];

console.log("Initalizing TenderAPI object...");
loadScript("./init-tenderapi-address.js");
loadScript("./build/contracts/TenderAPI.js");
var TenderAPIAbi = web3.eth.contract(TenderAPIBuild.abi);
var TenderAPI = TenderAPIAbi.at(TenderAPIAddress);

console.log("Initalizing TenderBLL object...");
loadScript("./init-tenderbll-address.js");
loadScript("./build/contracts/TenderBLL.js");
var TenderBLLAbi = web3.eth.contract(TenderBLLBuild.abi);
var TenderBLL = TenderBLLAbi.at(TenderBLLAddress);

TenderAPI.setCurrentAddress(TenderBLL.address);

console.log("init.js execution completed\n");