// We require the Hardhat Runtime Environment explicitly here. This is optional 
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile 
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const Seeder = await hre.ethers.getContractFactory("SeedToken");
  const seeder = await Seeder.deploy();
  await seeder.deployed();
  console.log("SeedToken deployed to:", seeder.address);


  let registry_addr = "0x74c5dc1bB65e1Dbc5a36C3ebF6863c53122b9592";
  const Treasury = await hre.ethers.getContractFactory("Treasury");
  const treasury = await Treasury.deploy(seeder.address, registry_addr);
  await treasury.deployed();
  console.log("Treasury deployed to:", treasury.address);

  const accounts = await hre.ethers.getSigners();
  const signer = accounts[0];
  const seedlist = new hre.ethers.Contract(seeder.address, Seeder.interface, signer);

  let transactionResponse = await seedlist.addMinter(treasury.address);
  let receipt = await transactionResponse.wait(1)
  console.log("set minter for seedlist token finished");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
