## Tender Smart Contracts

#### Structure & Reasoning

The Tender blockchain architecture is composed of 2 main modular smart contracts:

```
       Owner (Deployer's Wallet)
                   │
                   │
                   ↓
   TenderLogic (Business Logic Layer)
                   │                ↘ references ↘
                   │                               TenderDataInterface
                   ↓                ↗ implements ↗
TenderData (Storage & Data Access Layer)
```

where TenderLogic and TenderData are hot-swappable with the aim of being upgradeable if necessary, which can be done by calling the `replaceTenderData` or `replaceTenderLogic` functions in the TenderLogic smart contract. Every layer can only be invoked by the layer above it for security purposes. The data is read-only to outsiders through public functions offered in TenderData, and the owner can only modify the parts of the data that can be modified through the provided TenderLogic functions. This is to prevent tampering or erroneous modification.

The data structures and the functions related to data access are defined in TenderDataInterface. The interface should be designed to be set in stone and unmodified as much as possible after being deployed into a public blockchain environment.

The design leverages separation of concern (modularity), reduced dependency coupling, planned upgradability and development flexibility. The contracts contain various checks and balances to avoid unwanted behaviour and block unauthorised callers.

The TenderLogic and TenderData smart contracts are designed to handle transactions for all relevant business contracts, meaning that transactions for all clients will be managed by the same instances of TenderLogic and TenderData. This is so that if a bug is found in the smart contract logic, they can be easily fixed and upgraded for all clients simultaneously as they will be using the same instances.

### Deployment & Testing

The easiest way to test the smart contracts using C# is by using the Nethereum open-source library. After installing the necessary dependencies outlined in [Readme.md](https://github.com/mathusummut/tender/blob/master/README.md), one can simply launch `run-nethereum.bat` to deploy and test the smart contract.

Here are a few sample commands you can use to quickly interact with the smart contract:

    //Gets the small server price for contract #123
    TenderData.CallRead("getSmallServerPrice", 123).Await();

    //Creates a new business contract instance within the smart contract
    TenderLogic.CallWrite("createContract", Wallet, new BigInteger[] {
        10, 20, 30, //smallServerPrice, mediumServerPrice, largeServerPrice
        2, //penaltyPerDay
        21102018, //creationDate in UTC time
        21102020, //expiryDate in UTC time
        1, //guaranteeRequired
    }, new uint[] {
        123, //contractId
        10987, //operatorId
    }, new ushort[] { 1 /*daysForDelivery*/ }).Await();

    //Creates a new order with ID #12 for contract #123 of 0 small servers, 3 medium servers and 1 large
    TenderLogic.CallWrite("createOrder", Wallet, 123, 12, 0, 3, 1);

    //Creates a new order with ID #12 for contract #123 of 0 small servers, 3 medium servers and 1 large
    TenderLogic.CallWrite("createOrder", Wallet, 123, 12, 0, 3, 1);

    //Gets the state of order #12 for contract #123
    TenderData.CallRead("getOrderState", 123, 12).Await();

    //Marks order #12 for contract #123 as cancelled
    TenderLogic.CallWrite("cancelOrder", 123, 12).Await();

### Appendix

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