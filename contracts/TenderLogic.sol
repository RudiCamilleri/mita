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

	//Makes sure that the contract is active
	modifier contractActive(uint32 contractId) {
		require(tenderData.getContractState(contractId) == TenderDataInterface.ContractState.Active, "Specified contract is expired or invalid");
		_;
	}

	//Makes sure that the contract is active and the order is Pending or BeingDelivered (ie. not finalized)
	modifier orderActive(uint32 contractId, uint32 orderId) {
		require(tenderData.getContractState(contractId) == TenderDataInterface.ContractState.Active, "Specified contract is expired or invalid");
		TenderDataInterface.OrderState state = tenderData.getOrderState(contractId, orderId);
		require(state == TenderDataInterface.OrderState.Pending || state == TenderDataInterface.OrderState.BeingDelivered, "Order state must be Pending or BeingDelivered to be modified");
		_;
	}

	//=======================================================
	//== FUNCTION IMPLEMENTATIONS ARE TO BE INSERTED BELOW ==
	//==    ALL FUNCTIONS MUST BE MARKED AS RESTRICTED!    ==
	//=======================================================
	//Functions that are used in the smart contract itself and are to be exported should be marked as public,
	//whereas functions that are only called from outside should be marked as external

	//Replaces the current owner of the contract (not recommended to use)
	function replaceOwner(address newOwner) external restricted {
		owner = newOwner;
	}

	//Replaces the current TenderLogic smart contract implementation
	function replaceTenderLogic(address payable newTenderLogicAddress, bool killOldTenderLogic) external restricted {
		require(newTenderLogicAddress != address(this), "Invalid newTenderLogicAddress in replaceTenderLogic TenderLogic");
		if (address(tenderData) != address(0))
			tenderData.replaceTenderLogic(newTenderLogicAddress);
		if (killOldTenderLogic)
			selfdestruct(newTenderLogicAddress);
	}

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

	//Creates a contract instance
	function createContract(uint32 contractId, address payable client, uint128[] calldata params128, uint32[] calldata params32, uint16[] calldata params16) external restricted {
		require(tenderData.getContractState(contractId) == TenderDataInterface.ContractState.Null, "Contract already exists with that ID");
		tenderData.addContract(contractId, client, params128, params32, params16);
	}

	//Creates an order
	function createOrder(uint32 contractId, uint32 orderId, uint128[] calldata params128, uint32[] calldata params32) external restricted
	contractActive(contractId) {
		require(tenderData.getOrderState(contractId, orderId) == TenderDataInterface.OrderState.Null, "Order already exists with that ID");
		tenderData.addOrder(contractId, orderId, params128, params32);
	}

	//Marks servers as delivered
	function markServersDelivered(uint32 contractId, uint32 orderId, uint32 small, uint32 medium, uint32 large) external restricted
	orderActive(contractId, orderId) {
		if ()
		tenderData.setOrderState(contractId, orderId, TenderDataInterface.OrderState.Delivered);
	}

	//Marks the order as cancelled
	function cancelOrder(uint32 contractId, uint32 orderId) external restricted
	orderActive(contractId, orderId) {
		tenderData.setOrderState(contractId, orderId, TenderDataInterface.OrderState.Cancelled);
	}

	//Accepts the order as delivered and pays the client
	function acceptDelivery(uint32 contractId, uint32 orderId) external restricted
	orderActive(contractId, orderId) {
		tenderData.getClient(contractId).transfer(
			tenderData.getSmallServerPrice(contractId) * tenderData.getSmallServersOrdered(contractId, orderId) +
			tenderData.getMediumServerPrice(contractId) * tenderData.getMediumServersOrdered(contractId, orderId) +
			tenderData.getLargeServerPrice(contractId) * tenderData.getLargeServersOrdered(contractId, orderId)
		);
	}

	/*
	//passes refundable deposit
	function topUpPerformanceGuarantee() external;
	//stops the contract if payment isnt made.
	function stopOrder(uint32 orderNumber, uint8 penalty) external; //uint32 - Order number, uint8 - Penalty to be taken

	//automatically accepts extension
	function defaultAcceptanceOfOrderDeadlineExtension(uint32 orderNumber) external; //uint32 - Order number
	//to reject the extension
	function rejectOrderDeadlineExtension(uint32 orderNumber) external; //uint32 - Order number
	//accepts deadline manually
	function acceptOrderDeadlineExtension(uint32 orderNumber, uint64 dateExtension) external; //uint32 - Order number, uint 64 is checking date of extension
	//requests an extension of a deadline
	function requestOrderDeadlineExtension(uint32 orderNumber, bytes32 reason, uint64 dateExtension) external; //bytes 32 to store explanation, uint 64 is checking date of extension
	*/

	//Extends the deadline of an order
	function extendOrderDeadline(uint32 contractId, uint32 orderId, uint128 newUtcDeadline) external restricted
	orderActive(contractId, orderId) {
		require(tenderData.getOrderDeadline(contractId, orderId) < newUtcDeadline, "New order deadline cannot be older than the current order deadline");
		tenderData.setOrderDeadline(contractId, orderId, newUtcDeadline);
	}

	//Ends the contract
	function endContract(uint32 contractId, uint128 currentUtcDate) external restricted
	contractActive(contractId) {
		require(currentUtcDate - tenderData.getContractDeadline(contractId) >= 0);
		tenderData.markExpired(contractId);
	}

	//Kills the service
	function endService(address payable targetWallet) external restricted {
		tenderData.endService(targetWallet);
		selfdestruct(targetWallet);
	}
}