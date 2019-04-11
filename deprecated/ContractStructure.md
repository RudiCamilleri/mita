# Tender Smart Contract Structure

The Tender blockchain architecture is composed of 3 main modular smart contracts:

```
       Owner (Deployer's Wallet)
                   │
                   │
                   ↓
   TenderAPI (Backend Interface Layer)
                   │                ↘ implements and references 
                   │           TenderBLLInterface
                   ↓                ↗ implements
   TenderBLL (Business Logic Layer)
                   │                ↘ references
                   │           TenderDataInterface
                   ↓                ↗ implements
TenderData (Storage & Data Access Layer)
```

where TenderAPI, TenderBLL and TenderData are hot-swappable with the aim of being upgradeable if necessary. Every layer can only be invoked by the layer above it for security purposes. The data is read-only to outsiders, and the owner can only modify the parts of the data that can be modified through the provided TenderAPI functions. This is to prevent tampering or erroneous modification.

The data structures and the functions related to data access are defined in TenderDataInterface, and the functions related to the operational logic and contract module versioning are defined in TenderBLLInterface. The interfaces should be designed to be set in stone and unmodified after being deployed into a public blockchain environment.

The design leverages separation of concern (modularity), reduced dependency coupling, planned upgradability and development flexibility. The contracts contain various checks and balances to avoid unwanted behaviour and block unauthorised callers.