async function verify() {
	await hre
		.run('verify:verify', {
			address: '0x7F0fF918a2ED72ec6C82D59be62b8Dc8fce3F7d0',
			contract: 'contracts/Market/Market.sol:NFTMarket',
			constructorArguments: [],
		})
		.catch(console.log);
}

verify();
