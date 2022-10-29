require("@nomiclabs/hardhat-waffle");
// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */

const privateKey =
  "0xe69de35c06dc826bd848e24082fa97bc5497db4e357aa1411c8423238c8e034c";

const mainnet =
  "https://eth-mainnet.alchemyapi.io/v2/2O5Nih8N4_J-ozut4TCgGDu60noYhrS-";

const kovan =
  "https://eth-kovan.alchemyapi.io/v2/XB6dxTdhnoW9innA9OIvjuuqmp4G3JfN";

module.exports = {
  solidity: "0.7.5",
  settings: {
    optimizer: {
      enabled: true,
      runs: 200,
    },
  },
  networks: {
    kovan: {
      url: "https://kovan.infura.io/v3/74f98561ad324c25b84e97cce1fc119d",
      accounts: [privateKey],
      chainId: 42,
    },
    hardhat: {
      forking: {
        url: kovan,
      },
      // mining: {
      //   auto: false,
      //   interval: 5000,
      // },
    },
  },
  namedAccounts: {
    deployer: 0,
  },
};
