const { ethers } = require('hardhat');

// Exceedes SIZE LIMITT!!!

const main = async () => {
	// await network.provider.request({
	//   method: "hardhat_impersonateAccount",
	//   params: ["0x896223ACCdAA46602A1CA9B7dd32f853EA87a97c"],
	// });

	const signer = await ethers.getSigner();
	const balance = await signer.getBalance();
	console.log('balance', ethers.utils.formatEther(balance));

	const EtherEscrow = await ethers.getContractFactory('EtherEscrow');

	// const deploymentData = EtherEscrow.interface.encodeDeploy([
	//   "0x896223ACCdAA46602A1CA9B7dd32f853EA87a97c",
	//   "0x896223ACCdAA46602A1CA9B7dd32f853EA87a97c",
	//   "0x37f8101a4773b17e220E7eB2F267e54b42098f3E",
	//   "0xA61ca04DF33B72b235a8A28CfB535bb7A5271B70",
	//   "0x87b1f4cf9BD63f7BBD3eE1aD04E8F52540349347",
	// ]);

	// const estimatedGas = await ethers.provider.estimateGas({
	//   data: deploymentData,
	// });

	const deposit = ethers.utils.parseEther('1');

	// const overrides = {
	//   gasLimit: ethers.utils.parseEther("0.00000000000221000"),
	// };

	const mainnetDB = '0x7bc06c482DEAd17c0e297aFbC32f6e63d3846650';
	const kovanDB = '0x37f8101a4773b17e220E7eB2F267e54b42098f3E';

	const contract = await EtherEscrow.deploy(
		'0x896223ACCdAA46602A1CA9B7dd32f853EA87a97c',
		'0x896223ACCdAA46602A1CA9B7dd32f853EA87a97c',
		{ value: deposit }
	);

	await contract.deployed();
	console.log('Contract deployed at:', contract.address);
};

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
