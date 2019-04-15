pragma solidity >=0.5.0;

import "./TenderDataInterface.sol";

//Version 0.1
//This is the Business Logic Layer functionality implementation
contract TenderLogic {
	address public owner; //the main wallet owner of the smart contract
	TenderDataInterface public tenderData; //the current data contract implementation

	//Initializes the smart contract
	constructor() public {
		owner = msg.sender;
	}

	//Makes sure that the function can only be called by main wallet owner
	modifier restricted() {
		require(msg.sender == owner, "Illegitimate caller in TenderLogic");
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
		require(newTenderDataAddress != address(tenderData), "Invalid newTenderDataAddress in replaceTenderData TenderLogic");
		TenderDataInterface oldTenderData = tenderData;
		tenderData = TenderDataInterface(newTenderDataAddress); //cast contract to TenderDataInterface
		if (address(tenderData) != address(0)) {
			if (migrateOldData)
				tenderData.migrateData(address(oldTenderData));
			if (killOldData)
				oldTenderData.endService(newTenderDataAddress);
		}
	}

	//Replaces the current TenderLogic smart contract implementation
	function replaceTenderLogic(address payable newTenderLogicAddress, bool killOldTenderLogic) external restricted {
		require(newTenderLogicAddress != address(this), "Invalid newTenderLogicAddress in replaceTenderLogic TenderLogic");
		if (address(tenderData) != address(0))
			tenderData.replaceTenderLogic(newTenderLogicAddress);
		if (killOldTenderLogic)
			selfdestruct(newTenderLogicAddress);
	}

	//Replaces the current owner of the contract (not recommended to use)
	function replaceOwner(address newOwner) external restricted {
		owner = newOwner;
	}

	//Creates a contract instance
	function createContract(uint128[] calldata params128, uint32[] calldata params32, uint16[] calldata params16) external restricted {
		tenderData.addContract(params128, params32, params16);
	}

	//Creates an order
	function createOrder(uint32 contractId, uint32 orderId, uint16 small, uint16 medium, uint16 large) external restricted {
		tenderData.addOrder(contractId, orderId, small, medium, large);
	}

	//Marks the order as delivered
	function markDelivered(uint32 contractId, uint32 orderId) external restricted {
		tenderData.setOrderState(contractId, orderId, TenderDataInterface.OrderState.Delivered);

	}

	//Marks the order as cancelled
	function cancelOrder(uint32 contractId, uint32 orderId) external restricted {
		tenderData.setOrderState(contractId, orderId, TenderDataInterface.OrderState.Cancelled);
	}

	/*
	//passes refundable deposit
	function topUpPerformanceGuarantee() external;
	//stops the contract if payment isnt made.
	function stopOrder(uint32 orderNumber, uint8 penalty) external; //uint32 - Order number, uint8 - Penalty to be taken
    //if order was delivered proceed
	function deliveryAcceptance(uint32 orderNumber, uint16 serverAmount) external; //uint32 - Order number, unit16 server amount as a whole
	//to confirm order is delivered
	//automatically accepts extension
	function defaultAcceptanceOfOrderDeadlineExtension(uint32 orderNumber) external; //uint32 - Order number
	//to reject the extension
	function rejectOrderDeadlineExtension(uint32 orderNumber) external; //uint32 - Order number
	//accepts deadline manually
	function acceptOrderDeadlineExtension(uint32 orderNumber, uint64 dateExtension) external; //uint32 - Order number, uint 64 is checking date of extension
	//requests an extension of a deadline
	function requestOrderDeadlineExtension(uint32 orderNumber, bytes32 reason, uint64 dateExtension) external; //bytes 32 to store explanation, uint 64 is checking date of extension
	*/

	//Ends the contract
	function endContract(uint32 contractId, uint128 currentUtcDate) external restricted {
		require(currentUtcDate - tenderData.getExpiryDate(contractId) >= 0);
		tenderData.markExpired(contractId);
	}

	//Kills the service
	function endService(address payable targetWallet) external restricted {
		tenderData.endService(targetWallet);
		selfdestruct(targetWallet);
	}
}