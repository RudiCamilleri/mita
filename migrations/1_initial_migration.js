//This file serves as glue code for truffle to work.
//DO NOT MODIFY THE CODE BELOW
var Migrations = artifacts.require("./Migrations.sol");

module.exports = function(deployer) {
	deployer.deploy(Migrations);
};