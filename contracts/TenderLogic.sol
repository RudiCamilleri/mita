pragma solidity >=0.5.0;

import "./TenderDataInterface.sol";

//Version 0.1
//This is the Business Logic Layer functionality implementation
contract TenderLogic {
	address payable public owner; //the main wallet owner of the smart contract
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
	modifier contractActive(uint128 currentUtcDate, uint32 contractId) {
		require(tenderData.getContractState(contractId) == TenderDataInterface.ContractState.Active &&
			tenderData.getContractDeadline(contractId) > currentUtcDate, "Specified contract is expired or invalid");
		_;
	}

	//Makes sure that the contract is active and the order is Pending or BeingDelivered (ie. not finalized)
	modifier orderActive(uint128 currentUtcDate, uint32 contractId, uint32 orderId) {
		//contractActive
		require(tenderData.getContractState(contractId) == TenderDataInterface.ContractState.Active &&
			tenderData.getContractDeadline(contractId) > currentUtcDate, "Specified contract is expired or invalid");

		require(tenderData.getOrderDeadline(contractId, orderId) <= currentUtcDate, "Order is expired");
		TenderDataInterface.OrderState state = tenderData.getOrderState(contractId, orderId);
		require(state == TenderDataInterface.OrderState.Pending || state == TenderDataInterface.OrderState.BeingDelivered, "Order state must be Pending or BeingDelivered to be modified");
		_;
	}

	//=====================================
	//=== PUBLIC CLIENT FUNCTIONS BELOW ===
	//=====================================
	//The client shoud call this function to pay the performance guarantee
	function payGuarantee(uint128 currentUtcDate, uint32 contractId) external
	contractActive(currentUtcDate, contractId) {
		require(msg.sender == tenderData.getClient(contractId) && msg.value == tenderData.getGuaranteeRequired(contractId), "Incorrect client or amount for performance guarantee");
		tenderData.setGuaranteePaid(contractId);
	}

	//TODO: Tops up the penalty required
	function topUpPenalty(uint128 currentUtcDate, uint32 contractId) external
	contractActive(currentUtcDate, contractId) {

	}

	//=======================================================
	//== FUNCTION IMPLEMENTATIONS ARE TO BE INSERTED BELOW ==
	//==    ALL FUNCTIONS MUST BE MARKED AS RESTRICTED!    ==
	//=======================================================
	//Functions that are used in the smart contract itself and are to be exported should be marked as public,
	//whereas functions that are only called from outside should be marked as external

	//Transfers the current TenderLogic smart contract to another owner
	function transferOwner(address newOwner) external restricted {
		owner = newOwner;
	}

	//Replaces the current TenderLogic smart contract implementation (for upgrading or bug fixes)
	function replaceTenderLogic(address payable newTenderLogicAddress, bool killOldTenderLogic) external restricted {
		require(newTenderLogicAddress != address(this), "Invalid newTenderLogicAddress in replaceTenderLogic TenderLogic");
		if (address(tenderData) != address(0))
			tenderData.replaceTenderLogic(newTenderLogicAddress);
		if (killOldTenderLogic)
			selfdestruct(newTenderLogicAddress);
	}

	//Sets or replaces the TenderDataInterface smart contract implementation (for initialization or upgrading)
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
	function createContract(uint32 contractId, address payable client, uint128[] calldata params128, uint32[] calldata params32) external restricted {
		require(tenderData.getContractState(contractId) == TenderDataInterface.ContractState.Null, "Contract already exists with that ID");
		tenderData.addContract(contractId, client, params128, params32);
	}

	//Creates an order
	function createOrder(uint128 currentUtcDate, uint32 contractId, uint32 orderId, uint128[] calldata params128, uint32[] calldata params32) external restricted
	contractActive(currentUtcDate, contractId) {
		require(tenderData.getOrderState(contractId, orderId) == TenderDataInterface.OrderState.Null, "Order already exists with that ID");
		require(tenderData.getGuaranteePaid(), "Performance guarantee must be paid to create an order");
		tenderData.addOrder(contractId, orderId, params128, params32);
	}

	//TODO: Marks servers as delivered
	function markServersDelivered(uint128 currentUtcDate, uint32 contractId, uint32 orderId, uint32 small, uint32 medium, uint32 large) external restricted
	orderActive(currentUtcDate, contractId, orderId) {
		if () {
			tenderData.setOrderState(contractId, orderId, TenderDataInterface.OrderState.Delivered);
			tenderData.getClient(contractId).transfer(safeAdd(safeAdd(
				safeMul(tenderData.getSmallServerPrice(contractId), tenderData.getSmallServersOrdered(contractId, orderId)),
				safeMul(tenderData.getMediumServerPrice(contractId), tenderData.getMediumServersOrdered(contractId, orderId))),
				safeMul(tenderData.getLargeServerPrice(contractId), tenderData.getLargeServersOrdered(contractId, orderId)))
			);
		}
	}

	//Changes the client wallet address of a contract to a new address
	function changeClient(uint128 currentUtcDate, uint32 contractId, address payable newClient) external restricted
	contractActive(currentUtcDate, contractId) {
		require(!(address(newClient) == address(0) || newClient == tenderData.getClient(contractId)), "New client address is zero or the same as the old one");
		tenderData.setClient(contractId, newClient);
	}

	//TODO: Marks the order deadline as passed (only if the deadline has passed)
	function markOrderDeadlinePassed(uint128 currentUtcDate, uint32 contractId, uint32 orderId) external restricted
	orderActive(0, contractId, contractId) {
		require(tenderData.getOrderDeadline(contractId, orderId) <= currentUtcDate, "Order deadline can be marked as passed only if deadline has passed");
		if ()
		tenderData.setContractState(contractId, TenderDataInterface.ContractState.Expired);
	}

	//TODO: Cancels the specified order
	function cancelOrder(uint128 currentUtcDate, uint32 contractId, uint32 orderId, uint128 penalty) external restricted
	orderActive(currentUtcDate, contractId, orderId) {
		tenderData.setOrderState(contractId, orderId, TenderDataInterface.OrderState.Cancelled);
		tenderData.setContract fgd
	}

	//Increases the min, medium and max server limits of the contract to the specified amount
	function updateContractMax(uint128 currentUtcDate, uint32 contractId, uint32 maxSmall, uint32 maxMedium, uint32 maxLarge) external restricted
	contractActive(currentUtcDate, contractId) {
		require(maxSmall >= tenderData.getMaxSmallServers(contractId) &&
				maxMedium >= tenderData.getMaxMediumServers(contractId) &&
				maxLarge >= tenderData.getMaxLargeServers(contractId), "Max server quantities can only be increased");
		tenderData.setContractMax(contractId, maxSmall, maxMedium, maxLarge);
	}

	//Extends the order deadline to the specified date
	function extendOrderDeadline(uint128 currentUtcDate, uint32 contractId, uint32 orderId, uint128 newUtcDeadline) external restricted
	orderActive(0, contractId, orderId) {
		require(tenderData.getOrderDeadline(contractId, orderId) < newUtcDeadline, "New order deadline cannot be older than the current order deadline");
		tenderData.setOrderDeadline(contractId, orderId, newUtcDeadline);
	}

	//Extends the contract deadline to the specified date
	function extendContractDeadline(uint128 currentUtcDate, uint32 contractId, uint128 newUtcDeadline) external restricted
	contractActive(0, contractId) {
		require(tenderData.getContractDeadline(contractId) < newUtcDeadline, "New contract deadline cannot be older than the current order deadline");
		tenderData.setContractDeadline(contractId, newUtcDeadline);
	}

	//Marks the contract as expired (only if it is already expired)
	function markContractExpired(uint128 currentUtcDate, uint32 contractId) external restricted
	contractActive(0, contractId) {
		require(tenderData.getContractDeadline(contractId) <= currentUtcDate, "Contract can be marked as expired only if deadline is reached");
		tenderData.setContractState(contractId, TenderDataInterface.ContractState.Expired);
	}

	//TODO: Terminates the contract abnormally (possibly due to breach)
	function terminateContract(uint128 currentUtcDate, uint32 contractId) external restricted
	contractActive(currentUtcDate, contractId) {
		tenderData.setContractState(contractId, TenderDataInterface.ContractState.Terminated);
	}

	//Kills the current TenderData contract and transfers its Ether to the owner
	function destroyTenderData() external restricted {
		tenderData.destroyTenderData(owner);
	}

	//Kills the current TenderLogic contract and transfers its Ether to the owner
	function destroyTenderLogic() external restricted {
		selfdestruct(owner);
	}

	//======================= CALCULATIONS =======================

	//Adds two positive integers
	function safeAdd(uint256 a, uint256 b) private pure returns (uint256 c) {
		c = a + b;
		require(c >= a, "Wraparound occurred in addition");
	}

	//Subtracts a small positive integer from a larger positive integer
	function safeSub(uint256 a, uint256 b) private pure returns (uint256 c) {
		require(b <= a, "Wraparound occurred in subtraction");
		c = a - b;
	}

	//Multiplies two positive integers
	function safeMul(uint256 a, uint256 b) private pure returns (uint256 c) {
		c = a * b;
		require(a == 0 || c / a == b, "Wraparound occurred in multiplication");
	}

	//Divides a positive integer by another positive integer
	function safeDiv(uint256 a, uint256 b) private pure returns (uint256 c) {
		require(b > 0, "Cannot divide by 0");
		c = a / b;
	}
}