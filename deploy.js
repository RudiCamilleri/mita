var Tender = json object
var Tender2 = web3.eth.contract(Tender.abi);
var Tender3 = Tender2.new({from:eth.coinbase, data: Tender2.bytecode, gas: 1000000});