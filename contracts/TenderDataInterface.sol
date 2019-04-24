pragma solidity >=0.5.0;

//Version 0.1
//This interface serves to expose data layer functionality
interface TenderDataInterface {
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
		BeingDelivered, //order servers are being delivered (ie. one or more servers was already delivered and accepted)
		PartiallyDelivered, //deadline reached before all of the order was delivered and accepted
		Delivered, //the order was delivered and accepted successfully
		Cancelled //the order was cancelled, and possibly a penalty was issued
	}

	struct Attributes {
		//Contract: current number of small servers ordered
		//Order: current number of small servers that arrived
		uint32 small;
		//Contract: current number of medium servers ordered
		//Order: current number of medium servers that arrived
		uint32 medium;
		//Contract: current number of large servers ordered
		//Order: current number of large servers that arrived
		uint32 large;
		//Contract: max number of small servers that can be ordered
		//Order: the number of small servers ordered
		uint32 maxSmall;
		//Contract: max number of medium servers that can be ordered
		//Order: the number of medium servers ordered
		uint32 maxMedium;
		//Contract: max number of medium servers that can be ordered
		//Order: the number of medium servers ordered
		uint32 maxLarge;
		//Contract: the contract expiry date in UTC time
		//Order: the order deadline in UTC time
		uint128 deadline;
	}

	//Defines an order for a contract
	struct Order {
		OrderState state;
		Attributes attr;
	}

	//Defines a legal contract instance
	struct Contract {
		address payable client;
		ContractState state;
		uint128 smallServerPrice;
		uint128 mediumServerPrice;
		uint128 largeServerPrice;
		uint128 penaltyPerDay;
		uint128 guaranteeRequired;
		Attributes attr;
		mapping(uint32 => Order) orders;
	}

	//=============== PUBLIC READ-ONLY SECTION ====================
	//==================== Contract Data ==========================
	function getClient(uint32 contractId) external view returns (address payable);
	function getSmallServerPrice(uint32 contractId) external view returns (uint128);
	function getMediumServerPrice(uint32 contractId) external view returns (uint128);
	function getLargeServerPrice(uint32 contractId) external view returns (uint128);
	function getPenaltyPerDay(uint32 contractId) external view returns (uint128);
	function getOperatorId(uint32 contractId) external view returns (uint32);
	function getGuaranteeRequired(uint32 contractId) external view returns (uint128);
	function getContractState(uint32 contractId) external view returns (ContractState);
	function getTotalSmallServersOrdered(uint32 contractId) external view returns (uint32);
	function getTotalMediumServersOrdered(uint32 contractId) external view returns (uint32);
	function getTotalLargeServersOrdered(uint32 contractId) external view returns (uint32);
	function getMaxSmallServers(uint32 contractId) external view returns (uint32);
	function getMaxMediumServers(uint32 contractId) external view returns (uint32);
	function getMaxLargeServers(uint32 contractId) external view returns (uint32);
	function getContractDeadline(uint32 contractId) external view returns (uint128);
	//====================== Order Data ===========================
	function getOrderState(uint32 contractId, uint32 orderId) external view returns (OrderState);
	function getSmallServersDelivered(uint32 contractId, uint32 orderId) external view returns (uint32);
	function getMediumServersDelivered(uint32 contractId, uint32 orderId) external view returns (uint32);
	function getLargeServersDelivered(uint32 contractId, uint32 orderId) external view returns (uint32);
	function getSmallServersOrdered(uint32 contractId, uint32 orderId) external view returns (uint32);
	function getMediumServersOrdered(uint32 contractId, uint32 orderId) external view returns (uint32);
	function getLargeServersOrdered(uint32 contractId, uint32 orderId) external view returns (uint32);
	function getOrderDeadline(uint32 contractId, uint32 orderId) external view returns (uint128);

	//===================== DATA SECTION ==========================
	//Sets or replaces the TenderLogic smart contract implementation
	function replaceTenderLogic(address newTenderLogicAddress) external;

	//Migrates the data from an old TenderData instance to a new one
	function migrateData(address oldTenderDataAddress) external;

	//Adds a business contract instance to the smart contract
	function addContract(uint32 contractId, address payable client, uint128[] calldata params128, uint32[] calldata params32) external;

	//Sets the contract deadline
	function setContractDeadline(uint32 contractId, uint128 newUtcDeadline) external;

	//Sets the contract state
	function setContractState(uint32 contractId, ContractState newState) external;

	//Adds a new order to the specified contract
	function addOrder(uint32 contractId, uint32 orderId, uint128[] calldata params128, uint32[] calldata params32) external;

	//Sets the order deadline
	function setOrderDeadline(uint32 contractId, uint32 orderId, uint128 newUtcDeadline) external;

	//Sets the order state
	function setOrderState(uint32 contractId, uint32 orderId, OrderState newState) external;

	//Kills the service
	function endService(address payable targetWallet) external;
}