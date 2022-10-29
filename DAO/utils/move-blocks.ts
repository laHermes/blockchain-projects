import { network } from 'hardhat';

export async function moveBlocks(amount: number) {
	console.log('Mining Blocks');

	for (let index = 0; index < amount; index++) {
		network.provider.request({
			method: 'evm_mint',
			params: [],
		});
	}
}
