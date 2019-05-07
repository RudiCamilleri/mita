pragma solidity >=0.5.0;

//Version 0.1
//This interface serves to expose data layer functionality
interface ITenderData {
	//Represents the current state of a legal contract
	enum ContractState {
		Null, //not set
		Active, //the contract is active
		Expired, //the contract is marked as expired
		Terminated //the contract is terminated abnormally (possibly due to breach)
	}

	//Represents the current state of an order
	enum OrderState {
		Null, //not set
		Pending, //order is created and pending
		Delivered, //the order was fully delivered and accepted successfully
		Cancelled //the order was cancelled before the servers arrived fully, possibly a penalty was issued as well
	}

	//=============== PUBLIC READ-ONLY SECTION ====================
	//==================== Contract Data ==========================
	function getClient(uint32 contractId) external view returns (address payable);
	function getSmallServerPrice(uint32 contractId) external view returns (uint128);
	function getMediumServerPrice(uint32 contractId) external view returns (uint128);
	function getLargeServerPrice(uint32 contractId) external view returns (uint128);
	function getPenaltyPerDay(uint32 contractId) external view returns (uint128);
	function getGuaranteeRequired(uint32 contractId) external view returns (uint128);
	function getGuaranteePaid(uint32 contractId) external view returns (bool);
	function getClientPot(uint32 contractId) external view returns (uint256);
	function getContractState(uint32 contractId) external view returns (ContractState);
	function getTotalSmallServersOrdered(uint32 contractId) external view returns (uint32);
	function getTotalMediumServersOrdered(uint32 contractId) external view returns (uint32);
	function getTotalLargeServersOrdered(uint32 contractId) external view returns (uint32);
	function getMaxSmallServers(uint32 contractId) external view returns (uint32);
	function getMaxMediumServers(uint32 contractId) external view returns (uint32);
	function getMaxLargeServers(uint32 contractId) external view returns (uint32);
	function getContractStartDate(uint32 contractId) external view returns (uint128);
	function getContractDeadline(uint32 contractId) external view returns (uint128);
	//====================== Order Data ===========================
	function getOrderState(uint32 contractId, uint32 orderId) external view returns (OrderState);
	function getOrderCancelledDate(uint32 contractId, uint32 orderId) external view returns (uint128);
	function getOrderPaid(uint32 contractId, uint32 orderId) external view returns (bool);
	function getSmallServersDelivered(uint32 contractId, uint32 orderId) external view returns (uint32);
	function getMediumServersDelivered(uint32 contractId, uint32 orderId) external view returns (uint32);
	function getLargeServersDelivered(uint32 contractId, uint32 orderId) external view returns (uint32);
	function getSmallServersOrdered(uint32 contractId, uint32 orderId) external view returns (uint32);
	function getMediumServersOrdered(uint32 contractId, uint32 orderId) external view returns (uint32);
	function getLargeServersOrdered(uint32 contractId, uint32 orderId) external view returns (uint32);
	function getOrderCreationDate(uint32 contractId, uint32 orderId) external view returns (uint128);
	function getOrderDeadline(uint32 contractId, uint32 orderId) external view returns (uint128);

	//===================== DATA SECTION ==========================
	//Sets or replaces the TenderLogic smart contract implementation
	function replaceTenderLogic(address newTenderLogicAddress) external;

	//Migrates the data from an old TenderData instance to a new one
	function migrateData(address oldTenderDataAddress) external;

	//Adds a business contract instance to the smart contract
	function addContract(uint32 contractId, address payable client, uint128[] calldata params128, uint32[] calldata params32) external;

	//Sets the total number of servers ordered so far for the specified contract
	function setTotalServersOrdered(uint32 contractId, uint32 small, uint32 medium, uint32 large) external;

	//Sets the total number of servers delivered so far for the specified order
	function setTotalServersDelivered(uint32 contractId, uint32 orderId, uint32 small, uint32 medium, uint32 large) external;

	//Sets the contract client address
	function setClient(uint32 contractId, address payable newClient) external;

	//Sets the guarantee as paid
	function setGuaranteePaid(uint32 contractId) external;

	//Sets the balance of the client pot to the specified amount
	function setClientPot(uint32 contractId, uint256 newValue) external;

	//Sets the contract deadline
	function setContractDeadline(uint32 contractId, uint128 newUtcDeadline) external;

	//Sets the contract state
	function setContractState(uint32 contractId, ContractState newState) external;

	//Adds a new order to the specified contract
	function addOrder(uint32 contractId, uint32 orderId, uint32 small, uint32 medium, uint32 large, uint128 startDate, uint128 deadline) external;

	//Sets the maximum server quantities for the specified contract
	function setContractMax(uint32 contractId, uint32 maxSmall, uint32 maxMedium, uint32 maxLarge) external;

	//Sets the order deadline
	function setOrderDeadline(uint32 contractId, uint32 orderId, uint128 newUtcDeadline) external;

	//Sets the order state
	function setOrderState(uint32 contractId, uint32 orderId, OrderState newState) external;

	//Sets whether the order was paid
	function setOrderPaid(uint32 contractId, uint32 orderId, bool paid) external;

	function setOrderCancelledDate(uint32 contractId, uint32 orderId, uint128 cancelledDate) external;

	//Kills the current TenderData contract and transfers its Ether to the owner
	function destroyTenderData(address payable targetWallet) external;
}