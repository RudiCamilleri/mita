pragma solidity >=0.5.0;

import "./TenderDataInterface.sol";

//Version 0.1
//This is the contract data storage layer
contract TenderData is TenderDataInterface {
	address public tenderLogic; //the parent TenderLogic smart contract instance
	mapping(uint32 => TenderDataInterface.TenderContract) contracts; //the legal contracts that are represented in this instance

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

	//=======================================================
	//== FUNCTION IMPLEMENTATIONS ARE TO BE INSERTED BELOW ==
	//==    ALL FUNCTIONS MUST BE MARKED AS RESTRICTED!    ==
	//=======================================================
	//Functions that are used in the smart contract itself and are to be exported should be marked as public,
	//whereas functions that are only called from outside should be marked as external

	//Sets or replaces the TenderLogic smart contract implementation
	function replaceTenderLogic(address newTenderLogicAddress) external restricted {
		tenderLogic = newTenderLogicAddress;
	}

	//Adds the contract to the contracts dictionary a contract instance (should be changed to external when compiler support starts to exist)
	function addContract(uint128[] calldata params128, uint32[] calldata params32, uint16[] calldata params16) external restricted {
		require(contracts[params32[0]].creationDate == 0, "Contract already exists with that ID");
		contracts[params32[0]] = TenderDataInterface.TenderContract({
			state: TenderDataInterface.ContractState.Active,
			smallServerPrice: params128[0],
			mediumServerPrice: params128[1],
			largeServerPrice: params128[2],
			daysForDelivery: params16[0],
			penaltyPerDay: params128[3],
			creationDate: params128[4],
			expiryDate: params128[5],
			operatorId: params32[1],
			guaranteeRequired: params128[6]
		});
	}

	//Adds a new order to the speicfied contract
	function addOrder(uint32 contractId, uint32 orderId, uint16 small, uint16 medium, uint16 large) external restricted {
		require(contracts[contractId].creationDate != 0 && contracts[contractId].orders[orderId].small == 0 && contracts[contractId].orders[orderId].medium == 0 && contracts[contractId].orders[orderId].large == 0, "The specified contract is empty or an order already exists with that ID");
		contracts[contractId].orders[orderId] = TenderDataInterface.Order({
			state: TenderDataInterface.OrderState.Pending,
			small: small,
			medium: medium,
			large: large
		});
	}

	//Migrates the data from an old TenderDataInterface instance to a new one
	function migrateData(address oldTenderDataAddress) external restricted {
	}

	//Sets the order state
	function setOrderState(uint32 contractId, uint32 orderId, TenderDataInterface.OrderState newState) external restricted {
		contracts[contractId].orders[orderId].state = newState;
	}

	//Marks the contract as expired
	function markExpired(uint32 contractId) external restricted {
		contracts[contractId].state = TenderDataInterface.ContractState.Expired;
		//delete contracts[contractId];
	}

	//Kills the service
	function endService(address payable targetWallet) external restricted {
		selfdestruct(targetWallet);
	}

	//=============== PUBLIC READ-ONLY SECTION ====================
	function getContractState(uint32 contractId) external view returns (TenderDataInterface.ContractState) {
		return contracts[contractId].state;
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

	function getDaysForDelivery(uint32 contractId) external view returns (uint16) {
		return contracts[contractId].daysForDelivery;
	}

	function getPenaltyPerDay(uint32 contractId) external view returns (uint128) {
		return contracts[contractId].penaltyPerDay;
	}

	function getCreationDate(uint32 contractId) external view returns (uint128) {
		return contracts[contractId].creationDate;
	}

	function getExpiryDate(uint32 contractId) external view returns (uint128) {
		return contracts[contractId].expiryDate;
	}

	function getOperatorId(uint32 contractId) external view returns (uint32) {
		return contracts[contractId].operatorId;
	}

	function getGuaranteeRequired(uint32 contractId) external view returns (uint128) {
		return contracts[contractId].guaranteeRequired;
	}

	//Orders
	function getOrderState(uint32 contractId, uint32 orderId) external view returns (TenderDataInterface.OrderState) {
		return contracts[contractId].orders[orderId].state;
	}

	function getSmallServersOrdered(uint32 contractId, uint32 orderId) external view returns (uint16) {
		return contracts[contractId].orders[orderId].small;
	}

	function getMediumServersOrdered(uint32 contractId, uint32 orderId) external view returns (uint16) {
		return contracts[contractId].orders[orderId].medium;
	}

	function getLargeServersOrdered(uint32 contractId, uint32 orderId) external view returns (uint16) {
		return contracts[contractId].orders[orderId].large;
	}
}