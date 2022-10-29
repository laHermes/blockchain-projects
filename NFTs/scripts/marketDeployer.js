// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
const hre = require('hardhat');

async function main() {
	const Market = await hre.ethers.getContractFactory('NFTMarket');
	const Punks = await hre.ethers.getContractFactory('Collection');

	const punks = await Punks.deploy('Collections', 'Coll');
	const market = await Market.deploy();

	await market.deployed();
	await punks.deployed();

	// toggle the sale of tokens on
	await punks.toggleSaleOn();

	console.log('market address', market.address);
	console.log('nft address', punks.address);
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
