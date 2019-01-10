@echo off
start /b call ./start-ganache-cli.bat
cd contracts
title Running Remixd...
echo Starting Remixd...
remixd -s %cd% --remix-ide http://remix.ethereum.org
cd ..