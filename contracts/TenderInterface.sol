pragma solidity ^0.5.0;

//Version 0.1
//This interface serves to expose and document main contract functionality
//This is meant to be set in stone as much as possible after completion
interface TenderInterface {
	//Increments value
	function incrementValue() external returns (uint8);
	//Ends the contract
	function endContract() external;
	//passes refundable deposit.
	function topUpPerformanceGuarantee() external;
	//stops the contract if payment isnt made.
	function stopOrder(uint32 orderNumber, uint8 penalty) external; // uint32 - Order number, uint8 - Penalty to be taken
    //if order was delivered proceed
	function deliveryAcceptance(uint32 orderNumber, uint16 serverAmount) external; // uint32 - Order number, unit16 server amount as a whole
	//to confirm order is delivered
	function markDelivered(uint32 orderNumber) external; // uint32 - Order number
	//automatically accepts extension
	function defaultAcceptanceOfOrderDeadlineExtension(uint32 orderNumber) external; // uint32 - Order number
	//to reject the extension
	function rejectOrderDeadlineExtension(uint32 orderNumber) external; // uint32 - Order number
	//accepts deadline manually
	function acceptOrderDeadlineExtension(uint32 orderNumber, uint64 dateExtension) external; // uint32 - Order number, uint 64 is checking date of extension.
	//requests an extension of a deadline
	function requestOrderDeadlineExtension(uint32 orderNumber,bytes32 reason, uint64 dateExtension ) external;//bytes 32 to store explanation //uint 64 is checking date of extension.
	//cancels order
	function cancelOrder(uint32 orderNumber) external; // uint32 - Order number
	//creates order
	function createOrder(uint32 orderNumber, uint16 serverAmount, bytes32 costDescription) external; // uint32 - Order number, uint16 server amoutn as a whole , bytes32 description of total price.
	function acceptContract() external;



	

}