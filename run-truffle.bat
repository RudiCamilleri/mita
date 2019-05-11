@echo off
title Running Truffle...
start /b call .\start-ganache-cli.bat <NUL >ganache-output.txt
cd build\contracts
echo Cleaning build fragments...
call del *.js >nul 2>&1
call del *.json >nul 2>&1
cd ..\..
call truffle migrate --reset
call truffle console