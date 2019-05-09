# Testing

Testing snippets are provided below for easy debugging and code demonstrations.

### i. Nethereum

1. Double-click `run-nethereum.bat`
2. If the script launches properly and a "Ready!" message appears, then one can start invoking smart contract functionality from the console

Here are a few sample commands you can use to quickly interact with the smart contract:

	Write Functions:

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
	TenderLogic.CallWrite("createOrder", Wallet, ContractUtil.Utc, 123, 12, 0, 3, 1, ContractUtil.Utc, ContractUtil.ToUtc(DateTime.UtcNow.AddYears(1)));

	//Gets the current owner wallet balance
	Wallet.Balance.Await()

	//Tops up the smart contract's balance by 1000000wei to be able to pay the client
	TenderLogic.CallWrite("topUpPaymentsToClient", Wallet, ConfigParams.DefaultGas, ConfigParams.DefaultGasPrice, new HexBigInteger("1000000")).Await();

	//Marks that 0 small, 3 medium and 1 large servers have been delivered and accepted for order #12 for contract #123, and to pay the client if the order is completed
	TenderLogic.CallWrite("markServersDelivered", Wallet, 123, 12, 0, 3, 1, true).Await();

	//Marks order #12 for contract #123 as cancelled
	TenderLogic.CallWrite("cancelOrder", ContractUtil.Utc, 123, 12, true).Await();

	Read Functions:

	//Gets the state of order #12 for contract #123
	TenderData.CallRead("getOrderState", 123, 12).Await();

	//Gets the small server price for contract #123
	TenderData.CallRead("getSmallServerPrice", 123).Await();

### ii. Remix

1. Double-click `run-remix.bat`
2. Compile then deploy TenderData
3. Compile then deploy TenderLogic
4. Call `replaceTenderData(TenderDataAddress, false, false)` where TenderDataAddress should be replaced with the address of TenderData
5. Call createContract() with the following parameters:
	- contractId: 123
	- client: ClientWallet (can be copied from address 1 in ganache-output.txt)
	- params128: [10, 20, 30, 2, 1, 1555337743, 1655337743]
	- params32: [30, 30, 30]