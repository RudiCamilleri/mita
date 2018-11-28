pragma solidity ^0.5.0;

import "./TenderInterface.sol";

//Version 0.1
//This is the contract functionality implementation
//This contract is upgradeable as long as it keeps the same TenderInterface implementation
contract Tender is TenderInterface {
	address public owner; //the TenderApi smart contract instance
	uint8 public value;

	//Initializes the smart contract
	constructor(address apiAddress, uint8 initialValue) public {
		owner = apiAddress;
		value = initialValue;
	}

	//Makes sure that the function can only be called by TenderApi instance
	modifier restricted() {
		require(msg.sender == owner);
		_;
	}

	//=======================================================
	//== FUNCTION IMPLEMENTATIONS ARE TO BE INSERTED BELOW ==
	//==    ALL FUNCTIONS MUST BE MARKED AS RESTRICTED!    ==
	//=======================================================

	function incrementValue() public restricted returns (uint8) {
		return ++value;
	}
}