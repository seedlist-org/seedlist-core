const hre = require("hardhat");
const { ethers } = require("ethers");

async function main(){
	await deployAllContracts();
}

async function deployAllContracts() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile 
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const accounts = await hre.ethers.getSigners();
  const signer = accounts[0];
  const VaultHubPermission = await hre.ethers.getContractFactory("VaultHubPermission");
  const vPermission = await VaultHubPermission.deploy();
  await vPermission.deployed();
  console.log("VaultHubPermissionLib deploy to:", vPermission.address );

  const PrivateVaultPermission = await hre.ethers.getContractFactory("PrivateVaultPermission");
  const pPermission = await PrivateVaultPermission.deploy();
  await pPermission.deployed();
  console.log("PrivateVaultPermissionLib deploy to:", pPermission.address);

  const Seeder = await hre.ethers.getContractFactory("SeedToken");
  const seeder = await Seeder.deploy();
  await seeder.deployed();
  console.log("SeedToken deployed to:", seeder.address);

  const Treasury = await hre.ethers.getContractFactory("Treasury");
  const treasury = await Treasury.deploy(seeder.address);
  await treasury.deployed();
  console.log("Treasury deployed to:", treasury.address);

  const Validator = await hre.ethers.getContractFactory("Validator");
  const validator = await Validator.deploy();
  await validator.deployed();
  console.log("Validator deployed to:", validator.address);


  const VaultHub = await hre.ethers.getContractFactory("VaultHub");
  const vaulthub = await VaultHub.deploy(validator.address, vPermission.address, pPermission.address);
  await vaulthub.deployed();
  console.log("VaultHub deployed to:", vaulthub.address);

  const seedToken = new hre.ethers.Contract(seeder.address, Seeder.interface, signer);
  let transactionResponse = await seedToken.setMinter(treasury.address);
  let receipt = await transactionResponse.wait(1)
  console.log("set minter for seedlist token finished");

  const treasuryContract = new hre.ethers.Contract(treasury.address, Treasury.interface, signer);
  transactionResp = await treasuryContract.setCaller(vaulthub.address);
  receipt0 = await transactionResp.wait(1);
  console.log("set caller for treasury finished");

  const vaultHubContract = new hre.ethers.Contract(vaulthub.address, VaultHub.interface, signer);
  let transResponse = await vaultHubContract.setTreasuryAddress(treasury.address);
  let receipt1 = await  transResponse.wait(1);
  console.log("vaulthub set treasury finished");

  //calculate domain_separator for front-end using
  let DOMAIN = await vaultHubContract.DOMAIN_SEPARATOR();
  console.log("DOMAIN_SEPARATOR:",DOMAIN);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
