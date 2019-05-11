@echo off
echo Starting Ganache...
echo.
ganache-cli.cmd --host 127.0.0.1 --port 8545 --defaultBalanceEther 10000 --gasPrice 0x7A817C800 --gasLimit 0x100000000 --allowUnlimitedContractSize