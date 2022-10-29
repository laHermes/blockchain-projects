import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/dist/types';
import { ethers } from 'hardhat';

const deployGovernanceToken: DeployFunction = async function (
	hre: HardhatRuntimeEnvironment
) {
	const { getNamedAccounts, deployments } = hre;
	const { deploy, log } = deployments;
	const { deployer } = await getNamedAccounts();

	log('Deploying Gov Token');
	const governanceToken = await deploy('GovernanceToken', {
		from: deployer,
		args: [],
		log: true,
		// waitConfirmations: 4,
	});

	log(`Deployed Governance Token to address ${governanceToken.address}`);

	await delegate(governanceToken.address, deployer);
};

// who can vote with this token
const delegate = async (
	deployGovernanceTokenAddress: string,
	delegatedAccount: string
) => {
	const governanceToken = await ethers.getContractAt(
		'GovernanceToken',
		deployGovernanceTokenAddress
	);

	const tx = await governanceToken.delegate(delegatedAccount);
	await tx.wait(1);
	console.log(
		`Checkpoints ${await governanceToken.numCheckpoints(delegatedAccount)}`
	);
};

export default deployGovernanceToken;
