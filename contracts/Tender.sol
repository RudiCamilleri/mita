pragma solidity >=0.5.6;

import "./TenderInterface.sol";
import "./TenderData.sol";

//Version 0.01
//This is the contract functionality implementation
//This contract is upgradeable as long as it keeps the same TenderInterface implementation
contract Tender is TenderInterface {
	address payable public owner; //the TenderApi smart contract instance
	TenderData public data; //the current contract implementation

	//Initializes the smart contract
	constructor(address payable tenderApiAddress) public {
		owner = tenderApiAddress;
	}

	//Makes sure that the function can only be called by TenderApi instance
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

	//Specifies the address of the TenderData smart contract implementation
	function setDataAddress(address newAddress) external restricted {
		data = TenderData(newAddress); //cast contract to TenderData
	}

	//Transfers ownership to the specified Tender smart contract owner
	function transferOwner(address payable newTenderOwner) external restricted {
		data.transferOwner(newTenderOwner);
	}

	//Creates a contract instance (should be changed to external when compiler support starts to exist)
	function createContract(uint128[] calldata params128, uint32[] calldata params32, uint16[] calldata params16) external restricted {
		data.addContract(params128, params32, params16);
	}

	//Ends the contract
	function endContract(uint32 contractId) external restricted {
		data.markEnded(contractId);
	}

	//Kills the service
	function endService() external restricted {
		data.endService();
		selfdestruct(owner);
	}
}