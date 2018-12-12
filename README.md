# MITA Smart Contract

Website repository can be found here: https://github.com/mathusummut/tender-website

## To set up local development environment and testing of Ethereum smart contracts:

1. Install Visual Studio Code from https://aka.ms/win32-x64-user-stable and then install the Solidity extension by clicking the square icon on the left.

2. Install Git from https://git-scm.com/download/win, then press Shift+RightMouseClick on the desktop and click `Open Powershell window here` and copy and paste the following command to obtain the development files:

       git clone https://github.com/mathusummut/tender.git

	Note: Any time you want to update the files, open the project folder in Visual Studio Code, and in the Terminal tab (you might have to click `Teminal -> New Terminal`) write `git pull`.

3. Install Nodejs from https://nodejs.org/en/download by clicking on `64-bit` next to `Windows Installer`.

4. Press right-click on the Windows Start button and click "Windows PowerShell Admin", and enter the following commands line by line:

       npm install -g windows-build-tools
       npm install -g truffle
       npm install -g ganache-cli
       
	Technical Note: If `windows-build-tools` or `ganache-cli` freezes or fails to install, install truffle and ganache-cli and try again. If the installation still does not work, then you have to add Python 2.7 to PATH and try again, installing both `windows-build-tools` or `ganache-cli`. If that does not work, try installing Python manually. The important thing is for `ganache-cli` to work.

5. Open the project folder in Visual Studio Code.

## Running the smart contract:

6. Run `start-ganache-cli.bat` in the project folder.

7. In the ganache-cli output under `Available Accounts` (scroll up), copy the address at (0) and paste it in the `truffle-config.js` file next to the `from` key

8. In the `Terminal` tab in Visual Studio Code, enter the following line by line (`m` stands for `migrate`, `con` stands for `console`):

       truffle m --reset
       truffle con

9. Copy and paste the following line into the truffle console and press enter (output should be `undefined`):

       TenderApi.deployed().then(a=>{TenderApi=a;Tender.deployed().then(t=>{Tender=t;TenderApi.setCurrentAddress(Tender.address)})})

10. In Truffle there are two ways to call a function:

       Read-only (not using call): TenderApi.owner()
       Write-only (using call):    TenderApi.owner.call()

Read-only executes the function and reads the return value of functions, but does not modify the state of the contract.

Write-only executes the function, modifying the state if the function does so, but return value is not computed.

In this smart contract, calls are to be made through TenderApi.

To exit truffle console, press Ctrl+C twice.

## Git Cheat Sheet

Useful Commands:

    git pull                           #pull updates

    git add * :/                       #loads all file changes since last pull or commit
    git commit -m "Changed A, B, C"    #commits the changes under the specified message
    git push

    git reset --hard                   #removes changes from last pull or commit
    git mergetool                      #to fix merge conflicts (install TortoiseSVN)
