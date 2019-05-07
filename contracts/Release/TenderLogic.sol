pragma solidity >=0.5.0;

import "./ITenderData.sol";

//Version 0.1
//This is the Business Logic Layer functionality implementation
contract TenderLogic {
	address payable public owner; //the main wallet owner of the smart contract
	uint256 public ownerBalance; //the pending balance of owner top-ups to the smart contract
	ITenderData public tenderData; //the current data contract implementation

	//Initializes the smart contract
	constructor() public {
		owner = msg.sender;
	}

	//Makes sure that the function can only be called by main wallet owner
	modifier restricted() {
		require(msg.sender == owner);
		_;
	}

	//Makes sure that the contract is active
	modifier contractActive(uint32 contractId) {
		require(tenderData.getContractState(contractId) == ITenderData.ContractState.Active);
		_;
	}

	//Makes sure that the contract is active and check that the date is valid for the contract
	modifier contractActiveCheckDate(uint128 currentUtcDate, uint32 contractId) {
		require(tenderData.getContractState(contractId) == ITenderData.ContractState.Active &&
			tenderData.getContractStartDate(contractId) <= currentUtcDate &&
			tenderData.getContractDeadline(contractId) > currentUtcDate);
		_;
	}

	//Makes sure that the order is Pending (ie. not finalized)
	modifier orderActive(uint32 contractId, uint32 orderId) {
		require(tenderData.getOrderState(contractId, orderId) == ITenderData.OrderState.Pending);
		_;
	}

	modifier validateAddress(address addr) {
		require(!(addr == address(0) || addr == address(this) || addr == address(tenderData)));
		_;
	}

	//=====================================
	//=== PUBLIC CLIENT FUNCTIONS BELOW ===
	//=====================================
	//The client calls this function to pay the performance guarantee
	function payGuarantee(uint128 currentUtcDate, uint32 contractId) external payable
	contractActiveCheckDate(currentUtcDate, contractId) {
		require(msg.value > 0 && msg.sender == tenderData.getClient(contractId) &&
			msg.value == tenderData.getGuaranteeRequired(contractId) && !tenderData.getGuaranteePaid(contractId));
		tenderData.setGuaranteePaid(contractId);
		tenderData.setClientPot(contractId, safeAdd256(tenderData.getClientPot(contractId), msg.value));
	}

	//The client calls this function to top up the penalty balance
	function topUpPenalty(uint128 currentUtcDate, uint32 contractId) external payable
	contractActiveCheckDate(currentUtcDate, contractId) {
		require(msg.value > 0 && msg.sender == tenderData.getClient(contractId) && tenderData.getGuaranteePaid(contractId));
		tenderData.setClientPot(contractId, safeAdd256(tenderData.getClientPot(contractId), msg.value));
	}

	//Tops up the pending balance of the smart contract for payments to client
	function topUpPaymentsToClient() external payable restricted {
		require(msg.value > 0 && msg.sender == owner);
		ownerBalance = safeAdd256(ownerBalance, msg.value);
	}

	//=======================================================
	//== FUNCTION IMPLEMENTATIONS ARE TO BE INSERTED BELOW ==
	//==    ALL FUNCTIONS MUST BE MARKED AS RESTRICTED!    ==
	//=======================================================
	//Functions that are used in the smart contract itself and are to be exported should be marked as public,
	//whereas functions that are only called from outside should be marked as external

	//Transfers the current TenderLogic smart contract to another owner
	function transferOwner(address payable newOwner) external restricted {
		owner = newOwner;
	}

	//Replaces the current TenderLogic smart contract implementation (for upgrading or bug fixes)
	function replaceTenderLogic(address payable newTenderLogicAddress, bool killOldTenderLogic) external restricted
	validateAddress(newTenderLogicAddress) {
		tenderData.replaceTenderLogic(newTenderLogicAddress);
		if (killOldTenderLogic)
			selfdestruct(newTenderLogicAddress);
	}

	//Sets or replaces the ITenderData smart contract implementation (for initialization or upgrading)
	function replaceTenderData(address payable newTenderDataAddress, bool migrateOldData, bool killOldData) external restricted
	validateAddress(newTenderDataAddress) {
		ITenderData oldTenderData = tenderData;
		tenderData = ITenderData(newTenderDataAddress); //cast contract to ITenderData
		if (address(oldTenderData) != address(0)) {
			if (migrateOldData)
				tenderData.migrateData(address(oldTenderData));
			if (killOldData)
				oldTenderData.destroyTenderData(newTenderDataAddress);
		}
	}

	//Creates a contract instance
	function createContract(uint32 contractId, address payable client, uint128[] calldata params128, uint32[] calldata params32) external restricted {
		require(params128[5] < params128[6]);
		require(tenderData.getContractState(contractId) == ITenderData.ContractState.Null);
		tenderData.addContract(contractId, client, params128, params32);
	}

	//Creates an order
	function createOrder(uint128 currentUtcDate, uint32 contractId, uint32 orderId, uint32 small, uint32 medium, uint32 large, uint128 startDate, uint128 deadline) external restricted
	contractActiveCheckDate(currentUtcDate, contractId) {
		require(startDate < deadline);
		require(tenderData.getOrderState(contractId, orderId) == ITenderData.OrderState.Null);
		require(tenderData.getGuaranteePaid(contractId) || tenderData.getGuaranteeRequired(contractId) == 0);
		uint32 newSmall = safeAdd32(tenderData.getTotalSmallServersOrdered(contractId), small);
		uint32 newMedium = safeAdd32(tenderData.getTotalMediumServersOrdered(contractId), medium);
		uint32 newLarge = safeAdd32(tenderData.getTotalLargeServersOrdered(contractId), large);
		require(newSmall <= tenderData.getMaxSmallServers(contractId));
		require(newMedium <= tenderData.getMaxMediumServers(contractId));
		require(newLarge <= tenderData.getMaxLargeServers(contractId));
		tenderData.setTotalServersOrdered(contractId, newSmall, newMedium, newLarge);
		tenderData.addOrder(contractId, orderId, small, medium, large, startDate, deadline);
	}

	//Pays the client the specified amount (use only for special cases)
	function payClient(uint32 contractId, uint128 amount) external restricted
	validateAddress(tenderData.getClient(contractId)) {
		require(amount > 0);
		ownerBalance = safeSub256(ownerBalance, amount);
		tenderData.getClient(contractId).transfer(amount);
	}

	//Pays the client for the specified order delivery
	function payClientForOrder(uint32 contractId, uint32 orderId) public restricted
	validateAddress(tenderData.getClient(contractId)) {
		markOrderPaid(contractId, orderId);
		uint256 amount = safeAdd256(safeAdd256(
			safeMul256(tenderData.getSmallServerPrice(contractId), tenderData.getSmallServersOrdered(contractId, orderId)),
			safeMul256(tenderData.getMediumServerPrice(contractId), tenderData.getMediumServersOrdered(contractId, orderId))),
			safeMul256(tenderData.getLargeServerPrice(contractId), tenderData.getLargeServersOrdered(contractId, orderId)));
		require(amount > 0);
		ownerBalance = safeSub256(ownerBalance, amount);
		tenderData.getClient(contractId).transfer(amount);
	}

	//Marks a number of servers as delivered for the specified order
	function markServersDelivered(uint32 contractId, uint32 orderId, uint32 small, uint32 medium, uint32 large, bool payClientIfCompleted) external restricted
	orderActive(contractId, orderId) {
		uint32 newSmall = safeAdd32(tenderData.getSmallServersDelivered(contractId, orderId), small);
		uint32 newMedium = safeAdd32(tenderData.getMediumServersDelivered(contractId, orderId), medium);
		uint32 newLarge = safeAdd32(tenderData.getLargeServersDelivered(contractId, orderId), large);
		require(newSmall <= tenderData.getSmallServersOrdered(contractId, orderId));
		require(newMedium <= tenderData.getMediumServersOrdered(contractId, orderId));
		require(newLarge <= tenderData.getLargeServersOrdered(contractId, orderId));
		tenderData.setTotalServersDelivered(contractId, orderId, newSmall, newMedium, newLarge);
		if (newSmall == tenderData.getSmallServersOrdered(contractId, orderId) &&
			newMedium == tenderData.getMediumServersOrdered(contractId, orderId) &&
			newLarge == tenderData.getLargeServersOrdered(contractId, orderId)) {
			tenderData.setOrderState(contractId, orderId, ITenderData.OrderState.Delivered);
			if (payClientIfCompleted)
				payClientForOrder(contractId, orderId);
		}
	}

	//Marks the order deadline as passed (only if the deadline has passed). To collect penalty fee, call collectFromPot() with the desired amount
	function markOrderDeadlinePassed(uint128 currentUtcDate, uint32 contractId, uint32 orderId, bool subtractFromContractTotal) external restricted
	orderActive(contractId, contractId) {
		require(tenderData.getOrderDeadline(contractId, orderId) <= currentUtcDate);
		tenderData.setOrderState(contractId, orderId, ITenderData.OrderState.Cancelled);
		if (subtractFromContractTotal) {
			tenderData.setTotalServersOrdered(contractId,
				safeSub32(tenderData.getTotalSmallServersOrdered(contractId), tenderData.getSmallServersOrdered(contractId, orderId)),
				safeSub32(tenderData.getTotalMediumServersOrdered(contractId), tenderData.getMediumServersOrdered(contractId, orderId)),
				safeSub32(tenderData.getTotalLargeServersOrdered(contractId), tenderData.getLargeServersOrdered(contractId, orderId)));
		}
	}

	//Marks the order as paid (only call if the order was actually paid)
	function markOrderPaid(uint32 contractId, uint32 orderId) public restricted {
		require(tenderData.getOrderState(contractId, orderId) == ITenderData.OrderState.Delivered &&
			!tenderData.getOrderPaid(contractId, orderId));
		tenderData.setOrderPaid(contractId, orderId, true);
	}

	//Cancels the specified order. To collect penalty fee, call collectFromPot() with the desired amount
	function cancelOrder(uint32 contractId, uint32 orderId, bool subtractFromContractTotal) external restricted
	orderActive(contractId, orderId) {
		tenderData.setOrderState(contractId, orderId, ITenderData.OrderState.Cancelled);
		if (subtractFromContractTotal) {
			tenderData.setTotalServersOrdered(contractId,
				safeSub32(tenderData.getTotalSmallServersOrdered(contractId), tenderData.getSmallServersOrdered(contractId, orderId)),
				safeSub32(tenderData.getTotalMediumServersOrdered(contractId), tenderData.getMediumServersOrdered(contractId, orderId)),
				safeSub32(tenderData.getTotalLargeServersOrdered(contractId), tenderData.getLargeServersOrdered(contractId, orderId)));
		}
	}

	//Collects fees from the client pot (which includes performance guarantee and penalty money)
	function collectFromClientPot(uint32 contractId, uint256 amount) external restricted {
		require(amount > 0);
		require(tenderData.getGuaranteePaid(contractId) || tenderData.getGuaranteeRequired(contractId) == 0);
		tenderData.setClientPot(contractId, safeSub256(tenderData.getClientPot(contractId), amount));
		owner.transfer(amount);
	}

	//Refunds the specified amount back to the owner
	function collectFromOwnerBalance(uint256 amount) external restricted {
		require(amount > 0);
		ownerBalance = safeSub256(ownerBalance, amount);
		owner.transfer(amount);
	}

	//Changes the client wallet address of a contract to a new address
	function changeClient(uint128 currentUtcDate, uint32 contractId, address payable newClient) external restricted
	contractActiveCheckDate(currentUtcDate, contractId)
	validateAddress(newClient) {
		require(newClient != tenderData.getClient(contractId));
		tenderData.setClient(contractId, newClient);
	}

	//Increases the min, medium and max server limits of the contract to the specified amount
	function updateContractMax(uint128 currentUtcDate, uint32 contractId, uint32 maxSmall, uint32 maxMedium, uint32 maxLarge) external restricted
	contractActiveCheckDate(currentUtcDate, contractId) {
		require(maxSmall >= tenderData.getMaxSmallServers(contractId) &&
				maxMedium >= tenderData.getMaxMediumServers(contractId) &&
				maxLarge >= tenderData.getMaxLargeServers(contractId));
		tenderData.setContractMax(contractId, maxSmall, maxMedium, maxLarge);
	}

	//Extends the order deadline to the specified date
	function extendOrderDeadline(uint32 contractId, uint32 orderId, uint128 newUtcDeadline) external restricted
	orderActive(contractId, orderId) {
		require(tenderData.getOrderDeadline(contractId, orderId) < newUtcDeadline);
		tenderData.setOrderDeadline(contractId, orderId, newUtcDeadline);
	}

	//Extends the contract deadline to the specified date
	function extendContractDeadline(uint32 contractId, uint128 newUtcDeadline) external restricted
	contractActive(contractId) {
		require(tenderData.getContractDeadline(contractId) < newUtcDeadline);
		tenderData.setContractDeadline(contractId, newUtcDeadline);
	}

	//Marks the contract as expired (only if it is already expired)
	function markContractExpired(uint128 currentUtcDate, uint32 contractId) external restricted
	contractActive(contractId) {
		require(tenderData.getContractDeadline(contractId) <= currentUtcDate);
		tenderData.setContractState(contractId, ITenderData.ContractState.Expired);
	}

	//Terminates the contract abnormally (possibly due to breach)
	function terminateContract(uint128 currentUtcDate, uint32 contractId) external restricted
	contractActiveCheckDate(currentUtcDate, contractId) {
		tenderData.setContractState(contractId, ITenderData.ContractState.Terminated);
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
	function safeAdd32(uint32 a, uint32 b) private pure returns (uint32) {
		uint32 result = a + b;
		require(result >= a);
		return result;
	}

	//Adds two positive integers
	function safeAdd256(uint256 a, uint256 b) private pure returns (uint256) {
		uint256 result = a + b;
		require(result >= a);
		return result;
	}

	//Subtracts a small positive integer from a larger positive integer
	function safeSub32(uint32 a, uint32 b) private pure returns (uint32) {
		require(b <= a);
		return a - b;
	}

	//Subtracts a small positive integer from a larger positive integer
	function safeSub256(uint256 a, uint256 b) private pure returns (uint256) {
		require(b <= a);
		return a - b;
	}

	//Multiplies two positive integers
	function safeMul256(uint256 a, uint256 b) private pure returns (uint256) {
		uint256 result = a * b;
		require(a == 0 || result / a == b);
		return result;
	}

	//Divides a positive integer by another positive integer
	function safeDiv256(uint256 a, uint256 b) private pure returns (uint256) {
		require(b > 0);
		return a / b;
	}
}