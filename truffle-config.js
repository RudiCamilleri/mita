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
			gas: 2573636023, //gas limit used for deploys
			gasPrice: 2000000000 //Gas price used for deploys (default: 100 Shannon = 100000000000)
		}
	},
	compilers: {
		solc: {
			version: "0.5.6"
		}
	}
};