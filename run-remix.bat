@echo off
start /b call ./start-ganache-cli.bat
cd contracts
title Running Remixd...
echo Opening URL: http://remix.ethereum.org/#optimize=true^&version=soljson-v0.5.0+commit.1d4f565a.js
start "" "http://remix.ethereum.org/#optimize=true&version=soljson-v0.5.0+commit.1d4f565a.js"
echo Launching REPL...
start cmd /k dotnet-script -i %cd%\..\init-csharp-repl.csx
echo Starting Remixd...
remixd -s %cd% --remix-ide http://remix.ethereum.org
cd ..