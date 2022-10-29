async function verify() {
	await hre
		.run('verify:verify', {
			address: '0x5d6f0cBe65C202c1706502036d10c91A64803913',
			contract: 'contracts/QuasiRandomERC721.sol:QuasiMesh',
			constructorArguments: [],
		})
		.catch(console.log);
}

verify();
