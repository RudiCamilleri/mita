//Load smart contracts for deployment
var TenderAPIAbi = artifacts.require("./TenderAPI.sol");
var TenderBLLAbi = artifacts.require("./TenderBLL.sol");
var TenderDataAbi = artifacts.require("./TenderData.sol");

contract("TenderAPI", accounts => {
	it("All contracts loaded properly", () => {
		TenderAPIAbi.deployed().then(a=>{TenderAPI=a;TenderBLLAbi.deployed().then(t=>{TenderBLL=t;TenderAPI.replaceTenderBLL(TenderBLLAbi.address)})});
	});
});