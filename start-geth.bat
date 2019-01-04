@echo off
echo Loading Geth... (use Ctrl+Break to exit)
geth --exec "loadScript('deploy-tenderapi.js')" attach http://127.0.0.1:8545
geth --exec "loadScript('deploy-tender.js')" attach http://127.0.0.1:8545
geth attach http://127.0.0.1:8545 --preload "init.js"