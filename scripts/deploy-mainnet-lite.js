// We require the Hardhat Runtime Environment explicitly here. This is optional 
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
//const {GenEthereumBrainWallet} = require("../../seedlist-interface-ts/src/lib/brainwallet");
// Get From Contract Interface By RPC

const DOMAIN_SEPARATOR = "0xeff7361eb9be999d71f09b696682b429fa50c59d1d2bdca4c9a525ee40488dd2";

// keccak256('savePrivateDataWithMinting(address addr, string memory data, string memory cryptoLabel, address labelHash,
// address receiver, uint256 deadline)');
const MINT_SAVE_PERMIT_TYPE_HASH =
	"0xcdd3cc6eb42396c94a4d5d905327888ade5ae14c59a5d22ae3235b88283c0035";

// keccak256('savePrivateDataWithoutMinting(address addr, string memory data,
// string memory cryptoLabel, address labelHash, uint256 deadline)');
const SAVE_PERMIT_TYPE_HASH = "0x50a5dca0d9658d6eb6282f2d7bdda2a899b962259e2708f7cce8c48021a63483";

//keccak256('queryPrivateDataByIndex(address addr, uint64 index, uint256 deadline)')
const INDEX_QUERY_PERMIT_TYPE_HASH =
	"0xbcb00634c612072a661bb64fa073e7806d31f3790f1c827cd20f95542b5af679";

//keccak256('queryPrivateDataByName(address addr, address labelHash, uint256 deadline)')
const NAME_QUERY_PERMIT_TYPE_HASH =
	"0xab4ac209d4a97678c29d0f2f4ef3539a24e0ce6dbd2dd481c818134b61d28ecc";

//keccak256('initPrivateVault(address addr, uint256 deadline)')
const INIT_VAULT_PERMIT_TYPE_HASH = "0xef93604cd5c5e7d35e7ef7d38e1cac9e1cc450e49bc931effd1f65a5a993121d";

//keccak256('vaultHasRegister(address addr, uint256 deadline)')
const VAULT_HAS_REGISTER_PERMIT_TYPE_HASH = "0x5a14c87645febe5840f128409acb12772ff89f3398b05142d7e039c76e0844e8";

//keccak256('hasMinted(address addr, uint256 deadline)')
const HAS_MINTED_PERMIT_TYPE_HASH = "0xdbd66a895de1fdf2e44b84c83cf1e4f482f647eb80397d069bf7763a583ce1a5";

//keccak256('totalSavedItems(address addr, uint256 deadline)')
const TOTAL_SAVED_ITEMS_PERMIT_TYPE_HASH = "0xf65e93839555276acb1b1c33eb49dff5fa6a88c6991b9b84b680dc961b85f847";

//keccak256('getLabelNameByIndex(address addr, uint256 deadline, uint64 index)')
const GET_LABEL_NAME_BY_INDEX = "0xbd5bc3ca2c7ea773b900edfe638ad04ce3697bf85885abdbe90a2f7c1266d9ee";

//keccak256('queryPrivateVaultAddress(address addr, uint256 deadline)')
const QUERY_PRIVATE_VAULT_ADDRESS_PERMIT_TYPE_HASH = "0x21b7e085fb49739c78b83ddb0a8a7e4b469211d08958f57d52ff68325943de04";

//keccak256('labelExist(address addr, address labelHash, uint256 deadline)')
const LABEL_EXIST_TYPE_HASH = "0xac1275bd89417f307b1ae27de4967e4910dfab4abd173eb3e6a3352c21ae42fe";

// =========== private vault contract caller used ===========
//keccak256('labelNameDirectly(uint64 index, uint256 deadline)')
const LABEL_NAME_PERMIT_TYPE_HASH =
	"0xcbb2475c190d2e287f7de56c688846f7612f70b210a3856ad34c475cbad0dda7";

//keccak256('getPrivateDataByNameDirectly(address name, uint256 deadline)')
const  GET_PRIVATE_DATA_BY_NAME_PERMIT_TYPE_HASH =
	"0x91fb9dd060bd9ffe42a43373e9de88b3a9b106cbce07f242fd6f2c4a41ef921d";

//keccak256('getPrivateDataByIndexDirectly(uint64 index, uint256 deadline)')
const  GET_PRIVATE_DATA_BY_INDEX_PERMIT_TYPE_HASH =
	"0x17558919af4007c4fb94572ba8e807922ff7db103814e127ad21ef481ca35d98";

//keccak256('saveWithoutMintingDirectly(string memory data, string memory cryptoLabel, address labelHash, uint256 deadline, bytes memory params)')
const  SAVE_WITHOUT_MINTING_PERMIT_TYPE_HASH =
	"0xb5874d5c3f6f8ad0eddae31287a8b0ff49e374249cd2389616fb828f06f42f63";

//keccak256('saveWithMintingDirectly(string memory data, string memory cryptoLabel, address labelHash, uint256 deadline)')
const SAVE_WITH_MINTING_PERMIT_TYPE_HASH =
	"0x8774f567563ee2634c371978f5cfa8e41e5d255912344cb6b7d652f94c66c8a4";

//keccak256('labelIsExistDirectly(address labelHash, uint256 deadline)')
const LABEL_EXIST_DIRECTLY_PERMIT_TYPE_HASH = "0x5e9a0e1424c7f33522faa862eafa09a676e96246da16c8b58d5803ba8010584f";

//keccak256('updateValidator(address _privateValidator, uint256 deadline)')
const  UPDATE_VALIDATOR_PERMIT_TYPE_HASH = "0x79c473821b1882439e653292df5add05615ab1a78b695620f6cf37ab0fb6dbbc";

const SAVING_PRIVATE_DATA_FEE = 300000000000000;

const hre = require("hardhat");
const { ethers } = require("ethers");

let vaultHubAddr = "";
let treasuryAddr = "";
let seedTokenAddr = "";
let privateVaultAddr = "";
let privateValidator = "";
const privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";

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

  const Seeder = await hre.ethers.getContractFactory("SeedToken");
  const seeder = await Seeder.deploy();
  await seeder.deployed();
  console.log("SeedToken deployed to:", seeder.address);
  seedTokenAddr = seeder.address;

  const Treasury = await hre.ethers.getContractFactory("Treasury");
  const treasury = await Treasury.deploy(seeder.address);
  await treasury.deployed();
  console.log("Treasury deployed to:", treasury.address);
  treasuryAddr = treasury.address;

  const VaultHub = await hre.ethers.getContractFactory("VaultHub");
  const vaulthub = await VaultHub.deploy(vPermission.address);
  await vaulthub.deployed();
  console.log("VaultHub deployed to:", vaulthub.address);
  vaultHubAddr = vaulthub.address;

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
