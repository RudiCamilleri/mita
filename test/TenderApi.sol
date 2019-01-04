pragma solidity ^0.4.24;

import "./TenderInterface.sol";

//Version 0.01
//This is the main contract that expose functionality to the public and handles versioning
//This is meant to be set in stone as much as possible after completion
contract TenderApi is TenderInterface {
	TenderInterface public current; //the current contract implementation
	address public owner; //the creator of the smart contract

	//Initializes the smart contract
	constructor() public {
		owner = msg.sender;
	}

	//Specifies the address of the current (latest) smart contract implementation
	function setCurrentAddress(address newAddress) public {
		require(msg.sender == owner); //function can only be called by the creator of the smart contract
		current = TenderInterface(newAddress); //cast contract to TenderInterface
	}

	//======================================================
	//== PUBLIC API FUNCTIONALITY IS TO BE INSERTED BELOW ==
	//======================================================

	function incrementValue() external returns (uint8) {
		return current.incrementValue();
	}
}