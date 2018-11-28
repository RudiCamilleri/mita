# MITA Smart Contract

## To set up local development environment and testing of Ethereum smart contracts:

1. Install nodejs

2. Install required global packages:
	npm install -g windows-build-tools
	npm install -g truffle
	npm install -g ganache-cli

3. Install Visual Studio Code, and download the Solidity plugin.

4. Install Git and run the following command to obtain the latest development files:

    git clone https://github.com/mathusummut/tender.git

5. Open the main folder in Visual Studio Code

## Running the smart contract:

6. Launch command prompt window and write `ganache-cli` and press enter.

7. In the ganache-cli output under `Available Accounts`, copy the address at (0) and paste it in the `truffle-config.js` file next to the `from` key

8.In the "Terminal" tab in VS Code, enter the following:

    truffle m --reset      //m stands for migrate
    truffle con            //con stands for console

9. Copy and paste the following line into the truffle console and press enter (output should be `undefined`):

    TenderApi.deployed().then(a=>{TenderApi=a;Tender.deployed().then(t=>{Tender=t;TenderApi.setCurrentAddress(Tender.address)})})

10. In Truffle there are two ways to call a function:

    Read-only (not using call): TenderApi.owner()
    Write-only (using call):    TenderApi.owner.call()

Read-only executes the function and reads the return value of functions, but does not modify the state of the contract.
Write-only executes the function, modifying the state if the function does so, but return value is not computed.
In this smart contract, calls are to be made through TenderApi.

To exit truffle console, press Ctrl+C twice.

Enjoy!