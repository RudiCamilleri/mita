# Tender Smart Contract Structure

The Tender blockchain architecture is composed of 2 main modular smart contracts:

```
       Owner (Deployer's Wallet)
                   │
                   │
                   ↓
   TenderLogic (Business Logic Layer)
                   │                ↘ references
                   │                             TenderDataInterface
                   ↓                ↗ implements
TenderData (Storage & Data Access Layer)
```

where TenderLogic and TenderData are hot-swappable with the aim of being upgradeable if necessary. Every layer can only be invoked by the layer above it for security purposes. The data is read-only to outsiders through public functions offered in TenderData, and the owner can only modify the parts of the data that can be modified through the provided TenderLogic functions. This is to prevent tampering or erroneous modification.

The data structures and the functions related to data access are defined in TenderDataInterface. The interface should be designed to be set in stone and unmodified as much as possible after being deployed into a public blockchain environment.

The design leverages separation of concern (modularity), reduced dependency coupling, planned upgradability and development flexibility. The contracts contain various checks and balances to avoid unwanted behaviour and block unauthorised callers.