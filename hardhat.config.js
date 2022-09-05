require("@nomiclabs/hardhat-waffle");
//require("@nomiclabs/hardhat-web3");
require("@nomiclabs/hardhat-etherscan");

//.secrets format: { "privkey":"....", "alchemyapikey":"...." }
const { privkey, infura_url, etherscan_apikey,mainnet_url,polygon_url, polygonscan_apikey } = require("./.secrets.json");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async () => {
  const accounts = await ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: //"0.6.6",
      {
        compilers:[
            {
                version:"0.8.12",
                settings:{
	                evmVersion:"istanbul",
                    optimizer:{
                        enabled:true,
	                    runs:1000
                    }
                },
            }
        ],
      },
  networks: {
    rinkeby: {
      url: `${infura_url}`,
      accounts: [`${privkey}`],
	  gas: 21000000,
	  gasPrice: 8000000000
    },
	  matic: {
		  url: `${polygon_url}`,
		  accounts: [`${privkey}`],
		  gas: 21000000,
		  gasPrice: 80000000000,
		  chainId:137
	  },
	  mainnet: {
		  url: `${mainnet_url}`,
		  accounts: [`${privkey}`],
		  gas: 21000000,
		  gasPrice: 8000000000
	  },
	  arbitrum:{
        url: "https://rinkeby.arbitrum.io/rpc",
        accounts: [`${privkey}`]

      }
  },
  // usage: https://www.npmjs.com/package/@nomiclabs/hardhat-etherscan
  etherscan: {
    apiKey: polygonscan_apikey
  }


};

