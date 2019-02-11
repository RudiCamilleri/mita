@echo off
echo Starting VS Code...
start /b call code %cd%\contracts
call .\run-remix.bat