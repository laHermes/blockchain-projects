const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Punks', () => {
	const tokenPrice = ethers.utils.parseEther('0.03');
	let owner, stranger, punks;

	before('deploy Punks token', async () => {
		[owner, stranger] = await ethers.getSigners();
		const contract = await ethers.getContractFactory('QuasiMesh');
		punks = await contract.deploy();
		await punks.deployed();
	});

	describe('Transactions', async () => {
		it('should mint a new token', async () => {
			await punks
				.connect(stranger)
				.mintToken(stranger.address, 1, { value: tokenPrice });

			expect(
				await punks.totalSupply(),
				'Expect total supply to be 1'
			).to.be.equal('1');
		});
		it('should mint a new token', async () => {
			await punks.mintToken(owner.address, 9, { value: tokenPrice.mul(9) });

			expect(
				await punks.totalSupply(),
				'Expect total supply to be 10'
			).to.be.equal('10');

			const data = await punks.getAllNfts();
			console.log(data);
		});
	});
});
