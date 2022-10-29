const { ethers } = require("hardhat");

// Exceedes SIZE LIMITT!!!

const main = async () => {
  // await network.provider.request({
  //   method: "hardhat_impersonateAccount",
  //   params: ["0x896223ACCdAA46602A1CA9B7dd32f853EA87a97c"],
  // });

  const signer = await ethers.getSigner();
  const balance = await signer.getBalance();
  console.log("balance", ethers.utils.formatEther(balance));

  const EtherEscrow = await ethers.getContractFactory("EtherEscrow");

  const deposit = ethers.utils.parseEther("1");

  // const overrides = {
  //   gasLimit: ethers.utils.parseEther("0.00000000000221000"),
  // };

  const mainnetDB = "0x7bc06c482DEAd17c0e297aFbC32f6e63d3846650";
  const kovanDB = "0x37f8101a4773b17e220E7eB2F267e54b42098f3E";

  // console.log(ethers.utils.formatEther(estimatedGas), "burn baby burn");

  const contract = await EtherEscrow.deploy(
    "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
    "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
    "0xD094251CeE05A9Ed56BbDDf5d792eb0672e4De8f",
    { value: deposit }
  );

  await contract.deployed();
  console.log("Contract deployed at:", contract.address);

  console.log("contract is", await contract.functions.approve());
};

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
