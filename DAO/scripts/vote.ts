import { ethers, network } from 'hardhat';
import { proposalFile } from '../helper-hardhat-config';
import fs from 'fs';

export async function main(proposalIndex: number) {
	const proposal = JSON.parse(fs.readFileSync(proposalFile, 'utf8'));
	const proposalId = proposal[network.config.chainId!][proposalIndex];

	// 0: Against. 1 - FOR, 2: ab stain
	const voteStance = 0;
	const reason = 'out of spite';
	//get contract
	// vode by sneding tokens
	await vote(proposalId, voteStance, reason);
}

async function vote(proposalId: number, stance: number, reason: string) {
	const governor = await ethers.getContract('GovernorContract');
	const voteTx = await governor.castVoteWithReason(proposalId, stance, reason);

	const voteReceipt = await voteTx.wait(1);
	console.log(voteReceipt.events[0].args.reason);
}

main(1)
	.then(() => {
		process.exit(0);
	})
	.catch((e) => {
		console.log(e);
		process.exit(1);
	});
