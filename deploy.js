//Loading TenderApi contract
loadScript("./build/contracts/TenderApi.js");
var TenderApiAbi = web3.eth.contract(TenderApiBuild.abi);
var TenderApi = TenderApiAbi.new({from: eth.coinbase, data: TenderApiAbi.bytecode, gas: 1000000});

//Loading Tender contract (requires constructor values)
loadScript("./build/contracts/Tender.js");
var TenderAbi = web3.eth.contract(TenderBuild.abi);
var Tender = TenderAbi.new({from: eth.coinbase, data: TenderAbi.bytecode, gas: 1000000});