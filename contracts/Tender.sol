pragma solidity ^0.5.0;

import "./TenderInterface.sol";

//Version 0.01
//This is the contract functionality implementation
//This contract is upgradeable as long as it keeps the same TenderInterface implementation
contract Tender is TenderInterface {
	address payable public owner; //the TenderApi smart contract instance
	uint256 public smallServerPrice;
	uint256 public mediumServerPrice;
	uint256 public largeServerPrice;
	uint16 public min;
	uint16 public max;
	uint16 public daysForDelivery;
	uint256 public penaltyPerDay;
	uint256 public penaltyCap;
	uint256 public maximumCostofExtras;
	uint64 public expiryDate;
	bytes8 public operatorId;
	uint256 public guaranteeRequired;

	//Initializes the smart contract
	constructor(address payable apiAddress,
		uint256 smallServerPrice, uint256 mediumServerPrice, uint256 largeServerPrice,
		uint16 min, uint16 max, uint16 daysForDelivery, uint256 penaltyPerDay, uint256 penaltyCap,
		uint256 maximumCostofExtras, uint64 expiryDate, bytes8 operatorId, uint256 guaranteeRequired) public {
		owner = apiAddress;
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

	function endContract() public restricted {
		selfdestruct(owner);
	}

	/*function incrementValue() public restricted returns (uint8) {
		return ++value;
	}*/
}