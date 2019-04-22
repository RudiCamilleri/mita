pragma solidity >=0.5.0;

//Version 0.1
//This interface serves to expose data layer functionality
interface TenderDataInterface {
	//Represents the current state of a legal contract
	enum ContractState {
		Expired,
		Active
	}

	//Represents the current state of an order
	enum OrderState {
		Pending,
		Delivered,
		Cancelled
	}

	struct Attributes {
		//Contract: current number of small servers ordered
		//Order: current number of small servers that arrived
		uint16 small;
		//Contract: current number of medium servers ordered
		//Order: current number of medium servers that arrived
		uint16 medium;
		//Contract: current number of large servers ordered
		//Order: current number of large servers that arrived
		uint16 large;
		//Contract: max number of small servers that can be ordered
		//Order: the number of small servers ordered
		uint16 maxSmall;
		//Contract: max number of medium servers that can be ordered
		//Order: the number of medium servers ordered
		uint16 maxMedium;
		//Contract: max number of medium servers that can be ordered
		//Order: the number of medium servers ordered
		uint16 maxLarge;
		//The deadline date in UTC time
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
		Attributes attr;
		uint128 smallServerPrice;
		uint128 mediumServerPrice;
		uint128 largeServerPrice;
		uint16 defaultDaysForDelivery;
		uint128 penaltyPerDay;
		uint128 expiryDate; //in UTC time
		uint32 operatorId;
		uint128 guaranteeRequired;
		mapping(uint32 => Order) orders;
	}

	//Sets or replaces the TenderLogic smart contract implementation
	function replaceTenderLogic(address newTenderLogicAddress) external;

	//Migrates the data from an old TenderData instance to a new one
	function migrateData(address oldTenderDataAddress) external;

	//Adds a business contract instance to the smart contract
	function addContract(address payable client, uint128[] calldata params128, uint32[] calldata params32, uint16[] calldata params16) external;

	//Adds a new order to the specified contract
	function addOrder(uint32 contractId, uint32 orderId, uint16 small, uint16 medium, uint16 large, uint128 orderDeadlineDate) external;

	//Sets the order state
	function setOrderState(uint32 contractId, uint32 orderId, OrderState newState) external;

	//Sets the order deadline
	function setOrderDeadline(uint32 contractId, uint32 orderId, uint128 newUtcDeadline) external;

	//Marks the contract as expired
	function markExpired(uint32 contractId) external;

	//Kills the service
	function endService(address payable targetWallet) external;

	//=============== PUBLIC READ-ONLY SECTION ====================
	function getClient(uint32 contractId) external view returns (address payable);
	function getContractState(uint32 contractId) external view returns (ContractState);
	function getSmallServerPrice(uint32 contractId) external view returns (uint128);
	function getMediumServerPrice(uint32 contractId) external view returns (uint128);
	function getLargeServerPrice(uint32 contractId) external view returns (uint128);
	function getDaysForDelivery(uint32 contractId) external view returns (uint16);
	function getPenaltyPerDay(uint32 contractId) external view returns (uint128);
	function getCreationDate(uint32 contractId) external view returns (uint128);
	function getExpiryDate(uint32 contractId) external view returns (uint128);
	function getOperatorId(uint32 contractId) external view returns (uint32);
	function getGuaranteeRequired(uint32 contractId) external view returns (uint128);

	function getOrderState(uint32 contractId, uint32 orderId) external view returns (OrderState);
	function getSmallServersOrdered(uint32 contractId, uint32 orderId) external view returns (uint16);
	function getMediumServersOrdered(uint32 contractId, uint32 orderId) external view returns (uint16);
	function getLargeServersOrdered(uint32 contractId, uint32 orderId) external view returns (uint16);
	function getOrderDeadline(uint32 contractId, uint32 orderId) external view returns (uint16);
}