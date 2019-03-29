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

	//Defines an order for a contract
	struct Order {
		uint32 orderId;
		OrderState state;
		uint16 small; //small servers ordered
		uint16 medium; //medium servers ordered
		uint16 large; //large servers ordered
	}

	//Defines a legal contract instance
	struct TenderContract {
		uint32 contractId;
		ContractState state;
		uint128 smallServerPrice;
		uint128 mediumServerPrice;
		uint128 largeServerPrice;
		uint16 daysForDelivery;
		uint128 penaltyPerDay;
		uint128 creationDate;
		uint128 expiryDate;
		uint32 operatorId;
		uint128 guaranteeRequired;
		mapping(uint32 => Order) orders;
	}

	//Adds the contract to the contracts dictionary a contract instance (should be changed to external when compiler support starts to exist)
	function addContract(uint128[] calldata params128, uint32[] calldata params32, uint16[] calldata params16) external;

	//Sets or replaces the TenderBLLInterface smart contract implementation
	function replaceTenderBLL(address newTenderBLLAddress) external;

	//Migrates the data from an old TenderData instance to a new one
	function migrateData(address oldTenderDataAddress) external;

	//Marks the contract as ended
	function markEnded(uint32 contractId) external;

	//Kills the service
	function endService(address payable targetWallet) external;
}