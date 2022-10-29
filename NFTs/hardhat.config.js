import '@nomiclabs/hardhat-waffle';
import '@nomiclabs/hardhat-etherscan';
import 'dotenv';

const privateKey = process.env.PRIVATE_KEY;
const apiKey = process.env.API_KEY;

module.exports = {
	solidity: '0.8.4',
	settings: {
		optimizer: {
			enabled: true,
			runs: 200,
		},
	},
	networks: {
		hardhat: {},
		rinkeby: {
			url: 'https://rinkeby.infura.io/v3/74f98561ad324c25b84e97cce1fc119d',
			accounts: [privateKey],
		},
		polygonMumbai: {
			url: 'https://rpc-mumbai.maticvigil.com/',
			accounts: [privateKey],
		},
	},
	etherscan: {
		apiKey: {
			polygonMumbai: apiKey,
		},
	},
};
