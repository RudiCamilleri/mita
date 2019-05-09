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
		require(msg.sender == owner, "Illegitimate caller in TenderLogic");
		_;
	}

	//Makes sure that the contract is active
	modifier contractActive(uint32 contractId) {
		require(tenderData.getContractState(contractId) == ITenderData.ContractState.Active, "Specified contract is expired or invalid");
		_;
	}

	//Makes sure that the contract is active and check that the date is valid for the contract
	modifier contractActiveCheckDate(uint128 currentUtcDate, uint32 contractId) {
		require(tenderData.getContractState(contractId) == ITenderData.ContractState.Active &&
			tenderData.getContractStartDate(contractId) <= currentUtcDate &&
			tenderData.getContractDeadline(contractId) > currentUtcDate, "Specified contract is pending, expired or invalid");
		_;
	}

	//Makes sure that the order is Pending (ie. not finalized)
	modifier orderActive(uint32 contractId, uint32 orderId) {
		require(tenderData.getOrderState(contractId, orderId) == ITenderData.OrderState.Pending, "Order state must be Pending to be modified");
		_;
	}

	modifier validateAddress(address addr) {
		require(!(addr == address(0) || addr == address(this) || addr == address(tenderData)), "Invalid target address");
		_;
	}

	/*//Makes sure that the contract is active and the order is Pending (ie. not finalized)
	modifier orderActiveCheckDate(uint128 currentUtcDate, uint32 contractId, uint32 orderId) {
		//contractActiveCheckDate
		require(tenderData.getContractState(contractId) == ITenderData.ContractState.Active &&
			tenderData.getContractStartDate(contractId) <= currentUtcDate &&
			tenderData.getContractDeadline(contractId) > currentUtcDate, "Specified contract is pending, expired or invalid");

		require(tenderData.getOrderCreationDate(contractId, orderId) <= currentUtcDate &&
			tenderData.getOrderDeadline(contractId, orderId) > currentUtcDate, "Order is not created or it is expired");
		ITenderData.OrderState state = tenderData.getOrderState(contractId, orderId);
		require(state == ITenderData.OrderState.Pending, "Order state must be Pending to be modified");
		_;
	}*/

	//=====================================
	//=== PUBLIC CLIENT FUNCTIONS BELOW ===
	//=====================================
	//The client calls this function to pay the performance guarantee
	function payGuarantee(uint128 currentUtcDate, uint32 contractId) external payable
	contractActiveCheckDate(currentUtcDate, contractId) {
		require(msg.value > 0 && msg.sender == tenderData.getClient(contractId) &&
			msg.value == tenderData.getGuaranteeRequired(contractId) && !tenderData.getGuaranteePaid(contractId), "Incorrect client or amount for performance guarantee, or already paid");
		tenderData.setGuaranteePaid(contractId);
		tenderData.setClientGuaranteeBalance(contractId, msg.value);
	}

	//The client calls this function to top up the penalty balance
	function topUpPenalty(uint128 currentUtcDate, uint32 contractId) external payable
	contractActiveCheckDate(currentUtcDate, contractId) {
		require(msg.value > 0 && msg.sender == tenderData.getClient(contractId) && tenderData.getGuaranteePaid(contractId), "Incorrect client or amount 0 for performance guarantee or guarantee not paid");
		tenderData.setClientPenaltyBalance(contractId, safeAdd256(tenderData.getClientPenaltyBalance(contractId), msg.value));
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
		require(params128[5] < params128[6], "Deadline cannot be before start date");
		require(tenderData.getContractState(contractId) == ITenderData.ContractState.Null, "Contract already exists with that ID");
		tenderData.addContract(contractId, client, params128, params32);
	}

	//Creates an order
	function createOrder(uint128 currentUtcDate, uint32 contractId, uint32 orderId, uint32 small, uint32 medium, uint32 large, uint128 startDate, uint128 deadline) external restricted
	contractActiveCheckDate(currentUtcDate, contractId) {
		require(startDate < deadline, "Deadline cannot be before start date");
		require(tenderData.getOrderState(contractId, orderId) == ITenderData.OrderState.Null, "Order already exists with that ID");
		require(tenderData.getGuaranteePaid(contractId) || tenderData.getGuaranteeRequired(contractId) == 0, "Performance guarantee must be paid to create an order");
		uint32 newSmall = safeAdd32(tenderData.getTotalSmallServersOrdered(contractId), small);
		uint32 newMedium = safeAdd32(tenderData.getTotalMediumServersOrdered(contractId), medium);
		uint32 newLarge = safeAdd32(tenderData.getTotalLargeServersOrdered(contractId), large);
		require(newSmall <= tenderData.getMaxSmallServers(contractId), "Cannot exceed max small server count. To extend the amount, use updateContractMax()");
		require(newMedium <= tenderData.getMaxMediumServers(contractId), "Cannot exceed max medium server count. To extend the amount, use updateContractMax()");
		require(newLarge <= tenderData.getMaxLargeServers(contractId), "Cannot exceed max large server count. To extend the amount, use updateContractMax()");
		tenderData.setTotalServersOrdered(contractId, newSmall, newMedium, newLarge);
		tenderData.addOrder(contractId, orderId, small, medium, large, startDate, deadline);
	}

	//Pays the client the specified amount (use only for special cases)
	function payClient(uint32 contractId, uint128 amount) external restricted
	validateAddress(tenderData.getClient(contractId)) {
		require(amount > 0, "Amount must be greater than 0");
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
		require(amount > 0, "Balance must be greater than 0");
		ownerBalance = safeSub256(ownerBalance, amount);
		tenderData.getClient(contractId).transfer(amount);
	}

	//Tops up the pending balance of the smart contract for payments to client
	function topUpPaymentsToClient() external payable restricted {
		require(msg.value > 0, "Cannot top up 0");
		ownerBalance = safeAdd256(ownerBalance, msg.value);
	}

	//Collects fees from the client's penalty balance
	function collectFromClientPenaltyBalance(uint32 contractId, uint256 amount) public restricted {
		require(amount > 0, "Cannot collect 0");
		require(tenderData.getGuaranteePaid(contractId) || tenderData.getGuaranteeRequired(contractId) == 0, "Performance guarantee must be paid to collect from penalty balance");
		tenderData.setClientPenaltyBalance(contractId, safeSub256(tenderData.getClientPenaltyBalance(contractId), amount));
		owner.transfer(amount);
	}

	//Collects fees from the client's performance guarantee
	function collectFromClientGuaranteeBalance(uint32 contractId, uint256 amount) external restricted {
		require(amount > 0, "Cannot collect 0");
		require(tenderData.getGuaranteePaid(contractId) || tenderData.getGuaranteeRequired(contractId) == 0, "Performance guarantee must be paid before collection");
		tenderData.setClientGuaranteeBalance(contractId, safeSub256(tenderData.getClientGuaranteeBalance(contractId), amount));
		owner.transfer(amount);
	}

	//Collects the due penalty fees from the client balance for an order that has its deadline due
	function collectDuePenaltyFromClient(uint128 currentUtcDate, uint32 contractId, uint32 orderId) public restricted {
		ITenderData.OrderState state = tenderData.getOrderState(contractId, orderId);
		require(state == ITenderData.OrderState.Pending || state == ITenderData.OrderState.Cancelled, "Order state must be Pending or Cancelled to collect penalty");
		uint128 lastDate;
		if (state == ITenderData.OrderState.Cancelled)
			lastDate = tenderData.getOrderCancelledDate(contractId, orderId);
		else
			lastDate = currentUtcDate;
		uint128 daysOverdue = safeDiv128(safeSub128(lastDate, tenderData.getOrderDeadline(contractId, orderId)), 86400);
		uint128 daysUnpaidOverdue = safeSub128(daysOverdue, tenderData.getLastPenaltyDateCount(contractId, orderId));
		require(daysUnpaidOverdue > 0, "At least 1 day must pass to collect penalty");
		tenderData.setLastPenaltyDateCount(contractId, orderId, daysOverdue);
		collectFromClientPenaltyBalance(contractId, safeMul256(tenderData.getPenaltyPerDay(contractId), daysUnpaidOverdue));
	}

	//Marks a number of servers as delivered for the specified order
	function markServersDelivered(uint32 contractId, uint32 orderId, uint32 small, uint32 medium, uint32 large, bool payClientIfCompleted) external restricted
	orderActive(contractId, orderId) {
		uint32 newSmall = safeAdd32(tenderData.getSmallServersDelivered(contractId, orderId), small);
		uint32 newMedium = safeAdd32(tenderData.getMediumServersDelivered(contractId, orderId), medium);
		uint32 newLarge = safeAdd32(tenderData.getLargeServersDelivered(contractId, orderId), large);
		require(newSmall <= tenderData.getSmallServersOrdered(contractId, orderId), "Cannot exceed ordered small server amount");
		require(newMedium <= tenderData.getMediumServersOrdered(contractId, orderId), "Cannot exceed ordered medium server amount");
		require(newLarge <= tenderData.getLargeServersOrdered(contractId, orderId), "Cannot exceed ordered large server amount");
		tenderData.setTotalServersDelivered(contractId, orderId, newSmall, newMedium, newLarge);
		if (newSmall == tenderData.getSmallServersOrdered(contractId, orderId) &&
			newMedium == tenderData.getMediumServersOrdered(contractId, orderId) &&
			newLarge == tenderData.getLargeServersOrdered(contractId, orderId)) {
			tenderData.setOrderState(contractId, orderId, ITenderData.OrderState.Delivered);
			if (payClientIfCompleted)
				payClientForOrder(contractId, orderId);
		}
	}

	//Marks the order as paid (only call if the order was actually paid)
	function markOrderPaid(uint32 contractId, uint32 orderId) public restricted {
		require(tenderData.getOrderState(contractId, orderId) == ITenderData.OrderState.Delivered &&
			!tenderData.getOrderPaid(contractId, orderId), "Order must be delivered and unpaid to be paid");
		tenderData.setOrderPaid(contractId, orderId, true);
	}

	//Cancels the specified order. To collect fee, call collectFromPot() with the desired amount
	function cancelOrder(uint32 currentUtcDate, uint32 contractId, uint32 orderId, bool collectDuePenalty) external restricted
	orderActive(contractId, orderId) {
		tenderData.setOrderCancelledDate(contractId, orderId, currentUtcDate);
		tenderData.setOrderState(contractId, orderId, ITenderData.OrderState.Cancelled);
		tenderData.setTotalServersOrdered(contractId,
			safeSub32(tenderData.getTotalSmallServersOrdered(contractId), tenderData.getSmallServersOrdered(contractId, orderId)),
			safeSub32(tenderData.getTotalMediumServersOrdered(contractId), tenderData.getMediumServersOrdered(contractId, orderId)),
			safeSub32(tenderData.getTotalLargeServersOrdered(contractId), tenderData.getLargeServersOrdered(contractId, orderId)));
		if (collectDuePenalty)
			collectDuePenaltyFromClient(currentUtcDate, contractId, orderId);
	}

	//Changes the client wallet address of a contract to a new address
	function changeClient(uint128 currentUtcDate, uint32 contractId, address payable newClient) external restricted
	contractActiveCheckDate(currentUtcDate, contractId)
	validateAddress(newClient) {
		require(newClient != tenderData.getClient(contractId), "New client address is zero or the same as the old one");
		tenderData.setClient(contractId, newClient);
	}

	//Increases the min, medium and max server limits of the contract to the specified amount
	function updateContractMax(uint128 currentUtcDate, uint32 contractId, uint32 maxSmall, uint32 maxMedium, uint32 maxLarge) external restricted
	contractActiveCheckDate(currentUtcDate, contractId) {
		require(maxSmall >= tenderData.getMaxSmallServers(contractId) &&
				maxMedium >= tenderData.getMaxMediumServers(contractId) &&
				maxLarge >= tenderData.getMaxLargeServers(contractId), "Max server quantities can only be increased");
		tenderData.setContractMax(contractId, maxSmall, maxMedium, maxLarge);
	}

	//Extends the order deadline to the specified date
	function extendOrderDeadline(uint32 contractId, uint32 orderId, uint128 newUtcDeadline) external restricted
	orderActive(contractId, orderId) {
		require(tenderData.getOrderDeadline(contractId, orderId) < newUtcDeadline, "New order deadline cannot be older than the current order deadline");
		tenderData.setOrderDeadline(contractId, orderId, newUtcDeadline);
	}

	//Extends the contract deadline to the specified date
	function extendContractDeadline(uint32 contractId, uint128 newUtcDeadline) external restricted
	contractActive(contractId) {
		require(tenderData.getContractDeadline(contractId) < newUtcDeadline, "New contract deadline cannot be older than the current order deadline");
		tenderData.setContractDeadline(contractId, newUtcDeadline);
	}

	//Refunds the specified amount back to the owner
	function refundOwnerBalance(uint256 amount) external restricted {
		require(amount > 0, "Cannot collect 0");
		ownerBalance = safeSub256(ownerBalance, amount);
		owner.transfer(amount);
	}

	//Refunds the remaining performance guarantee balance to the client if the contract is expired or terminated
	function refundClientGuaranteeBalance(uint32 contractId) public restricted {
		ITenderData.ContractState state = tenderData.getContractState(contractId);
		require(state == ITenderData.ContractState.Expired || state == ITenderData.ContractState.Terminated, "Guarantee can be refunded only if contract is expired");
		uint256 balance = tenderData.getClientGuaranteeBalance(contractId);
		tenderData.setClientGuaranteeBalance(contractId, 0);
		tenderData.getClient(contractId).transfer(balance);
	}

	//Refunds the remaining pending penalty balance to the client
	function refundClientPenaltyBalance(uint32 contractId) public restricted {
		uint256 balance = tenderData.getClientPenaltyBalance(contractId);
		tenderData.setClientPenaltyBalance(contractId, 0);
		tenderData.getClient(contractId).transfer(balance);
	}

	//Marks the contract as expired (only if it is already expired)
	function markContractExpired(uint128 currentUtcDate, uint32 contractId, bool refundGuarantee, bool refundPenaltyBalance) external restricted
	contractActive(contractId) {
		require(tenderData.getContractDeadline(contractId) <= currentUtcDate, "Contract can be marked as expired only if deadline is reached");
		tenderData.setContractState(contractId, ITenderData.ContractState.Expired);
		uint256 balance = tenderData.getClientGuaranteeBalance(contractId);
		tenderData.setClientGuaranteeBalance(contractId, 0);
		tenderData.getClient(contractId).transfer(balance);
		if (refundGuarantee)
			refundClientGuaranteeBalance(contractId);
		if (refundPenaltyBalance)
			refundClientPenaltyBalance(contractId);
	}

	//Terminates the contract abnormally (possibly due to breach)
	function terminateContract(uint128 currentUtcDate, uint32 contractId, bool refundGuarantee, bool refundPenaltyBalance) external restricted
	contractActiveCheckDate(currentUtcDate, contractId) {
		tenderData.setContractState(contractId, ITenderData.ContractState.Terminated);
		if (refundGuarantee)
			refundClientGuaranteeBalance(contractId);
		if (refundPenaltyBalance)
			refundClientPenaltyBalance(contractId);
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
		require(result >= a, "Wraparound occurred in addition");
		return result;
	}

	//Adds two positive integers
	function safeAdd256(uint256 a, uint256 b) private pure returns (uint256) {
		uint256 result = a + b;
		require(result >= a, "Wraparound occurred in addition");
		return result;
	}

	//Subtracts a small positive integer from a larger positive integer
	function safeSub32(uint32 a, uint32 b) private pure returns (uint32) {
		require(b <= a, "Wraparound occurred in subtraction");
		return a - b;
	}

	//Subtracts a small positive integer from a larger positive integer
	function safeSub128(uint128 a, uint128 b) private pure returns (uint128) {
		require(b <= a, "Wraparound occurred in subtraction");
		return a - b;
	}

	//Subtracts a small positive integer from a larger positive integer
	function safeSub256(uint256 a, uint256 b) private pure returns (uint256) {
		require(b <= a, "Wraparound occurred in subtraction");
		return a - b;
	}

	//Multiplies two positive integers
	function safeMul256(uint256 a, uint256 b) private pure returns (uint256) {
		uint256 result = a * b;
		require(a == 0 || result / a == b, "Wraparound occurred in multiplication");
		return result;
	}

	//Divides a positive integer by another positive integer
	function safeDiv128(uint128 a, uint128 b) private pure returns (uint128) {
		require(b > 0, "Cannot divide by 0");
		return a / b;
	}
}