@echo off
cd contracts
title Compiling smart contracts...
echo Compiling smart contracts... (using truffle)
call truffle compile
cd ..
echo Minifying Output...
call .\minify-json.exe build/contracts build/contracts
start /b call .\start-ganache-cli.bat <NUL >ganache-output.txt
cd contracts
title Running Remixd...
echo Opening URL: http://remix.ethereum.org/#optimize=true^&version=soljson-v0.5.0+commit.1d4f565a.js
start "" "http://remix.ethereum.org/#optimize=true&version=soljson-v0.5.0+commit.1d4f565a.js"
echo Starting Remixd...
start /b cmd /c remixd -s %cd% --remix-ide http://remix.ethereum.org <NUL
echo Launching REPL...
title Nethereum C# Console
call dotnet-script -i "%cd%\..\init-csharp-repl.csx"