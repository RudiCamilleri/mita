//This file deploys the smart contracts to the network

//Load smart contracts for deployment
TenderLogicAbi = artifacts.require("./TenderLogic.sol");
TenderDataAbi = artifacts.require("./TenderData.sol");
TenderLogic = null;
TenderData = null;

module.exports = function(deployer) {
	deployer.deploy(TenderLogicAbi).then(function(tenderLogic) { //call constructor of TenderLogic, then
		TenderLogic = tenderLogic;
		deployer.deploy(TenderDataAbi, tenderLogic.address).then(function(tenderData) { //call constructor of TenderData
			TenderData = tenderData;
		}); 
	});
}