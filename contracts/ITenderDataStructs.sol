pragma solidity >=0.5.0;

import "./ITenderData.sol";

//Version 0.1
//This interface serves to contain the definitions of the data structures that are used solely by the internals of TenderData.
//The only reason these structs are not placed within the TenderData smart contract itself is to make the code more organized.
interface ITenderDataStructs {
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
		//Contract: the start date of the contract
		//Order: the creation date of the order
		uint128 startDate;
		//Contract: the contract expiry date in UTC time
		//Order: the order deadline in UTC time
		uint128 deadline;
	}

	//Defines a legal contract instance
	struct Contract {
		address payable client; //the address of the client
		ITenderData.ContractState state; //the current state of the contract
		uint128 smallServerPrice; //the stipulated price of a small server
		uint128 mediumServerPrice; //the stipulated price of a medium server
		uint128 largeServerPrice; //the stipulated price of a large server
		uint128 penaltyPerDay; //the penalty required per day overdue of an order deadline
		uint128 guaranteeRequired; //the performance guarantee required from the client
		uint256 clientGuaranteeBalance; //the client's current performance guarantee balance
		uint256 clientPenaltyBalance; //the client's current penalty balance
		bool guaranteePaid; //whether the performance guarantee was paid
		Attributes attr; //common attributes
		mapping(uint32 => Order) orders; //the orders that were made for a contract
	}

	//Defines an order for a contract
	struct Order {
		ITenderData.OrderState state; //the current state of the order
		uint128 cancelledDate; //the UTC date when the order was cancelled (used for penalty calculations)
		uint128 lastPenaltyDateCount; ///the last number of days overdue at which the penalty was affected
		bool orderPaid; //whether the order was already paid
		Attributes attr; //common attributes
	}
}