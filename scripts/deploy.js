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
	await testVaultHub();
	//await testTreasury();
	//await testPrivateVault();
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
  seedTokenAddr = seeder.address;

  const Treasury = await hre.ethers.getContractFactory("Treasury");
  const treasury = await Treasury.deploy(seeder.address);
  await treasury.deployed();
  console.log("Treasury deployed to:", treasury.address);
  treasuryAddr = treasury.address;

  const Validator = await hre.ethers.getContractFactory("Validator");
  const validator = await Validator.deploy();
  await validator.deployed();
  console.log("Validator deployed to:", validator.address);

  const PrivateValidator = await hre.ethers.getContractFactory("PrivateValidator");
  const pvalidator = await PrivateValidator.deploy();
  await pvalidator.deployed();
  console.log("Private Validator deployed to:", pvalidator.address);
  privateValidator = pvalidator.address;

  const Worker = await hre.ethers.getContractFactory("Worker");
  const worker = await Worker.deploy();
  await worker.deployed();
  console.log("Worker deployed to:", worker.address);

  const validatorContract = new hre.ethers.Contract(validator.address, Validator.interface, signer);
  let transactionResp = await validatorContract.updateWorker(worker.address);
  let receipt0 = await transactionResp.wait(1);
  console.log("set worker belonged to valid validator finished");

  const VaultHub = await hre.ethers.getContractFactory("VaultHub");
  const vaulthub = await VaultHub.deploy(validator.address, vPermission.address, pPermission.address);
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

async function testTreasury(){
	const accounts = await hre.ethers.getSigners();
	const signer = accounts[0];
	let Treasure = await  hre.ethers.getContractFactory("Treasury");
	let treasury = new hre.ethers.Contract(treasuryAddr, Treasure.interface, signer);

	let seed0Resp = await treasury.withdraw(signer.address, seedTokenAddr, ethers.BigNumber.from("50000000000000000000"));
	let res0 = await seed0Resp.wait(1);
	console.log("withdraw 100 SEED finish, ",res0);

	let seed1Resp = await treasury.withdraw(signer.address, seedTokenAddr, ethers.BigNumber.from("50000000000000000000"));
	let res1 = await seed1Resp.wait(1);
	console.log("withdraw 50 SEED finish, ", res1);

	let Resp = await treasury.setHalf(true);
	let res = await Resp.wait(1);
	console.log("set half finish");
	let seed2Resp = await treasury.withdraw(signer.address, seedTokenAddr, ethers.BigNumber.from("50000000000000000000"));
	let res2 = await seed2Resp.wait(1);
	console.log("withdraw 25 SEED finish, ",res2);

	let seed3Resp = await treasury.withdraw(signer.address, seedTokenAddr, ethers.BigNumber.from("50000000000000000000"));
	let res3 = await seed3Resp.wait(1);
	console.log("withdraw 25 SEED finish, ",res3);

	let seed4Resp = await treasury.withdraw(signer.address, seedTokenAddr, ethers.BigNumber.from("50000000000000000000"));
	let res4 = await seed4Resp.wait(1);
	console.log("withdraw 25 SEED finish, ",res4);

	let rulesResp = await treasury.addRule("Hello Rule");
	let res5 = await rulesResp.wait(1);
	console.log("add Rule finished");
	let num = await treasury.ruleSize();
	console.log("num:",num);
	let rule = await treasury.rules(num-1);
	console.log("rule:",rule);

	let ethResp = await treasury.withdrawETH("0xB1799E2ccB10E4a8386E17474363A2BE8e33cDfb", ethers.BigNumber.from("1000000000000000000"));
	ethResp.wait(1);
	console.log("withdraw 1 ETH finish, resp:",ethResp);
}

async function makeSignature(message) {
	let wallet = new ethers.Wallet(privateKey);
	let messageHash = ethers.utils.keccak256(ethers.utils.arrayify(message.toLowerCase()));
	let messageHashBytes = ethers.utils.arrayify(messageHash);
	let flatSig = await wallet.signMessage(messageHashBytes);
	let sig = ethers.utils.splitSignature(flatSig);
	return sig;
}

