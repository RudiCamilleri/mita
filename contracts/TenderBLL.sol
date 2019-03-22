pragma solidity >=0.5.0;

import "./TenderBLLInterface.sol";
import "./TenderDataInterface.sol";

//Version 0.1
//This is the Business Logic Layer functionality implementation
contract TenderBLL is TenderBLLInterface {
	address public tenderApi; //the parent TenderApi smart contract instance
	TenderDataInterface public tenderData; //the current data contract implementation

	//Initializes the smart contract
	constructor(address tenderApiAddress) public {
		tenderApi = tenderApiAddress;
	}

	//Makes sure that the function can only be called by TenderApi parent
	modifier restricted() {
		require(msg.sender == tenderApi, "Illegitimate caller in TenderBLL");
		_;
	}

	//=======================================================
	//== FUNCTION IMPLEMENTATIONS ARE TO BE INSERTED BELOW ==
	//==    ALL FUNCTIONS MUST BE MARKED AS RESTRICTED!    ==
	//=======================================================
	//Functions that are used in the smart contract itself and are to be exported should be marked as public,
	//whereas functions that are only called from outside should be marked as external

	//Sets or replaces the TenderDataInterface smart contract implementation
	function replaceTenderData(address payable newTenderDataAddress, bool migrateOldData, bool killOldData) external restricted {
		require(newTenderDataAddress != address(tenderData), "Invalid newTenderDataAddress in replaceTenderData TenderBLL");
		TenderDataInterface newData = TenderDataInterface(newTenderDataAddress); //cast contract to TenderDataInterface
		if (address(tenderData) != address(0)) {
			if (migrateOldData)
				newData.migrateData(address(tenderData));
			if (killOldData)
				tenderData.endService(newTenderDataAddress);
		}
		tenderData = newData;
	}

	//Sets or replaces the TenderBLLInterface smart contract implementation
	function replaceTenderBLLAndTransfer(address payable newTenderBLLAddress, bool killOldTenderBLL) external restricted {
		require(newTenderBLLAddress != address(this), "Invalid newTenderBLLAddress in replaceTenderBLLAndTransfer TenderBLL");
		if (address(tenderData) != address(0))
			tenderData.replaceTenderBLL(newTenderBLLAddress);
		if (killOldTenderBLL)
			selfdestruct(newTenderBLLAddress);
	}

	//Sets or replaces the TenderBLLInterface smart contract implementation without transferring resources
	function replaceTenderBLL(address newTenderBLLAddress) external restricted {
		require(newTenderBLLAddress != address(this), "Invalid newTenderBLLAddress in replaceTenderBLL TenderBLL");
		if (address(tenderData) != address(0))
			tenderData.replaceTenderBLL(newTenderBLLAddress);
	}

	//Sets or replaces the TenderBLLInterface (ideally TenderApi) smart contract implementation,
	//where targetWallet is the wallet to transfer the funds to (or 0 to not transfer anything)
	function replaceTenderApi(address newTenderApiAddress, address payable targetWallet) external restricted {
		tenderApi = newTenderApiAddress;
	}

	//Creates a contract instance (should be changed to external when compiler support starts to exist)
	function createContract(uint128[] calldata params128, uint32[] calldata params32, uint16[] calldata params16) external restricted {
		tenderData.addContract(params128, params32, params16);
	}

	//Ends the contract
	function endContract(uint32 contractId) external restricted {
		tenderData.markEnded(contractId);
	}

	//Kills the service
	function endService(address payable targetWallet) external restricted {
		tenderData.endService(targetWallet);
		selfdestruct(targetWallet);
	}
}