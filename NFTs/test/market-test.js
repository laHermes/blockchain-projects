const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Market', () => {
	let owner, stranger, nft, market;
	const tokenPrice = ethers.utils.parseEther('0.01');

	before('deploy nft and market contracts', async () => {
		// reset hardhat state
		// await hre.network.provider.send('hardhat_reset');

		[owner, stranger] = await ethers.getSigners();
		market = await ethers.getContractFactory('NFTMarket');
		nft = await ethers.getContractFactory('Collection');

		// deploy nft
		nft = await nft.deploy('Collection', 'Coll');
		await nft.deployed();

		// deploy market
		market = await market.deploy();
		await market.deployed();
	});

	describe('Transactions', async () => {
		it('should asses the nft contract owner', async () => {
			expect(
				await nft.owner(),
				'Expect signer to be the owner of the nft contract'
			).to.equal(owner.address);
		});

		it('should asses the market contract owner', async () => {
			expect(
				await market.owner(),
				'Expect signer to be the owner of the market contract'
			).to.equal(owner.address);
		});

		it('should toggle on the sale', async () => {
			await nft.toggleSaleOn();
			expect(await nft.openSale(), 'Expect openSale to be true').to.be.true;
		});

		it('should fail to toggle on & off the sale', async () => {
			await expect(
				nft.connect(stranger).toggleSaleOn(),
				'ToggleOn: Expect to be reverted!'
			).to.be.reverted;
			await expect(
				nft.connect(stranger).toggleSaleOff(),
				'ToggleOff: Expect to be reverted!'
			).to.be.reverted;
		});

		it('should mint new token(s)', async () => {
			const cap = 10;
			for (let i = 0; i < cap; i++) {
				await nft.safeMintId(i, { value: tokenPrice });
			}
			expect(
				await nft.totalSupply(),
				'Expect total supply of nft to be 10'
			).to.be.equal('10');

			expect(
				await nft.balanceOf(owner.address),
				'Expect users balance to be 10'
			).to.be.equal('10');

			for (let i = 0; i < cap; i++) {
				expect(await nft.ownerOf(i)).to.be.equals(owner.address);
			}
		});

		it('should approve market contract', async () => {
			expect(await nft.setApprovalForAll(market.address, true))
				.to.emit(nft, 'ApprovalForAll')
				.withArgs(owner.address, market.address, true);
		});
	});

	describe('Market Interactions', async () => {
		it('should check approval', async () => {
			expect(await nft.isApprovedForAll(owner.address, market.address)).to.be
				.true;
		});

		it('should market individual NFT', async () => {
			const cap = 10;

			for (let i = 0; i < cap; i++) {
				await market.marketToken(nft.address, i, ethers.utils.parseEther('2'), {
					value: ethers.utils.parseEther('0.01'),
				});
			}

			await expect(
				market.marketToken(nft.address, 100, ethers.utils.parseEther('30'), {
					value: ethers.utils.parseEther('0.01'),
				})
			).to.be.revertedWith('ERC721: owner query for nonexistent token');

			expect(await market.getNftsForSale())
				.to.be.a('array')
				.that.have.lengthOf(10);

			expect(await market.getNftPrice(1)).to.be.equal(
				ethers.utils.parseEther('2')
			);
		});

		it('should buy first NFT', async () => {
			await expect(
				market
					.connect(stranger)
					.buyToken(1, { value: ethers.utils.parseEther('2') })
			)
				.to.emit(market, 'BuyToken')
				.withArgs(1);

			const own = await nft.ownerOf(1);

			expect(await market.getSaleStatus(1)).to.be.false;

			expect(await nft.ownerOf(0)).to.equal(stranger.address);

			expect(await market.getNftsForSale())
				.to.be.a('array')
				.that.have.lengthOf(9);
		});

		it('should buy second NFT', async () => {
			await expect(
				market
					.connect(stranger)
					.buyToken(2, { value: ethers.utils.parseEther('2') })
			)
				.to.emit(market, 'BuyToken')
				.withArgs(2);

			expect(await market.getSaleStatus(2)).to.be.false;
			expect(await market.getNftSeller(2)).to.equal(stranger.address);

			expect(await nft.ownerOf(2 - 1)).to.equal(stranger.address);

			expect(await market.getNftsForSale())
				.to.be.a('array')
				.that.have.lengthOf(8);
		});

		it('should remove token from listing', async () => {
			const tokenId = await market.getNftTokenId(3);
			const nftContractAddress = await market.getNftContract(3);

			await expect(market.removeFromListing(3))
				.to.emit(market, 'ListingRemoved')
				.withArgs(3, nftContractAddress, tokenId);

			expect(await market.getNftsForSale())
				.to.be.a('array')
				.that.have.lengthOf(7);

			expect(await market.getAllNfts())
				.to.be.a('array')
				.that.have.lengthOf(10);
		});
	});
});
