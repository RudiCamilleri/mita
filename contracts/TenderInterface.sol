pragma solidity ^0.5.0;

//Version 0.1
//This interface serves to expose and document main contract functionality
//This is meant to be set in stone as much as possible after completion
interface TenderInterface {
	//Ends the contract
	function endContract() external;
	/*//passes refundable deposit
	function topUpPerformanceGuarantee() external;
	//stops the contract if payment isnt made.
	function stopOrder(uint32 _orderNumber, uint8 _penalty) external; //uint32 - Order number, uint8 - Penalty to be taken
    //if order was delivered proceed
	function deliveryAcceptance(uint32 _orderNumber, uint16 _serverAmount) external; //uint32 - Order number, unit16 server amount as a whole
	//to confirm order is delivered
	function markDelivered(uint32 _orderNumber) external; //uint32 - Order number
	//automatically accepts extension
	function defaultAcceptanceOfOrderDeadlineExtension(uint32 _orderNumber) external; //uint32 - Order number
	//to reject the extension
	function rejectOrderDeadlineExtension(uint32 _orderNumber) external; //uint32 - Order number
	//accepts deadline manually
	function acceptOrderDeadlineExtension(uint32 _orderNumber, uint64 _dateExtension) external; //uint32 - Order number, uint 64 is checking date of extension
	//requests an extension of a deadline
	function requestOrderDeadlineExtension(uint32 _orderNumber, bytes32 _reason, uint64 _dateExtension) external; //bytes 32 to store explanation, uint 64 is checking date of extension
	//cancels orders
	function cancelOrder(uint32 _orderNumber) external; //uint32 - Order number
	//creates order
	function createOrder(uint32 _orderNumber, uint16 _serverAmount, bytes32 _costDescription) external; //uint32 - Order number, uint16 server amount as a whole, bytes32 description of total price
	*/
}