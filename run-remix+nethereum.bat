@echo off
title Compiling smart contracts...
cd build\contracts
echo Cleaning build fragments...
call del *.js >nul 2>&1
call del *.json >nul 2>&1
cd ..\..
echo.
echo Compiling smart contracts... (using truffle)
cd contracts
call truffle compile
cd ..
echo Minifying Output...
call .\minify-json.exe build/contracts build/contracts
start /b call .\start-ganache-cli.bat <NUL >ganache-output.txt
cd contracts
title Running Remixd...
echo Opening URL: http://remix.ethereum.org/#optimize=true^&version=soljson-v0.5.6+commit.b259423e.js
start "" "http://remix.ethereum.org/#optimize=true&version=soljson-v0.5.6+commit.b259423e.js"
echo Starting Remixd...
start /b cmd /c remixd -s %cd% --remix-ide http://remix.ethereum.org <NUL
echo Launching REPL...
title Nethereum C# Console
rem call dotnet-script -i "%cd%\..\init-csharp-repl.csx"
call scriptcs -script "%cd%\..\init-nethereum.csx" -Repl