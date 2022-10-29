// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
const hre = require('hardhat');

async function main() {
	const Punks = await hre.ethers.getContractFactory('QuasiMesh');
	const punks = await Punks.deploy();

	await punks.deployed();

	console.log('ADDRESS: ', punks.address);
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
