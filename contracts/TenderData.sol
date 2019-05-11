pragma solidity >=0.5.0;

import "./ITenderData.sol";
import "./ITenderDataStructs.sol";

//Version 0.1
//This is the contract data storage layer
contract TenderData is ITenderData {
	address public tenderLogic; //the parent TenderLogic smart contract instance
	mapping(uint32 => ITenderDataStructs.Contract) contracts; //the legal contracts that are represented in this instance

	//Initializes the smart contract
	constructor(address tenderLogicAddress) public {
		require(tenderLogicAddress != address(0), "tenderLogicAddress cannot be 0 in TenderData constructor");
		tenderLogic = tenderLogicAddress;
	}

	//Makes sure that the function can only be called by TenderLogic parent
	modifier restricted() {
		require(msg.sender == tenderLogic, "Illegitimate caller in TenderData");
		_;
	}

	//=============== PUBLIC READ-ONLY SECTION ====================
	//==================== Contract Data ==========================
	function getClient(uint32 contractId) external view returns (address payable) {
		return contracts[contractId].client;
	}

	function getSmallServerPrice(uint32 contractId) external view returns (uint128) {
		return contracts[contractId].smallServerPrice;
	}

	function getMediumServerPrice(uint32 contractId) external view returns (uint128) {
		return contracts[contractId].mediumServerPrice;
	}

	function getLargeServerPrice(uint32 contractId) external view returns (uint128) {
		return contracts[contractId].largeServerPrice;
	}

	function getPenaltyPerDay(uint32 contractId) external view returns (uint128) {
		return contracts[contractId].penaltyPerDay;
	}

	function getGuaranteeRequired(uint32 contractId) external view returns (uint128) {
		return contracts[contractId].guaranteeRequired;
	}

	function getGuaranteePaid(uint32 contractId) external view returns (bool) {
		return contracts[contractId].guaranteePaid;
	}

	function getClientGuaranteeBalance(uint32 contractId) external view returns (uint256) {
		return contracts[contractId].clientGuaranteeBalance;
	}

	function getClientPenaltyBalance(uint32 contractId) external view returns (uint256) {
		return contracts[contractId].clientPenaltyBalance;
	}

	function getContractState(uint32 contractId) external view returns (ITenderData.ContractState) {
		return contracts[contractId].state;
	}

	function getTotalSmallServersOrdered(uint32 contractId) external view returns (uint32) {
		return contracts[contractId].attr.small;
	}

	function getTotalMediumServersOrdered(uint32 contractId) external view returns (uint32) {
		return contracts[contractId].attr.medium;
	}

	function getTotalLargeServersOrdered(uint32 contractId) external view returns (uint32) {
		return contracts[contractId].attr.large;
	}

	function getMaxSmallServers(uint32 contractId) external view returns (uint32) {
		return contracts[contractId].attr.maxSmall;
	}

	function getMaxMediumServers(uint32 contractId) external view returns (uint32) {
		return contracts[contractId].attr.maxMedium;
	}

	function getMaxLargeServers(uint32 contractId) external view returns (uint32) {
		return contracts[contractId].attr.maxLarge;
	}

	function getContractStartDate(uint32 contractId) external view returns (uint128) {
		return contracts[contractId].attr.startDate;
	}

	function getContractDeadline(uint32 contractId) external view returns (uint128) {
		return contracts[contractId].attr.deadline;
	}

	//====================== Order Data ===========================
	function getOrderState(uint32 contractId, uint32 orderId) external view returns (ITenderData.OrderState) {
		return contracts[contractId].orders[orderId].state;
	}

	function getOrderPaid(uint32 contractId, uint32 orderId) external view returns (bool) {
		return contracts[contractId].orders[orderId].orderPaid;
	}

	function getOrderCancelledDate(uint32 contractId, uint32 orderId) external view returns (uint128) {
		return contracts[contractId].orders[orderId].cancelledDate;
	}

	function getLastPenaltyDateCount(uint32 contractId, uint32 orderId) external view returns (uint128) {
		return contracts[contractId].orders[orderId].lastPenaltyDateCount;
	}

	function getSmallServersDelivered(uint32 contractId, uint32 orderId) external view returns (uint32) {
		return contracts[contractId].orders[orderId].attr.small;
	}

	function getMediumServersDelivered(uint32 contractId, uint32 orderId) external view returns (uint32) {
		return contracts[contractId].orders[orderId].attr.medium;
	}

	function getLargeServersDelivered(uint32 contractId, uint32 orderId) external view returns (uint32) {
		return contracts[contractId].orders[orderId].attr.large;
	}

	function getSmallServersOrdered(uint32 contractId, uint32 orderId) external view returns (uint32) {
		return contracts[contractId].orders[orderId].attr.maxSmall;
	}

	function getMediumServersOrdered(uint32 contractId, uint32 orderId) external view returns (uint32) {
		return contracts[contractId].orders[orderId].attr.maxMedium;
	}

	function getLargeServersOrdered(uint32 contractId, uint32 orderId) external view returns (uint32) {
		return contracts[contractId].orders[orderId].attr.maxLarge;
	}

	function getOrderCreationDate(uint32 contractId, uint32 orderId) external view returns (uint128) {
		return contracts[contractId].orders[orderId].attr.startDate;
	}

	function getOrderDeadline(uint32 contractId, uint32 orderId) external view returns (uint128) {
		return contracts[contractId].orders[orderId].attr.deadline;
	}

	//=======================================================
	//==================== DATA SECTION =====================
	//
	//== FUNCTION IMPLEMENTATIONS ARE TO BE INSERTED BELOW ==
	//==    ALL FUNCTIONS MUST BE MARKED AS RESTRICTED!    ==
	//=======================================================
	//Functions that are used in the smart contract itself and are to be exported should be marked as public,
	//whereas functions that are only called from outside should be marked as external

	//Sets or replaces the TenderLogic smart contract implementation
	function replaceTenderLogic(address newTenderLogicAddress) external restricted {
		tenderLogic = newTenderLogicAddress;
	}

	//Migrates the data from an old ITenderData instance to a new one
	function migrateData(address oldTenderDataAddress) external restricted {
	}

	//Adds a business contract instance to the smart contract
	function addContract(uint32 contractId, address payable client, uint128[] calldata params128, uint32[] calldata params32) external restricted {
		contracts[contractId] = ITenderDataStructs.Contract({
			client: client,
			state: ITenderData.ContractState.Active,
			smallServerPrice: params128[0],
			mediumServerPrice: params128[1],
			largeServerPrice: params128[2],
			penaltyPerDay: params128[3],
			guaranteeRequired: params128[4],
			clientGuaranteeBalance: 0,
			clientPenaltyBalance: 0,
			guaranteePaid: false,
			attr: ITenderDataStructs.Attributes({
				small: 0,
				medium: 0,
				large: 0,
				maxSmall: params32[0],
				maxMedium: params32[1],
				maxLarge: params32[2],
				startDate: params128[5],
				deadline: params128[6]
			})
		});
	}

	//Sets the total number of servers ordered so far for the specified contract
	function setTotalServersOrdered(uint32 contractId, uint32 small, uint32 medium, uint32 large) external restricted {
		contracts[contractId].attr.small = small;
		contracts[contractId].attr.medium = medium;
		contracts[contractId].attr.large = large;
	}

	//Sets the total number of servers delivered so far for the specified order
	function setTotalServersDelivered(uint32 contractId, uint32 orderId, uint32 small, uint32 medium, uint32 large) external restricted {
		contracts[contractId].orders[orderId].attr.small = small;
		contracts[contractId].orders[orderId].attr.medium = medium;
		contracts[contractId].orders[orderId].attr.large = large;
	}

	//Sets the contract client address
	function setClient(uint32 contractId, address payable newClient) external restricted {
		contracts[contractId].client = newClient;
	}

	//Sets the guarantee as paid
	function setGuaranteePaid(uint32 contractId) external restricted {
		contracts[contractId].guaranteePaid = true;
	}

	//Sets the balance of the client's performance guarantee to the specified amount
	function setClientGuaranteeBalance(uint32 contractId, uint256 newValue) external restricted {
		contracts[contractId].clientGuaranteeBalance = newValue;
	}

	//Sets the balance of the client's penalty to the specified amount
	function setClientPenaltyBalance(uint32 contractId, uint256 newValue) external restricted {
		contracts[contractId].clientPenaltyBalance = newValue;
	}

	//Sets the contract deadline
	function setContractDeadline(uint32 contractId, uint128 newUtcDeadline) external restricted {
		contracts[contractId].attr.deadline = newUtcDeadline;
	}

	//Sets the contract state
	function setContractState(uint32 contractId, ITenderData.ContractState newState) external restricted {
		contracts[contractId].state = newState;
	}

	//Adds a new order to the specified contract
	function addOrder(uint32 contractId, uint32 orderId, uint32 small, uint32 medium, uint32 large, uint128 startDate, uint128 deadline) external restricted {
		contracts[contractId].orders[orderId] = ITenderDataStructs.Order({
			state: ITenderData.OrderState.Pending,
			cancelledDate: 0,
			lastPenaltyDateCount: 0,
			orderPaid: false,
			attr: ITenderDataStructs.Attributes({
				small: 0,
				medium: 0,
				large: 0,
				maxSmall: small,
				maxMedium: medium,
				maxLarge: large,
				startDate: startDate,
				deadline: deadline
			})
		});
	}

	//Sets the maximum server quantities for the specified contract
	function setContractMax(uint32 contractId, uint32 maxSmall, uint32 maxMedium, uint32 maxLarge) external restricted {
		contracts[contractId].attr.maxSmall = maxSmall;
		contracts[contractId].attr.maxMedium = maxMedium;
		contracts[contractId].attr.maxLarge = maxLarge;
	}

	//Sets the order deadline
	function setOrderDeadline(uint32 contractId, uint32 orderId, uint128 newUtcDeadline) external restricted {
		contracts[contractId].orders[orderId].attr.deadline = newUtcDeadline;
	}

	//Sets the order state
	function setOrderState(uint32 contractId, uint32 orderId, ITenderData.OrderState newState) external restricted {
		contracts[contractId].orders[orderId].state = newState;
	}

	//Sets whether the order was paid
	function setOrderPaid(uint32 contractId, uint32 orderId, bool paid) external restricted {
		contracts[contractId].orders[orderId].orderPaid = paid;
	}

	//Adjusts the server prices (for inflation)
	function adjustValues(uint32 contractId, uint128 small, uint128 medium, uint128 large, uint128 penaltyPerDay) external restricted {
		contracts[contractId].smallServerPrice = small;
		contracts[contractId].mediumServerPrice = medium;
		contracts[contractId].largeServerPrice = large;
		contracts[contractId].penaltyPerDay = penaltyPerDay;
	}

	//Sets the date when the order was cancelled
	function setOrderCancelledDate(uint32 contractId, uint32 orderId, uint128 cancelledDate) external restricted {
		contracts[contractId].orders[orderId].cancelledDate = cancelledDate;
	}

	//Sets the count of the number of days since the order deadline has passed
	function setLastPenaltyDateCount(uint32 contractId, uint32 orderId, uint128 lastPenaltyDateCount) external restricted {
		contracts[contractId].orders[orderId].lastPenaltyDateCount = lastPenaltyDateCount;
	}

	//Kills the current TenderData contract and transfers its Ether to the owner
	function destroyTenderData(address payable targetWallet) external restricted {
		selfdestruct(targetWallet);
	}
}