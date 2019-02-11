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
	constructor(address payable _apiAddress,
		uint256 _smallServerPrice, uint256 _mediumServerPrice, uint256 _largeServerPrice,
		uint16 _min, uint16 _max, uint16 _daysForDelivery, uint256 _penaltyPerDay, uint256 _penaltyCap,
		uint256 _maximumCostofExtras, uint64 _expiryDate, bytes8 _operatorId, uint256 _guaranteeRequired) public {
		owner = _apiAddress;
		_smallServerPrice = smallServerPrice;
		_mediumServerPrice = mediumServerPrice;
		_largeServerPrice = largeServerPrice;
		_min = min;
		_max = max;
		_daysForDelivery = daysForDelivery;
		_penaltyPerDay = penaltyPerDay;
		_penaltyCap = penaltyCap;
		_maximumCostofExtras = maximumCostofExtras;
		_expiryDate = expiryDate;
		_operatorId = operatorId;
		_guaranteeRequired = guaranteeRequired;
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