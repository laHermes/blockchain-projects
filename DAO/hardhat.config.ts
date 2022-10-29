import 'hardhat-deploy';
import '@nomiclabs/hardhat-ethers';
import '@typechain/hardhat';
import '@nomiclabs/hardhat-etherscan';
import { HardhatUserConfig } from 'hardhat/config';

const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY || '';

const config: HardhatUserConfig = {
	defaultNetwork: 'hardhat',
	networks: {
		hardhat: {
			chainId: 31337,
		},
		localhost: {
			chainId: 31337,
		},
	},
	etherscan: {
		apiKey: ETHERSCAN_API_KEY,
	},
	solidity: '0.8.9',
	namedAccounts: {
		deployer: {
			default: 0,
		},
	},
};

export default config;
