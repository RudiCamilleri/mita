pragma solidity >=0.5.6;

//Version 0.1
//This interface serves to expose and document main contract functionality
//This is meant to be set in stone as much as possible after completion
interface TenderInterface {
	struct OrderContract {
		uint32 orderId;
		uint16 small; //small servers ordered
		uint16 medium; //medium servers ordered
		uint16 large; //large servers ordered
	}

	struct TenderContract {
		uint32 contractId;
		uint128 smallServerPrice;
		uint128 mediumServerPrice;
		uint128 largeServerPrice;
		uint16 daysForDelivery;
		uint128 penaltyPerDay;
		uint128 creationDate;
		uint128 expiryDate;
		uint32 operatorId;
		uint128 guaranteeRequired;
		mapping(uint32 => OrderContract) orders;
	}

	//Specifies the address of the TenderData smart contract implementation
	function setDataAddress(address newAddress) external;

	//Creates a contract instance
	function createContract(uint128[] calldata params128, uint32[] calldata params32, uint16[] calldata params16) external;

	//Ends the contract
	function endContract(uint32 contractId) external;

	//Kills the service
	function endService() external;
	/*
	//passes refundable deposit
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