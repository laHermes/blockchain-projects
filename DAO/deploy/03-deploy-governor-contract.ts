import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/dist/types';
import { ethers } from 'hardhat';
import {
	VOTING_DELAY,
	VOTING_PERIOD,
	QUORUM_PERCENTAGE,
} from '../helper-hardhat-config';

const deployGovernorContract: DeployFunction = async function (
	hre: HardhatRuntimeEnvironment
) {
	const { getNamedAccounts, deployments } = hre;
	const { deploy, log, get } = deployments;
	const { deployer } = await getNamedAccounts();
	const governanceToken = await get('GovernanceToken');
	const timeLockContract = await get('TimeLock');

	log('Deploying Governor Contract');
	const governor = await deploy('GovernorContract', {
		from: deployer,
		args: [
			governanceToken.address,
			timeLockContract.address,
			VOTING_DELAY,
			VOTING_PERIOD,
			QUORUM_PERCENTAGE,
		],
		log: true,
	});

	log(`Deployed Governor to address ${governor.address}`);
};

export default deployGovernorContract;
