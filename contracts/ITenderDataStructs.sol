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

	//Defines an order for a contract
	struct Order {
		ITenderData.OrderState state;
		Attributes attr;
	}

	//Defines a legal contract instance
	struct Contract {
		address payable client;
		ITenderData.ContractState state;
		uint128 smallServerPrice;
		uint128 mediumServerPrice;
		uint128 largeServerPrice;
		uint128 penaltyPerDay;
		uint128 guaranteeRequired;
		uint256 clientPot;
		bool guaranteePaid;
		Attributes attr;
		mapping(uint32 => Order) orders;
	}
}