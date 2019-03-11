pragma solidity ^0.5.0;

import "./TenderInterface.sol";

//Version 0.1
//This is the main contract that expose functionality to the public and handles versioning
//This is meant to be set in stone as much as possible after completion
contract TenderApi is TenderInterface {
	TenderInterface public current; //the current contract implementation
	address payable public owner; //the creator of the smart contract

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

	//Ends the contract
	function endContract() external {
		current.endContract();
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