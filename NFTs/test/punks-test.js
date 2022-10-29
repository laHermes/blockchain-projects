const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Punks', () => {
	const tokenPrice = ethers.utils.parseEther('0.01');
	const tokenSupplyLimit = 100;
	let owner, stranger, punks;

	before('deploy Punks token', async () => {
		[owner, stranger] = await ethers.getSigners();
		const contract = await ethers.getContractFactory('Punks');
		punks = await contract.deploy();
		await punks.deployed();
	});

	describe('Transactions', async () => {
		it('should toggle on the sale', async () => {
			await punks.toggleSaleOn();
			expect(await punks.openSale(), 'Expect openSale to be true').to.be.true;
		});

		it('should fail to toggle on & off the sale', async () => {
			await expect(
				punks.connect(stranger).toggleSaleOn(),
				'ToggleOn: Expect to be reverted!'
			).to.be.reverted;
			await expect(
				punks.connect(stranger).toggleSaleOff(),
				'ToggleOff: Expect to be reverted!'
			).to.be.reverted;
		});

		it('should mint a new token', async () => {
			await punks.connect(stranger).tokenMint({ value: tokenPrice });
			expect(
				await punks.totalSupply(),
				'Expect total supply to be 1'
			).to.be.equal('1');

			expect(
				await punks.balanceOf(stranger.address),
				'Expect balance to be 1'
			).to.be.equal('1');
		});

		it('should mint tokens to the limit', async () => {
			let supply;
			for (let i = 0; i <= 110; i++) {
				supply = await punks.totalSupply();
				if (supply >= tokenSupplyLimit) {
					// if all tokens are minted expect revert (token limit reached)
					await expect(punks.connect(stranger).tokenMint({ value: tokenPrice }))
						.to.be.reverted;
					return;
				}
				await punks.connect(stranger).tokenMint({ value: tokenPrice });
			}
			console.log('total token suply', supply);
			expect(supply).to.be.equal(tokenSupplyLimit);
		});

		it('should withdraw funds', async () => {
			// Get beginnings balances
			const punksEthBalance = await ethers.provider.getBalance(punks.address);
			const artistEthBalance = await ethers.provider.getBalance(owner.address);

			// calculate expected artist's eth balance after withdrawal
			const artistsEndingBalance = ethers.utils.formatEther(
				artistEthBalance.add(punksEthBalance)
			);

			// Withdraw funds from to contract to the artist
			await punks.connect(stranger).withdrawFunds();
			expect(
				await ethers.provider.getBalance(punks.address),
				'Punks eth balance should be 0!'
			).to.be.equal(0);

			// Get artist's balance after withdrawal
			const finalArtistsBalance = ethers.utils.formatEther(
				await ethers.provider.getBalance(owner.address)
			);

			expect(
				finalArtistsBalance,
				"Artist's eth balance should be greater than the beginning!"
			).to.be.equal(artistsEndingBalance);
		});
	});
});
