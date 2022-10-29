import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/dist/types';
import { ethers } from 'hardhat';
import {
	VOTING_DELAY,
	VOTING_PERIOD,
	QUORUM_PERCENTAGE,
} from '../helper-hardhat-config';

const setupGovernanceContracts: DeployFunction = async function (
	hre: HardhatRuntimeEnvironment
) {
	const { getNamedAccounts, deployments } = hre;
	const { deploy, log, get } = deployments;
	const { deployer } = await getNamedAccounts();

	// @ts-ignore
	const timeLock = await ethers.getContract('TimeLock', deployer);

	// @ts-ignore
	const governor = await ethers.getContract('GovernorContract', deployer);

	log('Configuring roles');

	const proposerRole = await timeLock.PROPOSER_ROLE();
	const executorRole = await timeLock.EXECUTOR_ROLE();
	const adminRole = await timeLock.TIMELOCK_ADMIN_ROLE();

	const proposerTX = await timeLock.grantRole(proposerRole, governor.address);
	await proposerTX.wait(1);

	const executorTX = await timeLock.grantRole(
		executorRole,
		ethers.constants.AddressZero
	);
	await executorTX.wait(1);

	const revokeTX = await timeLock.revokeRole(adminRole, deployer);
	await revokeTX.wait(1);
};

export default setupGovernanceContracts;
