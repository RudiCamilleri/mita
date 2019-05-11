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
echo.
echo Launching Nethereum C# Console...
echo.
title Nethereum C# Console
rem call dotnet-script -i "%cd%\..\init-csharp-repl.csx"
call scriptcs -script "%cd%\..\init-nethereum.csx" -Repl
rem call scriptcs -script "%cd%\..\init-nethereum.csx" -Repl -loglevel debug