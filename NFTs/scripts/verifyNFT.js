async function verify() {
	await hre
		.run('verify:verify', {
			address: '0x7CD3c403FAd9C0484e52B0B647526b674614Be14',
			contract: 'contracts/FlatCollection.sol:Collection',
			constructorArguments: ['Collections', 'Coll'],
		})
		.catch(console.log);
}

verify();
