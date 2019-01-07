@echo off
echo Loading Geth... (use Ctrl+Break to exit)
geth --exec "loadScript('deploy-tenderapi.js')" attach http://127.0.0.1:8545
powershell.exe -executionpolicy bypass -file .\load-tenderapi-address.ps1
geth --exec "loadScript('deploy-tender.js')" attach http://127.0.0.1:8545
powershell.exe -executionpolicy bypass -file .\load-tender-address.ps1
geth attach http://127.0.0.1:8545 --preload "init.js"