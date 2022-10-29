import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/dist/types';
import { ethers } from 'hardhat';
import { MIN_DELAY } from '../helper-hardhat-config';

const deployTimeLock: DeployFunction = async function (
	hre: HardhatRuntimeEnvironment
) {
	const { getNamedAccounts, deployments } = hre;
	const { deploy, log } = deployments;
	const { deployer } = await getNamedAccounts();

	log('Deploying Time Lock Contract');
	const timeLock = await deploy('TimeLock', {
		from: deployer,
		args: [MIN_DELAY, [], []],
		log: true,
	});

	log(`Deployed Time Lock to address ${timeLock.address}`);
};

export default deployTimeLock;
