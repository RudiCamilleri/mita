@echo off
title Running Remixd...
start /b call .\start-ganache-cli.bat <NUL >ganache-output.txt
cd contracts
echo Opening URL: http://remix.ethereum.org/#optimize=true^&version=soljson-v0.5.6+commit.b259423e.js
start "" "http://remix.ethereum.org/#optimize=true&version=soljson-v0.5.6+commit.b259423e.js"
echo Starting Remixd...
call remixd -s %cd% --remix-ide http://remix.ethereum.org <NUL