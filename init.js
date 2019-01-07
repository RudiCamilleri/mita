console.log("\nInitalizing Web3 console environment... ");
web3.eth.defaultAccount = web3.eth.accounts[0];

console.log("Initalizing TenderApi object...");
loadScript("./init-tenderapi-address.js");
loadScript("./build/contracts/TenderApi.js");
var TenderApiAbi = web3.eth.contract(TenderApiBuild.abi);
var TenderApi = TenderApiAbi.at(TenderApiAddress);

console.log("Initalizing Tender object...");
loadScript("./init-tender-address.js");
loadScript("./build/contracts/Tender.js");
var TenderAbi = web3.eth.contract(TenderBuild.abi);
var Tender = TenderAbi.at(TenderAddress);

TenderApi.setCurrentAddress(Tender.address);

console.log("init.js execution completed\n");