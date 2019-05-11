@echo off
echo Starting Visual Studio Code...
echo.
cmd /c code "%cd%\contracts"
cmd /c code "%cd%\init-nethereum.csx"
.\run-remix+nethereum.bat