async function testPrivateVault() {
	const accounts = await hre.ethers.getSigners();
	const signer = accounts[0];

	let PrivateVault = await hre.ethers.getContractFactory("PrivateVault");
	let privateVault = new hre.ethers.Contract(privateVaultAddr, PrivateVault.interface, signer);

	//npx hardhat node account-0 private key, address: 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266
	let wallet = new ethers.Wallet(privateKey);
	let address = await wallet.getAddress();
	let deadline = Date.parse(new Date().toString()) / 1000 + 300;

	let DOMAIN = await privateVault.DOMAIN_SEPARATOR();
	console.log("private vault DOMAIN:",DOMAIN);

	let label1Hash= "0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199";
	let combineMessage = ethers.utils.solidityKeccak256(
		["address","address", "uint", "bytes32", "bytes32"],
		[address,privateValidator, deadline, DOMAIN, UPDATE_VALIDATOR_PERMIT_TYPE_HASH],
	);
	let signature = await makeSignature(combineMessage);
	let updateRes = await privateVault.updateValidator(
		privateValidator,
		deadline,
		signature.v,
		signature.r,
		signature.s
	);
	await  updateRes.wait(1);
	console.log("update result:", updateRes);

	let params = ethers.utils.defaultAbiCoder.encode( ["address", "uint24"], ["0xf32d39ff9f6aa7a7a64d7a4f00a54826ef791a55", 500]);
	let saveingMessage = ethers.utils.solidityKeccak256(
		["address","string", "string","bytes", "address", "uint", "bytes32", "bytes32"],
		[address, "What did", "labelNew", params, label1Hash,deadline, DOMAIN, SAVE_WITHOUT_MINTING_PERMIT_TYPE_HASH]
	);
	let signature0 = await makeSignature(saveingMessage);
	let savingRes = await privateVault.saveWithoutMintingDirectly(
		"What did",
		"labelNew",
		label1Hash,
		deadline,
		signature0.v,
		signature0.r,
		signature0.s,
		params
	)
	await savingRes.wait(1)
	console.log("saving Res:", savingRes)

	let getbyIndexMessage = ethers.utils.solidityKeccak256(
		["address","uint64","uint", "bytes32", "bytes32"],
		[address, 0, deadline, DOMAIN, GET_PRIVATE_DATA_BY_INDEX_PERMIT_TYPE_HASH]
	);
	let  signature1 = await makeSignature(getbyIndexMessage);
	let  getByIndexRes = await privateVault.getPrivateDataByIndexDirectly(
		0,
		deadline,
		signature1.v,
		signature1.r,
		signature1.s
	)
	console.log("get by index-0 directly:", getByIndexRes)

	let getByNameMessage = ethers.utils.solidityKeccak256(
		["address", "address", "uint", "bytes32", "bytes32"],
		[address,label1Hash,deadline, DOMAIN, GET_PRIVATE_DATA_BY_NAME_PERMIT_TYPE_HASH]
	)
	let signature2 = await makeSignature(getByNameMessage);

	let getByNameRes = await privateVault.getPrivateDataByNameDirectly(
		label1Hash,
		deadline,
		signature2.v,
		signature2.r,
		signature2.s
	)
	console.log("get by name directly:", getByNameRes)

	let total = await privateVault.total();
	console.log("total saving:", total)

	let labelNameMessage = ethers.utils.solidityKeccak256(
		["address", "uint64", "uint", "bytes32", "bytes32"],
		[address, 2, deadline, DOMAIN, LABEL_NAME_PERMIT_TYPE_HASH]
	)
	let signature3 =await makeSignature(labelNameMessage);
	let getLabelNameRes = await privateVault.labelNameDirectly(
		2, deadline, signature3.v, signature3.r, signature3.s
	)
	console.log("get labelName res:", getLabelNameRes)

	let labelExistMessage = ethers.utils.solidityKeccak256(
		["address", "address","uint", "bytes32", "bytes32"],
		[address, label1Hash, deadline, DOMAIN, LABEL_EXIST_DIRECTLY_PERMIT_TYPE_HASH]
	)
	let signature4 = await makeSignature(labelExistMessage);
	let labelExistRes = await privateVault.labelIsExistDirectly(
		label1Hash,
		deadline,
		signature4.v,
		signature4.r,
		signature4.s
	)
	console.log("label(this.Label1Hash) exist:", labelExistRes)
}

