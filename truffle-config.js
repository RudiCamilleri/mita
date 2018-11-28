//This file holds Truffle configuration

module.exports = {
	//See http://truffleframework.com/docs/advanced/configuration
	//to customize Truffle configuration
	networks: {
		development: {
			from: "0xdf4d0a48bf45ceb8fdc6227cb29125e1fbfd95c9", //address of TenderApi owner
			host: "127.0.0.1", //localhost
			port: 8545,
			network_id: "*", //match any network id
			gas: 4712388, //gas limit used for deploys
			gasPrice: 100000000000, //Gas price used for deploys (default: 100 Shannon)
			contracts_build_directory: "./build"
		}
	}
};