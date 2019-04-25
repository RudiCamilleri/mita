pragma solidity >=0.5.0;

import "./TenderDataInterface.sol";

//Version 0.1
//This is the contract data storage layer
contract TenderData is TenderDataInterface {
	address public tenderLogic; //the parent TenderLogic smart contract instance
	mapping(uint32 => TenderDataInterface.Contract) contracts; //the legal contracts that are represented in this instance

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

	function getContractState(uint32 contractId) external view returns (TenderDataInterface.ContractState) {
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

	function getContractDeadline(uint32 contractId) external view returns (uint128) {
		return contracts[contractId].attr.deadline;
	}

	//====================== Order Data ===========================
	function getOrderState(uint32 contractId, uint32 orderId) external view returns (TenderDataInterface.OrderState) {
		return contracts[contractId].orders[orderId].state;
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

	//Migrates the data from an old TenderDataInterface instance to a new one
	function migrateData(address oldTenderDataAddress) external restricted {
	}

	//Adds a business contract instance to the smart contract
	function addContract(uint32 contractId, address payable client, uint128[] calldata params128, uint32[] calldata params32) external restricted {
		contracts[contractId] = TenderDataInterface.Contract({
			client: client,
			state: TenderDataInterface.ContractState.Active,
			smallServerPrice: params128[0],
			mediumServerPrice: params128[1],
			largeServerPrice: params128[2],
			penaltyPerDay: params128[3],
			guaranteeRequired: params128[4],
			guaranteePaid: false,
			attr: TenderDataInterface.Attributes({
				small: 0,
				medium: 0,
				large: 0,
				maxSmall: params32[0],
				maxMedium: params32[1],
				maxLarge: params32[2],
				deadline: params128[5]
			})
		});
	}

	//Sets the contract client address
	function setClient(uint32 contractId, address payable newClient) external restricted {
		contracts[contractId].client = newClient;
	}

	//Sets the guarantee as paid
	function setGuaranteePaid(uint32 contractId) external restricted {
		contracts[contractId].guaranteePaid = true;
	}

	//Sets the contract deadline
	function setContractDeadline(uint32 contractId, uint128 newUtcDeadline) external restricted {
		contracts[contractId].attr.deadline = newUtcDeadline;
	}

	//Sets the contract state
	function setContractState(uint32 contractId, TenderDataInterface.ContractState newState) external restricted {
		contracts[contractId].state = newState;
	}

	//Adds a new order to the specified contract
	function addOrder(uint32 contractId, uint32 orderId, uint128[] calldata params128, uint32[] calldata params32) external restricted {
		contracts[contractId].orders[orderId] = TenderDataInterface.Order({
			state: TenderDataInterface.OrderState.Pending,
			attr: TenderDataInterface.Attributes({
				small: 0,
				medium: 0,
				large: 0,
				maxSmall: params32[0],
				maxMedium: params32[1],
				maxLarge: params32[2],
				deadline: params128[0]
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
	function setOrderState(uint32 contractId, uint32 orderId, TenderDataInterface.OrderState newState) external restricted {
		contracts[contractId].orders[orderId].state = newState;
	}

	//Kills the service
	function endService(address payable targetWallet) external restricted {
		selfdestruct(targetWallet);
	}
}