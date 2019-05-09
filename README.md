# Tender Smart Contracts

Smart contract environment setup is documented here: https://github.com/mathusummut/tender/blob/master/EnvSetup.md

### Scope & Purpose

The purpose of this smart contract implementation is to serve as a prototype for the business process of issuing tenders for MITA servers, taking care of order state management, payments to the Economic Operator (referred to as "client" in the smart contract), and collection of performance guarantee and penalty money from the Economic Operator ("client").

The smart contract is intended to be invoked by the backend of a website that handles the state management, where clients and officers would be able to log in and perform the necessary actions to view and update the state of the smart contract depending on their authorization. Payments to the smart contract by the client, however, should be done manually from outside the website domain, to make sure that the their private keys are never shared with the service for privacy and security reasons.

The smart contract handles payments for servers that are marked as ordered. Order states can be changed only by the authorized officers in charge, who will be given access to the services provided by the management server. All states, actions, payments and data in the smart contract will be publicly accessibly and visible in the Ethereum blockchain ledger. This will introduce greater transparency of the tender process to the public, which is one of the possible perks of smart contracts. Another perk would be the ease and speed of payment, where payments can be directly passed without any invovement of a central middle-man entity.

### Structure & Reasoning

The Tender blockchain architecture is composed of 2 main modular smart contracts:

```
       Owner (Deployer's Wallet)
                   │
                   │
                   ↓
   TenderLogic (Business Logic Layer)
                   │                ↘ references ↘
                   │                               ITenderData
                   ↓                ↗ implements ↗
TenderData (Storage & Data Access Layer) → (internally uses structs defined in ITenderDataStructs)
```

where TenderLogic and TenderData are hot-swappable with the aim of being upgradeable if necessary, which can be done by calling the `replaceTenderData` or `replaceTenderLogic` functions in the TenderLogic smart contract. Every layer can only be invoked by the layer above it for security purposes. The data is read-only to outsiders through public functions offered in TenderData, and the owner can only modify the parts of the data that can be modified through the provided TenderLogic functions. This is to prevent external tampering or erroneous modification, by seperating read operations from write operations.

The data structures and the functions related to data access are defined in ITenderData. The interface should be designed to be set in stone and unmodified as much as possible after being deployed into a public blockchain environment.

The design leverages separation of concern (modularity), reduced dependency coupling, planned upgradability and development flexibility. The contracts contain various checks and balances to avoid unwanted behaviour and block unauthorised callers.

The TenderLogic and TenderData smart contracts are designed to handle transactions for all relevant business contracts, meaning that transactions for all clients will be managed by the same instances of TenderLogic and TenderData. This is so that if a bug is found in the smart contract logic, they can be easily fixed and upgraded for all clients simultaneously as they will be using the same instances.

Side-note: The bytecodes of the contracts, when compiled, are larger than the public Ethereum smart contract size limit of 24KB per contract.
On public deployment, reason strings should be removed to reduce contract size. If that is not enough to bring the contracts under 24KB, the contract structure can be modified to use the ERC1538 Transparent Contract Standard, which is basically a technique of splitting functions into multiple contracts and using delegates athat redirect function calls through a gateway contract, like a multiplexor (one to many).

### Process Flow

##### Action Sequence

The smart contract is designed such that operations are to intended to follow the sequence outlined below, which should reflect a similar flow to the current business process. The steps for interacting with the smart contract are:

1. First, the TenderLogic and TenderData contracts have to be deployed
2. The replaceTenderData() function in TenderLogic should be called to point to the address of TenderData, immediately after deployment
3. To create a new business contract instance, call createContract() in TenderLogic with the appropriate parameters, whose description is outlined in the addContract() function in TenderData
4. Then, the client is to call payGuarantee() with a transfer of the Ether required by the contract
5. Then, the owner can call createOrder() to create an order. createOrder() cannot be called unless the client has paid the performance guarantee
6. When any servers arrive and are accepted, the owner calls markServersDelivered() and specifies how many small, medium and large servers have arrived for a particular order
7. To pay the client for the order, the owner has to top up the smart contract balance by calling the topUpPaymentsToClient() function

##### Configurable Parameters

