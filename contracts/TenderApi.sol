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

	//passes refundable deposit.
	function topUpPerformanceGuarantee() external {
		return current.topUpPerformanceGuarantee();
	}

	//stops the contract if payment isnt made.
	function stopOrder(uint32 orderNumber, uint8 penalty) external {
		//uint32 - Order number, uint8 - Penalty to be taken
		return current.stopOrder(orderNumber, penalty);
	}

    //if order was delivered proceed
	function deliveryAcceptance(uint32 orderNumber, uint16 serverAmount) external {
		//uint32 - Order number, unit16 server amount as a whole
		return current.deliveryAcceptance(orderNumber, serverAmount);
	}

	//to confirm order is delivered
	function markDelivered(uint32 orderNumber) external {
		//uint32 - Order number
		return current.markDelivered(orderNumber);
	}

	//automatically accepts extension
	function defaultAcceptanceOfOrderDeadlineExtension(uint32 orderNumber) external {
		//uint32 - Order number
		return current.defaultAcceptanceOfOrderDeadlineExtension(orderNumber);
	}

	//to reject the extension
	function rejectOrderDeadlineExtension(uint32 orderNumber) external {
		//uint32 - Order number
		return current.rejectOrderDeadlineExtension(orderNumber);
	}

	//accepts deadline manually
	function acceptOrderDeadlineExtension(uint32 orderNumber, uint64 dateExtension) external {
		//uint32 - Order number, uint 64 is checking date of extension.
		return current.acceptOrderDeadlineExtension(orderNumber, dateExtension);
	}

	//requests an extension of a deadline
	function requestOrderDeadlineExtension(uint32 orderNumber,bytes32 reason, uint64 dateExtension ) external {
		//bytes 32 to store explanation //uint 64 is checking date of extension.
		return current.requestOrderDeadlineExtension(orderNumber, reason, dateExtension);
	}

	//cancels order
	function cancelOrder(uint32 orderNumber) external {
		//uint32 - Order number
		return current.cancelOrder(orderNumber);
	}

	//creates order
	function createOrder(uint32 orderNumber, uint16 serverAmount, bytes32 costDescription) external {
		//uint32 - Order number, uint16 server amoutn as a whole , bytes32 description of total price.
		return current.createOrder(orderNumber, serverAmount, costDescription);
	}
}