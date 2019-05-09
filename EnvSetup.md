# Tender Smart Contracts

### To set up local development environment for testing Solidity smart contracts:

1. Install Visual Studio Code from https://aka.ms/win32-x64-user-stable and then install the Solidity extension by clicking the square icon on the left.

2. Install Git from https://git-scm.com/download/win, then press Shift+RightMouseClick on the desktop and click `Open Powershell window here` and copy and paste the following command to obtain the development files:

       git clone https://github.com/mathusummut/tender.git

	Note: Any time you want to update the files, open the project folder in Visual Studio Code, and in the Terminal tab (you might have to click `Teminal -> New Terminal`) write `git pull`.

3. Install Nodejs from https://nodejs.org/en by clicking on `64-bit` next to `Windows Installer`.

4. Press right-click on the Windows Start button and click `Windows PowerShell Admin`, and enter the following commands line by line:

       npm install -g windows-build-tools
       npm install -g truffle
       npm install -g ganache-cli
       npm install -g remixd              (only if you plan to use remix)

	Technical Note: If `windows-build-tools` or `ganache-cli` freezes or fails to install, install `truffle` and `ganache-cli` and try again. If the installation still does not work, then you have to add Python 2.7 to PATH and try again, installing both `windows-build-tools` or `ganache-cli`. If that does not work, try installing Python manually. The important thing is for `ganache-cli` to work.

5. (Optional) Install Geth from: https://ethereum.github.io/go-ethereum/downloads (the Windows installer)

6. ~~Run the following command in command prompt as well: `dotnet tool install -g dotnet-script`~~

    Install Chocolatey by opening Powershell and entering this command:

       Set-ExecutionPolicy Bypass -Scope Process -Force;iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

7. Then close the Powershell window and reopen it, and run the following command:

       choco install scriptcs

	Then (optionally) open the project folder in Visual Studio Code.

#### i. Running the smart contract using Nethereum (recommended method)

8. Run the `run-nethereum.bat` script in the project folder

9. Call C# Nethereum commands directly from the command window. Side Note: The scriptcs_bin directory contents are copied from the build output of the ContractUtils library.

10. The project uses the ContractUtils library (created by MathuSum Mut). The library source code and documentation can be found here: https://github.com/mathusummut/ContractUtils

#### ii. Running the smart contract locally using Remix IDE

8. Start `run-remix.bat` in the project folder.

9. When Remix loads in the browser, delete the files under the `browser` dropdown.

10. Click the small chain icon top left (when hovering over it, it should be labelled `Connect to localhost`), and then click `Connect`.

11. Click the `Run` tab, and set `Environment` to `Web3 Provider`, and click `OK`, then `OK` again.

12. You can edit inside Remix or use Visual Studio Code to modify the files. Files should be updated automatically.

**Warning: Deleting the files under `localhost` in Remix deletes the actual files permanently!!**

13. You can compile and run from Remix at your own leisure. Testing steps and demo parameters are provided in [Testing.md](https://github.com/mathusummut/tender/blob/master/Testing.md).

#### iii. Running the smart contract using truffle (not working):

8. Start `run-truffle.bat` in the project folder.

9. ~~Run `start-ganache-cli.bat` in the project folder, then in the ganache-cli output under `Available Accounts` (scroll up), copy the address at (0) and paste it in the `truffle-config.js` file next to the `from` key~~;

10. Copy and paste the following line into the truffle console and press enter (output should be `undefined`):

        TenderLogicAbi.deployed().then(a=>{TenderLogic=a;TenderDataAbi.deployed().then(t=>{TenderData=t;TenderLogic.replaceTenderData(TenderDataAbi.address, false, false)})})

11. Run console commands through Truffle, to close it simply close the console window or press Ctrl+C twice.

#### iv. Running the smart contract using geth (deprecated):

8. Double-click `run-geth.bat`, which is in the `/deprecated/geth` directory. To re-run, simply close the current console window (or press Ctrl+Break, then 'Y' and Enter) and re-open.

## Additional Info

In web3 there are two ways to call a function:

       Read-only (not using call): TenderLogic.owner()
       Write-only (using call):    TenderLogic.owner.call()

Read-only executes the function and reads the return value of functions, but does not modify the state of the contract.

Write-only executes the function, modifying the state if the function does so, but return value is not computed.

Type `eth` to see what's available if using truffle.

## Git Cheat Sheet

Useful Commands:

    git pull                           #pull updates

    git add * :/                       #loads all file changes since last pull or commit
    git commit -m "Changed A, B, C"    #commits the changes under the specified message
    git push

    git reset --hard                   #removes changes from last pull or commit
    git mergetool                      #to fix merge conflicts (install TortoiseSVN)