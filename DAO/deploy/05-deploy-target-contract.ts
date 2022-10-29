import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/dist/types';
import { ethers } from 'hardhat';

const deployTarget: DeployFunction = async function (
	hre: HardhatRuntimeEnvironment
) {
	const { getNamedAccounts, deployments } = hre;
	const { deploy, log } = deployments;
	const { deployer } = await getNamedAccounts();

	log('Deploying Target Contract');
	const target = await deploy('Target', {
		from: deployer,
		args: [],
		log: true,
	});

	log(`Target deployed to address ${target.address}`);

	const timeLock = await ethers.getContract('TimeLock', deployer);
	const targetContract = await ethers.getContractAt('Target', target.address);
	const transferOwnerTx = await targetContract.transferOwnership(
		timeLock.address
	);
	await transferOwnerTx.wait(1);
};

export default deployTarget;