async function testVaultHub() {
	const accounts = await hre.ethers.getSigners();
	const signer = accounts[0];

	let VaultHub = await hre.ethers.getContractFactory("VaultHub");
	let vaultHub = new hre.ethers.Contract(vaultHubAddr, VaultHub.interface, signer);

    //npx hardhat node account-0 private key, address: 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266
	let wallet = new ethers.Wallet(privateKey);
	let address = await wallet.getAddress();

	let deadline = Date.parse(new Date().toString()) / 1000 + 300;

	let DOMAIN = await vaultHub.DOMAIN_SEPARATOR();
	console.log("DOMAIN:",DOMAIN);

	//let INIT_VAULt_PERMIT = await vaultHub.VAULTHUB_INIT_VAULT_PERMIT_TYPE_HASH();
	let INIT_VAULt_PERMIT = INIT_VAULT_PERMIT_TYPE_HASH;
	let _combineMessage = ethers.utils.solidityKeccak256(
		["address", "uint", "bytes32", "bytes32"],
		[address, deadline, DOMAIN, INIT_VAULT_PERMIT_TYPE_HASH],
	);
	let sig = await makeSignature(_combineMessage);
	let initRes = await  vaultHub.initPrivateVault(address, deadline, sig.v, sig.r, sig.s);
	await initRes.wait(1);
	console.log("init vault res:", initRes)

	//let MINT_SAVE_PERMIT = await vaultHub.VAULTHUB_MINT_SAVE_PERMIT_TYPE_HASH();
	let label1Hash= "0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65";

	let combineMessage = ethers.utils.solidityKeccak256(
		["address", "string", "string", "address", "address", "uint", "bytes32", "bytes32"],
		[address, "Hello world", "label1",label1Hash, address, deadline, DOMAIN, MINT_SAVE_PERMIT_TYPE_HASH],
	);
	let signature = await makeSignature(combineMessage);
	let mintSaveRes = await vaultHub.savePrivateDataWithMinting(
		address,
		"Hello world",
		"label1",
		label1Hash,
		address,
		deadline,
		signature.v,
		signature.r,
		signature.s,
		{value:SAVING_PRIVATE_DATA_FEE}
	);
	let res = await mintSaveRes.wait(1);
	console.log("mint save result:", res);


	//let SAVE_PERMIT = await vaultHub.VAULTHUB_SAVE_PERMIT_TYPE_HASH();
	let label2Hash= "0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc";
	let combineMessage0 = ethers.utils.solidityKeccak256(
		["address", "string", "string","address", "uint", "bytes32", "bytes32"],
		[address, "Hello world0", "label2", label2Hash, deadline, DOMAIN, SAVE_PERMIT_TYPE_HASH],
	);
	let signature0 = await makeSignature(combineMessage0);
	let saveRes = await vaultHub.savePrivateDataWithoutMinting(
		address,
		"Hello world0",
		"label2",
		label2Hash,
		deadline,
		signature0.v,
		signature0.r,
		signature0.s,
		{value:SAVING_PRIVATE_DATA_FEE}
	);
	await saveRes.wait(1)
	console.log("save Result:", saveRes);

	//let INDEX_QUERY_PERMIT = await vaultHub.VAULTHUB_INDEX_QUERY_PERMIT_TYPE_HASH();
	let combineMessage1 = ethers.utils.solidityKeccak256(
		["address", "uint64", "uint", "bytes32", "bytes32"],
		[address, 0, deadline, DOMAIN, INDEX_QUERY_PERMIT_TYPE_HASH],
	);
	let signature1 = await makeSignature(combineMessage1);

	let val1 = await vaultHub.queryPrivateDataByIndex(
		address,
		0,
		deadline,
		signature1.v,
		signature1.r,
		signature1.s,
	);
	console.log("query by index 0:", val1);

	//let NAME_QUERY_PERMIT = await vaultHub.VAULTHUB_NAME_QUERY_PERMIT_TYPE_HASH();
	let combineMessage2 = ethers.utils.solidityKeccak256(
		["address", "address", "uint", "bytes32", "bytes32"],
		[address, label2Hash, deadline, DOMAIN, NAME_QUERY_PERMIT_TYPE_HASH],
	);
	let signature2 = await makeSignature(combineMessage2);
	let val2 = await vaultHub.queryPrivateDataByName(
		address,
		label2Hash,
		deadline,
		signature2.v,
		signature2.r,
		signature2.s,
	);
	console.log("query by label2:", val2);


	//let BASE_PERMIT = await vaultHub.VAULTHUB_HAS_MINTED_PERMIT_TYPE_HASH();
	let __combineMessage = ethers.utils.solidityKeccak256(
		["address", "uint", "bytes32", "bytes32"],
		[address, deadline, DOMAIN, HAS_MINTED_PERMIT_TYPE_HASH],
	);
	let _sig = await makeSignature(__combineMessage);
	let minted = await  vaultHub.hasMinted(address, deadline, _sig.v, _sig.r, _sig.s);
	console.log("minted res:", minted)

	//let TOTAL_SAVED_PERMIT = await vaultHub.TOTAL_SAVED_ITEMS_PERMIT_TYPE_HASH();
	let __combineMessage0 = ethers.utils.solidityKeccak256(
		["address", "uint", "bytes32", "bytes32"],
		[address, deadline, DOMAIN, TOTAL_SAVED_ITEMS_PERMIT_TYPE_HASH],
	);
	let _sig0 = await makeSignature(__combineMessage0);
	let total = await vaultHub.totalSavedItems(address, deadline, _sig0.v, _sig0.r, _sig0.s);
	console.log("total:", total)

	//let HAS_REGISTER_PERMIT = await vaultHub.VAULTHUB_VAULT_HAS_REGISTER_PERMIT_TYPE_HASH();
	let __combineMessage1 = ethers.utils.solidityKeccak256(
		["address", "uint", "bytes32", "bytes32"],
		[address, deadline, DOMAIN, VAULT_HAS_REGISTER_PERMIT_TYPE_HASH],
	);
	let _sig1 = await makeSignature(__combineMessage1);
	let hasRegister = await vaultHub.vaultHasRegister(address, deadline, _sig1.v, _sig1.r, _sig1.s);
	if(hasRegister == true){
		console.log("address:", address, " has register, please change one");
		//return;
	}

	let __combineMessage2 = ethers.utils.solidityKeccak256(
		["address", "uint", "bytes32", "bytes32"],
		[address, deadline, DOMAIN, QUERY_PRIVATE_VAULT_ADDRESS_PERMIT_TYPE_HASH],
	);
	let _sig2 =await makeSignature(__combineMessage2);
	privateVaultAddr= await vaultHub.queryPrivateVaultAddress(address, deadline, _sig2.v, _sig2.r, _sig2.s);
	console.log("vault address:", privateVaultAddr);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
