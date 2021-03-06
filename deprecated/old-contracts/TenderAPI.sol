pragma solidity >=0.5.0;

import "./TenderBLLInterface.sol";

//Version 0.1
//This is the main contract that expose functionality to the server API and handles versioning
contract TenderAPI is TenderBLLInterface {
	address public owner; //the main wallet owner of the smart contract
	TenderBLLInterface public tenderBLL; //the current TenderBLL contract implementation

	//Initializes the smart contract
	constructor() public {
		owner = msg.sender;
	}

	//Makes sure that the function can only be called by main wallet owner
	modifier restricted() {
		require(msg.sender == owner, "Illegitimate caller in TenderAPI");
		_;
	}

	//=================================================
	//==  API FUNCTIONALITY IS TO BE INSERTED BELOW  ==
	//== ALL FUNCTIONS MUST BE MARKED AS RESTRICTED! ==
	//=================================================

	//Replaces the current owner of the contract (not recommended to use)
	function replaceOwner(address newOwner) external restricted {
		owner = newOwner;
	}

	//Sets or replaces the TenderDataInterface smart contract implementation
	function replaceTenderData(address payable newTenderDataAddress, bool migrateOldData, bool killOldData) external restricted {
		tenderBLL.replaceTenderData(newTenderDataAddress, migrateOldData, killOldData);
	}

	//Sets or replaces the TenderBLLInterface smart contract implementation
	function replaceTenderBLLAndTransfer(address payable newTenderBLLAddress, bool killOldTenderBLL) external restricted {
		require(newTenderBLLAddress != address(this) && newTenderBLLAddress != address(tenderBLL), "Invalid newTenderBLLAddress in replaceTenderBLLAndTransfer TenderAPI");
		TenderBLLInterface oldTenderBLL = tenderBLL;
		tenderBLL = TenderBLLInterface(newTenderBLLAddress); //cast contract to TenderBLLInterface
		if (address(oldTenderBLL) != address(0))
			oldTenderBLL.replaceTenderBLLAndTransfer(newTenderBLLAddress, killOldTenderBLL);
	}

	//Sets or replaces the TenderBLLInterface smart contract implementation without transferring resources
	function replaceTenderBLL(address newTenderBLLAddress) external restricted {
		require(newTenderBLLAddress != address(this) && newTenderBLLAddress != address(tenderBLL), "Invalid newTenderBLLAddress in replaceTenderBLL TenderAPI");
		TenderBLLInterface oldTenderBLL = tenderBLL;
		tenderBLL = TenderBLLInterface(newTenderBLLAddress); //cast contract to TenderBLLInterface
		if (address(oldTenderBLL) != address(0))
			oldTenderBLL.replaceTenderBLL(newTenderBLLAddress);
	}

	//Sets or replaces the TenderBLLInterface (ideally TenderAPI) smart contract implementation,
	//where targetWallet is the wallet to transfer the funds to (or 0 to not transfer anything)
	function replaceTenderAPI(address newTenderAPIAddress, address payable targetWallet) external restricted {
		require(newTenderAPIAddress != address(this) && newTenderAPIAddress != address(tenderBLL), "Invalid newTenderAPIAddress in replaceTenderAPI TenderAPI");
		if (address(tenderBLL) != address(0)) {
			tenderBLL.replaceTenderAPI(newTenderAPIAddress, targetWallet);
			TenderBLLInterface(newTenderAPIAddress).replaceTenderBLL(address(tenderBLL));
		}
		if (address(targetWallet) != address(0))
			selfdestruct(targetWallet);
	}

	//Creates a contract instance
	function createContract(uint128[] calldata params128, uint32[] calldata params32, uint16[] calldata params16) external restricted {
		tenderBLL.createContract(params128, params32, params16);
	}

	//Creates an order
	function createOrder(uint32 contractId, uint32 orderId, uint16 small, uint16 medium, uint16 large) external restricted {
		tenderBLL.createOrder(contractId, orderId, small, medium, large);
	}

	//to confirm order is delivered
	function markDelivered(uint32 contractId, uint32 orderId) external restricted {
		tenderBLL.markDelivered(contractId, orderId);
	}

	//Ends the contract
	function endContract(uint32 contractId) external restricted {
		tenderBLL.endContract(contractId);
	}

	//Kills the service
	function endService(address payable targetWallet) external restricted {
		tenderBLL.endService(targetWallet);
		selfdestruct(targetWallet);
	}

	/*//passes refundable deposit.
	function topUpPerformanceGuarantee() external restricted {
		return tenderBLL.topUpPerformanceGuarantee();
	}

	//stops the contract if payment isnt made.
	function stopOrder(uint32 orderNumber, uint8 penalty) external restricted {
		//uint32 - Order number, uint8 - Penalty to be taken
		return tenderBLL.stopOrder(orderNumber, penalty);
	}

    //if order was delivered proceed
	function deliveryAcceptance(uint32 orderNumber, uint16 serverAmount) external restricted {
		//uint32 - Order number, unit16 server amount as a whole
		return tenderBLL.deliveryAcceptance(orderNumber, serverAmount);
	}

	//automatically accepts extension
	function defaultAcceptanceOfOrderDeadlineExtension(uint32 orderNumber) external restricted {
		//uint32 - Order number
		return tenderBLL.defaultAcceptanceOfOrderDeadlineExtension(orderNumber);
	}

	//to reject the extension
	function rejectOrderDeadlineExtension(uint32 orderNumber) external restricted {
		//uint32 - Order number
		return tenderBLL.rejectOrderDeadlineExtension(orderNumber);
	}

	//accepts deadline manually
	function acceptOrderDeadlineExtension(uint32 orderNumber, uint64 dateExtension) external restricted {
		//uint32 - Order number, uint 64 is checking date of extension.
		return tenderBLL.acceptOrderDeadlineExtension(orderNumber, dateExtension);
	}

	//requests an extension of a deadline
	function requestOrderDeadlineExtension(uint32 orderNumber, bytes32 reason, uint64 dateExtension) external restricted {
		//bytes 32 to store explanation //uint 64 is checking date of extension.
		return tenderBLL.requestOrderDeadlineExtension(orderNumber, reason, dateExtension);
	}

	//cancels order
	function cancelOrder(uint32 orderNumber) external restricted {
		//uint32 - Order number
		return tenderBLL.cancelOrder(orderNumber);
	}

	//creates order
	function createOrder(uint32 orderNumber, uint16 serverAmount, bytes32 costDescription) external restricted {
		//uint32 - Order number, uint16 server amoutn as a whole , bytes32 description of total price.
		return tenderBLL.createOrder(orderNumber, serverAmount, costDescription);
	}*/
}