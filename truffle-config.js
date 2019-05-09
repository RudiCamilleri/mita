//This file holds Truffle configuration

module.exports = {
	//See http://truffleframework.com/docs/advanced/configuration
	//to customize Truffle configuration
	networks: {
		development: {
			//from: "0x9c07857ac140039cb6e08edc13ec30887feb5ee8", //address of main wallet
			host: "127.0.0.1", //localhost
			port: 8545, //default ganache-cli port
			network_id: "*", //match any network id
			gas: 2573636023, //the maximum amount of gas you are willing to spend on a particular transaction (can be the same as "default_gas" in /scriptcs_bin/contract_defaults.json, but in decimal instead of hex)
			gasPrice: 2000000000, //the amount of Ether you are willing to pay for every unit of gas (can be the same as "default_gas_price" in /scriptcs_bin/contract_defaults.json, but in decimal instead of hex)
			contracts_build_directory: "./build" //specifies the build directory (required for some setups)
		}
	},
	compilers: {
		solc: {
			version: "0.5.6"
		}
	}
};