//This file deploys the smart contracts to the network

//Load smart contracts for deployment
var TenderAPIAbi = artifacts.require("./TenderAPI.sol");
var TenderBLLAbi = artifacts.require("./TenderBLL.sol");
var TenderDataAbi = artifacts.require("./TenderData.sol");

module.exports = function(deployer) {
	deployer.deploy(TenderAPIAbi).then(function() { //call constructor of TenderAPI, then
		deployer.deploy(TenderBLLAbi, TenderAPIAbi.address).then(function() { //call constructor of TenderBLL, then
			deployer.deploy(TenderDataAbi, TenderBLLAbi.address); //call constructor of TenderData
		});
	});
};