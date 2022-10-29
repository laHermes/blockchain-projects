import { ethers, network } from 'hardhat';
import {
	developmentChains,
	proposalFile,
	VOTING_DELAY,
} from '../helper-hardhat-config';
import { moveBlocks } from '../utils/move-blocks';
import fs from 'fs';

export async function propose(
	args: any[],
	functionToCall: string,
	proposalDescription: string
) {
	const governor = await ethers.getContract('GovernorContract');
	const target = await ethers.getContract('Target');

	const encodedFunctionCall = target.interface.encodeFunctionData(
		functionToCall,
		args
	);

	console.log(`Proposing ${functionToCall} on ${target.address} with ${args}`);
	console.log(`Proposal description: ${proposalDescription}`);

	const proposeTx = await governor.propose(
		[target.address],
		[0],
		[encodedFunctionCall],
		proposalDescription
	);

	const proposeReceipt = await proposeTx.wait(1);

	if (developmentChains.includes(network.name)) {
		await moveBlocks(VOTING_DELAY + 1);
	}

	const proposalId = proposeReceipt.events[0].args.proposalId;
	console.log('Proposal ID :', proposalId.toString());

	// get json
	let proposal = JSON.parse(fs.readFileSync(proposalFile, 'utf8'));
	proposal[network.config.chainId!.toString()].push(proposalId.toString());
	// write ot json
	fs.writeFileSync(proposalFile, JSON.stringify(proposal));
}

propose([4441], 'store', 'Hello')
	.then(() => process.exit(0))
	.catch((err) => {
		console.log(err);
		process.exit(1);
	});
