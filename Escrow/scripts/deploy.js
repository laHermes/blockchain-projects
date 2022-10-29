const { ethers } = require("hardhat");

const main = async () => {
  //   const [deployer] = await ethers.getSigners();
  //   console.log("dep", deployer);
  //   console.log("Deploying contracts with the account:", deployer.address);

  //   console.log("Account balance:", (await deployer.getBalance()).toString());

  const UserDatabase = await ethers.getContractFactory("UserDatabase");
  const contract = await UserDatabase.deploy();

  await contract.deployed();
  console.log("Contract deployed at:", contract.address);
};

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
