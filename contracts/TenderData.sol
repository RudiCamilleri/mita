pragma solidity >=0.5.0;

import "./TenderDataInterface.sol";

//Version 0.01
//This is the contract data wrapper
contract TenderData {
	address payable public owner; //the Tender smart contract instance
	mapping(uint32 => TenderDataInterface.TenderContract) public contracts; //the contract that are represented in this instance

	//Initializes the smart contract
	constructor(address payable tenderAddress) public {
		owner = tenderAddress;
	}

	//Makes sure that the function can only be called by Tender instance
	modifier restricted() {
		require(msg.sender == owner);
		_;
	}

	//=======================================================
	//== FUNCTION IMPLEMENTATIONS ARE TO BE INSERTED BELOW ==
	//==    ALL FUNCTIONS MUST BE MARKED AS RESTRICTED!    ==
	//=======================================================
	//
	//Functions that are used in the smart contract itself and are to be exported should be marked as public,
	//whereas functions that are only called from outside should be marked as external

	//Adds the contract to the contracts dictionary a contract instance (should be changed to external when compiler support starts to exist)
	function addContract(uint128[] calldata params128, uint32[] calldata params32, uint16[] calldata params16) external restricted {
		contracts[params32[0]] = TenderDataInterface.TenderContract({
			contractId: params32[0],
			smallServerPrice: params128[0],
			mediumServerPrice: params128[1],
			largeServerPrice: params128[2],
			daysForDelivery: params16[0],
			penaltyPerDay: params128[3],
			creationDate: params128[4],
			expiryDate: params128[5],
			operatorId: params32[1],
			guaranteeRequired: params128[6]
		});
	}

	//Transfers ownership to the specified Tender smart contract owner
	function changeDataOwner(address payable newTenderOwner) external restricted {
		owner = newTenderOwner;
	}

	//Migrates the data from an old TenderData instance to a new one
	//Comment out "view" if to be implemented
	function migrateData(address oldData) view external restricted {
	}

	//Marks the contract as ended
	function markEnded(uint32 contractId) external restricted {
		//delete contracts[contractId];
	}

	//Kills the service
	function endService() external restricted {
		selfdestruct(owner);
	}
}