@echo off
SETLOCAL EnableDelayedExpansion
title Compiling smart contracts...
echo Compiling smart contracts... (using truffle)
call truffle compile
echo.
echo Minifying Output...
minify-json.exe build/contracts build/contracts
echo.
call ./generate-js.bat
start /b call ./start-ganache-cli.bat <NUL >ganache-output.txt
title Running Local Blockchain...
echo.
echo Running Local Blockchain... (using Ganache)
set "FOUND=FALSE"
:REPEAT:
TIMEOUT 1 /NOBREAK >NUL
find "Listening" ganache-output.txt >nul && set "FOUND=TRUE"
if "%FOUND%" == "TRUE" (
	echo.
	start-geth.bat
) else (
	goto REPEAT
)