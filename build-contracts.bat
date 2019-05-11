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
pause