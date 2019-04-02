//This file deploys the smart contracts to the network

//Load smart contracts for deployment
TenderAPIAbi = artifacts.require("./TenderAPI.sol");
TenderBLLAbi = artifacts.require("./TenderBLL.sol");
TenderDataAbi = artifacts.require("./TenderData.sol");
TenderAPI = null;
TenderBLL = null;
TenderData = null;

module.exports = function(deployer) {
	deployer.deploy(TenderAPIAbi).then(function(tenderAPI) { //call constructor of TenderAPI, then
		TenderAPI = tenderAPI;
		deployer.deploy(TenderBLLAbi, TenderAPI.address).then(function(tenderBLL) { //call constructor of TenderBLL, then
			TenderBLL = tenderBLL;
			deployer.deploy(TenderDataAbi, tenderBLL.address).then(function(tenderData) { //call constructor of TenderData
				TenderData = tenderData;
			}); 
		});
	});
};