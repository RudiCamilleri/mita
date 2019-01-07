@echo off
SETLOCAL EnableDelayedExpansion
echo Generating JavaScript Files...
cd build\contracts
for /r %%i in ("*.json") do (
	set "filename=%%i"
	set "js=!filename:~0,-2!"
	copy !filename! !js!
	for %%F in ("!filename:~0,-5!") do set "varname=%%~nxF"
	echo | set /p dummyName=var !varname!Build=>!js!
	type !filename! >> !js!
)
cd ..\..