- transferOwner: Transfers the current TenderLogic smart contract to another owner
- replaceTenderLogic: Replaces the current TenderLogic smart contract implementation (for upgrading or bug fixes)
- replaceTenderData: Sets or replaces the ITenderData smart contract implementation (for initialization or upgrading)
- changeClient: Changes the client wallet address of a contract to a new address
- updateContractMax: Increases the min, medium and max server limits of the contract to the specified amount
- collectDuePenaltyFromClient: Collects the due penalty fees from the client balance for an order that has its deadline due
- collectFromClientPenaltyBalance: Collects fees from the client's penalty balance
- collectFromClientGuaranteeBalance: Collects fees from the client's performance guarantee
- refundOwnerBalance: Refunds the specified amount back to the owner
- refundClientGuaranteeBalance: Refunds the remaining performance guarantee balance to the client if the contract is expired or terminated
- refundClientPenaltyBalance: Refunds the remaining pending penalty balance to the client
- payClientForOrder: Pays the client for the specified order delivery
- payClient: Pays the client the specified amount (use only for special cases)
- topUpPenalty: The client calls this function to top up the penalty balance
- topUpPaymentsToClient: Tops up the pending balance of the smart contract for payments to client
- extendOrderDeadline: Extends the order deadline to the specified date
- extendContractDeadline: Extends the contract deadline to the specified date

##### Options for termination

- cancelOrder: Cancels the specified order
- markOrderPaid: Marks the order as paid (only call if the order was actually paid)
- markContractExpired: Marks the contract as expired (only if it is already expired)
- terminateContract: Terminates the contract abnormally (possibly due to breach)
- destroyTenderData: Kills the current TenderData contract and transfers its Ether to the owner
- destroyTenderLogic: Kills the current TenderLogic contract and transfers its Ether to the owner

### Deployment & Testing

The easiest way to test the smart contracts using C# is by using the Nethereum open-source library. After installing the necessary dependencies outlined in [EnvSetup.md](https://github.com/mathusummut/tender/blob/master/EnvSetup.md), one can simply launch `run-nethereum.bat` to deploy and test the smart contract.

Here are a few sample commands you can use to quickly interact with the smart contract:

    //Gets the small server price for contract #123
    TenderData.CallRead("getSmallServerPrice", 123).Await();

    //Creates a new business contract instance within the smart contract
    TenderLogic.CallWrite("createContract", Wallet, 123, ClientWallet,
		new BigInteger[] {
			10, 20, 30, //smallServerPrice, mediumServerPrice, largeServerPrice
			2, //penaltyPerDay
			1, //guaranteeRequired
			ContractUtil.Utc, //start date in UTC time
			ContractUtil.ToUtc(DateTime.UtcNow.AddYears(1)) //expiry date in UTC time
		}, new uint[] {
			30, 30, 30 //max small, medium, large
		}
	).Await();

	//Creates a new order with ID #12 for contract #123 of 0 small servers, 3 medium servers and 1 large
	TenderLogic.CallWrite("createOrder", Wallet, ContractUtil.Utc, 123, 12, 0, 3, 1, ContractUtil.Utc, ContractUtil.ToUtc(DateTime.UtcNow.AddYears(1)))

	//Tops up the smart contract's balance by 1000000wei to be able to pay the client
	TenderLogic.CallWrite("topUpPaymentsToClient", Wallet, ConfigParams.DefaultGas, ConfigParams.DefaultGasPrice, new HexBigInteger("1000000")).Await();

	//Marks that 0 small, 3 medium and 1 large servers have been delivered and accepted for order #12 for contract #123, and to pay the client if the order is completed
	TenderLogic.CallWrite("markServersDelivered", Wallet, 123, 12, 0, 3, 1, true).Await();

	//Gets the state of order #12 for contract #123
	TenderData.CallRead("getOrderState", 123, 12).Await();

	//Marks order #12 for contract #123 as cancelled
	TenderLogic.CallWrite("cancelOrder", ContractUtil.Utc, 123, 12, true).Await();

## Appendix

PS: The best way to use the CallRead<T> function would be to give it a C# type that corresponds with the expected return type of the function in the smart contract, similar to this format:

     TenderData.CallRead<BigInteger>("getSmallServerPrice", 123);

where the type parameter is provided in the angle brackets `<>`, and if omitted falls back to a generic `<object>` type. Here is a list of recommended type mappings that are most common in Nethereum:

    Solidity   │    C#
    ───────────│────────────────────────────
    address    │    string
    bool       │    bool
    int8       │    sbyte
    int16      │    short
    int32      │    int
    int64      │    long
    int128     │    BigInteger/HexBigInteger
    int256     │    BigInteger/HexBigInteger
    uint8      │    byte
    uint16     │    ushort
    uint32     │    uint
    uint64     │    ulong
    uint128    │    BigInteger/HexBigInteger
    uint256    │    BigInteger/HexBigInteger
    string     │    string
    bytes      │    byte[]
