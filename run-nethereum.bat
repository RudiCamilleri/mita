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
echo.
echo Launching Nethereum Console...
echo.
title Nethereum C# Console
rem call dotnet-script -i "%cd%\..\init-csharp-repl.csx"
call scriptcs -script "%cd%\..\init-nethereum.csx" -Repl