@echo off
title Starting Visual Studio Code from console...
echo Starting Visual Studio Code...
set VSCODE_DEV=
set ELECTRON_RUN_AS_NODE=1
for /f "tokens=*" %%i in ('where code') do set CODEPATH=%%i
start /b "" "%CODEPATH%\..\..\Code.exe" "%CODEPATH%\..\..\resources\app\out\cli.js" "%cd%\contracts"
start /b "" "%CODEPATH%\..\..\Code.exe" "%CODEPATH%\..\..\resources\app\out\cli.js" "%cd%\init-nethereum.csx"
timeout /t 10 /nobreak>nul
start /b "" ".\nircmd" win close title "Starting Visual Studio Code from console..."