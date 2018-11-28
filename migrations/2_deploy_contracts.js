//This file deploys the smart contracts to the network

//Load smart contracts for deployment
var TenderApi = artifacts.require("./TenderApi.sol");
var Tender = artifacts.require("./Tender.sol");

module.exports = function(deployer) {
	deployer.deploy(TenderApi).then(function() { //call constructor of TenderApi, then
		deployer.deploy(Tender, TenderApi.address, 3); //call constructor of Tender
	});
};