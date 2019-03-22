pragma solidity >=0.5.0;

import "./TenderInterface.sol";

//Version 0.1
//This is the main contract that expose functionality to the public and handles versioning
//This is meant to be set in stone as much as possible after completion
contract TenderApi is TenderInterface {
	address payable public owner; //the creator of the smart contract
	TenderInterface public current; //the current contract implementation

	//Initializes the smart contract
	constructor() public {
		owner = msg.sender;
	}

	//Makes sure that the function can only be called by TenderApi instance
	modifier restricted() {
		require(msg.sender == owner);
		_;
	}

	//Specifies the address of the Tender smart contract implementation
	function setTenderAddress(address payable tenderAddress, bool killOldTender) external restricted {
		require(address(current) != tenderAddress);
		if (address(current) != address(0))
			current.changeDataOwner(tenderAddress, killOldTender);
		current = TenderInterface(tenderAddress); //cast contract to TenderInterface
	}

	//Specifies the address of the TenderData smart contract implementation
	function setDataAddress(address dataAddress, bool migrateOldData, bool killOldData) external restricted {
		current.setDataAddress(dataAddress, migrateOldData, killOldData);
	}

	//Transfers ownership to the specified Tender smart contract owner
	function changeDataOwner(address payable newTenderOwner) view external restricted {
		require(false);
	}

	//======================================================
	//== PUBLIC API FUNCTIONALITY IS TO BE INSERTED BELOW ==
	//======================================================

	//Creates a contract instance
	function createContract(uint128[] calldata params128, uint32[] calldata params32, uint16[] calldata params16) external {
		current.createContract(params128, params32, params16);
	}

	//Ends the contract
	function endContract(uint32 contractId) external {
		current.endContract(contractId);
	}

	//Kills the service
	function endService() external {
		current.endService();
		selfdestruct(owner);
	}

	/*//passes refundable deposit.
	function topUpPerformanceGuarantee() external {
		return current.topUpPerformanceGuarantee();
	}

	//stops the contract if payment isnt made.
	function stopOrder(uint32 _orderNumber, uint8 _penalty) external {
		//uint32 - Order number, uint8 - Penalty to be taken
		return current.stopOrder(_orderNumber, _penalty);
	}

    //if order was delivered proceed
	function deliveryAcceptance(uint32 _orderNumber, uint16 _serverAmount) external {
		//uint32 - Order number, unit16 server amount as a whole
		return current.deliveryAcceptance(_orderNumber, _serverAmount);
	}

	//to confirm order is delivered
	function markDelivered(uint32 _orderNumber) external {
		//uint32 - Order number
		return current.markDelivered(_orderNumber);
	}

	//automatically accepts extension
	function defaultAcceptanceOfOrderDeadlineExtension(uint32 _orderNumber) external {
		//uint32 - Order number
		return current.defaultAcceptanceOfOrderDeadlineExtension(_orderNumber);
	}

	//to reject the extension
	function rejectOrderDeadlineExtension(uint32 _orderNumber) external {
		//uint32 - Order number
		return current.rejectOrderDeadlineExtension(_orderNumber);
	}

	//accepts deadline manually
	function acceptOrderDeadlineExtension(uint32 _orderNumber, uint64 _dateExtension) external {
		//uint32 - Order number, uint 64 is checking date of extension.
		return current.acceptOrderDeadlineExtension(_orderNumber, _dateExtension);
	}

	//requests an extension of a deadline
	function requestOrderDeadlineExtension(uint32 _orderNumber, bytes32 _reason, uint64 _dateExtension) external {
		//bytes 32 to store explanation //uint 64 is checking date of extension.
		return current.requestOrderDeadlineExtension(_orderNumber, _reason, _dateExtension);
	}

	//cancels order
	function cancelOrder(uint32 _orderNumber) external {
		//uint32 - Order number
		return current.cancelOrder(_orderNumber);
	}

	//creates order
	function createOrder(uint32 _orderNumber, uint16 _serverAmount, bytes32 _costDescription) external {
		//uint32 - Order number, uint16 server amoutn as a whole , bytes32 description of total price.
		return current.createOrder(_orderNumber, _serverAmount, _costDescription);
	}*/
}