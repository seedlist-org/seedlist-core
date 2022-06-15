// We require the Hardhat Runtime Environment explicitly here. This is optional 
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
//const {GenEthereumBrainWallet} = require("../../seedlist-interface-ts/src/lib/brainwallet");

const hre = require("hardhat");
const { ethers } = require("ethers");

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


  const Treasury = await hre.ethers.getContractFactory("Treasury");
  const treasury = await Treasury.deploy(seeder.address);
  await treasury.deployed();
  console.log("Treasury deployed to:", treasury.address);

  const VaultHub = await hre.ethers.getContractFactory("VaultHub");
  const vaulthub = await VaultHub.deploy();
  await vaulthub.deployed();
  console.log("VaultHub deployed to:", vaulthub.address);

  const accounts = await hre.ethers.getSigners();
  const signer = accounts[0];
  const seedToken = new hre.ethers.Contract(seeder.address, Seeder.interface, signer);

  let transactionResponse = await seedToken.setMinter(treasury.address);
  let receipt = await transactionResponse.wait(1)
  console.log("set minter for seedlist token finished");

  const treasuryContract = new hre.ethers.Contract(treasury.address, Treasury.interface, signer);
  let transactionResp = await treasuryContract.setCaller(vaulthub.address);
  let receipt0 = await transactionResp.wait(1);
  console.log("set caller for treasury finished");

  const vaultHubContract = new hre.ethers.Contract(vaulthub.address, VaultHub.interface, signer);
  let transResponse = await vaultHubContract.setTreasuryAddress(treasury.address);
  let receipt1 = await  transResponse.wait(1);
  console.log("vaulthub set treasury finished");
  let DOMAIN = await vaultHubContract.DOMAIN_SEPARATOR();
  console.log("DOMAIN_SEPARATOR:",DOMAIN);
}

async function _main() {
	const accounts = await hre.ethers.getSigners();
	const signer = accounts[0];

	let hubAddress = "0x8cC65684853B84E578aAA5F2CEE0fDa10A688560";
	let VaultHub = await hre.ethers.getContractFactory("VaultHub");
	let vaultHub = new hre.ethers.Contract(hubAddress, VaultHub.interface, signer);

	let treasureAddr = "0x7461728DdA7bFD129B5860bb901922F833952320";
	let Treasure = await  hre.ethers.getContractFactory("Treasury");
	let treasury = new hre.ethers.Contract(treasureAddr, Treasure.interface, signer);

	//老seed 转出来, 是我本人通过metamask转入的这个地址，转入500个；现在提出400个； addr: 0xa32a90C856Fa523f83bEEB281f2Eb04EEB724225
/*
	let seed0Resp = await treasury.withdraw("0xB1799E2ccB10E4a8386E17474363A2BE8e33cDfb","0xa32a90C856Fa523f83bEEB281f2Eb04EEB724225", ethers.BigNumber.from("100000000000000000000"));
	seed0Resp.wait(1);
	console.log("withdraw 400 seed0 finish");
	//新铸了210个token，转出100个；
	let seed1Resp = await treasury.withdraw("0xB1799E2ccB10E4a8386E17474363A2BE8e33cDfb","0xCE1d9f9983fecbD22BAE483Bc4b37F5783Ee41BD", ethers.BigNumber.from("110000000000000000000"));
	seed1Resp.wait(1);
	console.log("withdraw 100 seed1 finish");
	//本地址有1个ETH，现在提出1个；
	let ethResp = await treasury.withdrawETH("0xB1799E2ccB10E4a8386E17474363A2BE8e33cDfb", ethers.BigNumber.from("1000000000000000000"));
	ethResp.wait(1);
	console.log("withdraw 1 ETH finish");
*/

	let privateKey = "0x88347684515a71ea770b6049e3248db13ced888ccdad502ecbc1c14df5074002";
	let wallet = new ethers.Wallet(privateKey);
	let address = await wallet.getAddress();

	let deadline = Date.parse(new Date().toString()) / 1000 + 300;

	let DOMAIN = await vaultHub.DOMAIN_SEPARATOR();
	console.log("DOMAIN:",DOMAIN);
	return;
	let INIT_VAULt_PERMIT = await vaultHub.INIT_VAULT_PERMIT_TYPE_HASH();
	let _combineMessage = ethers.utils.solidityKeccak256(
		["address", "uint", "bytes32", "bytes32"],
		[address, deadline, DOMAIN, INIT_VAULt_PERMIT],
	);
	let messageHash = ethers.utils.keccak256(ethers.utils.arrayify(_combineMessage.toLowerCase()));
	let messageHashBytes = ethers.utils.arrayify(messageHash);
	let flatSig = await wallet.signMessage(messageHashBytes);
	let sig = ethers.utils.splitSignature(flatSig);
	let initRes = await  vaultHub.initPrivateVault(address, deadline, sig.v, sig.r, sig.s);
	await initRes.wait(1);
	console.log("init vault res:", initRes)

	let MINT_SAVE_PERMIT = await vaultHub.MINT_SAVE_PERMIT_TYPE_HASH();
	let combineMessage = ethers.utils.solidityKeccak256(
		["address", "string", "string", "address", "uint", "bytes32", "bytes32"],
		[address, "Hello world", "label1", address, deadline, DOMAIN, MINT_SAVE_PERMIT],
	);
	let msgHash = ethers.utils.keccak256(ethers.utils.arrayify(combineMessage.toLowerCase()));

	let msgHashBytes = ethers.utils.arrayify(msgHash);
	let flatSignature = await wallet.signMessage(msgHashBytes);
	let signature = ethers.utils.splitSignature(flatSignature);
	let mintSaveRes = await vaultHub.savePrivateDataWithMinting(
		address,
		"Hello world",
		"label1",
		address,
		deadline,
		signature.v,
		signature.r,
		signature.s,
	);
	await  mintSaveRes.wait(1);
	console.log("mint save result:", mintSaveRes);


	let SAVE_PERMIT = await vaultHub.SAVE_PERMIT_TYPE_HASH();
	let combineMessage0 = ethers.utils.solidityKeccak256(
		["address", "string", "string", "uint", "bytes32", "bytes32"],
		[address, "Hello world0", "label2", deadline, DOMAIN, SAVE_PERMIT],
	);
	let msgHash0 = ethers.utils.keccak256(ethers.utils.arrayify(combineMessage0.toLowerCase()));

	let msgHashBytes0 = ethers.utils.arrayify(msgHash0);
	let flatSignature0 = await wallet.signMessage(msgHashBytes0);
	let signature0 = ethers.utils.splitSignature(flatSignature0);
	let saveRes = await vaultHub.savePrivateDataWithoutMinting(
		address,
		"Hello world0",
		"label2",
		deadline,
		signature0.v,
		signature0.r,
		signature0.s,
	);
	await saveRes.wait(1)
	console.log("save Result:", saveRes);

	let INDEX_QUERY_PERMIT = await vaultHub.INDEX_QUERY_PERMIT_TYPE_HASH();
	let combineMessage1 = ethers.utils.solidityKeccak256(
		["address", "uint16", "uint", "bytes32", "bytes32"],
		[address, 0, deadline, DOMAIN, INDEX_QUERY_PERMIT],
	);
	let msgHash1 = ethers.utils.keccak256(ethers.utils.arrayify(combineMessage1.toLowerCase()));
	let msgHashBytes1 = ethers.utils.arrayify(msgHash1);
	let flatSignature1 = await wallet.signMessage(msgHashBytes1);
	let signature1 = ethers.utils.splitSignature(flatSignature1);
	let val1 = await vaultHub.queryPrivateDataByIndex(
		address,
		0,
		deadline,
		signature1.v,
		signature1.r,
		signature1.s,
	);
	console.log("query by index 0:", val1);

	let NAME_QUERY_PERMIT = await vaultHub.NAME_QUERY_PERMIT_TYPE_HASH();
	let combineMessage2 = ethers.utils.solidityKeccak256(
		["address", "string", "uint", "bytes32", "bytes32"],
		[address, "label2", deadline, DOMAIN, NAME_QUERY_PERMIT],
	);
	let msgHash2 = ethers.utils.keccak256(ethers.utils.arrayify(combineMessage2.toLowerCase()));
	let msgHashBytes2 = ethers.utils.arrayify(msgHash2);
	let flatSignature2 = await wallet.signMessage(msgHashBytes2);
	let signature2 = ethers.utils.splitSignature(flatSignature2);
	let val2 = await vaultHub.queryPrivateDataByName(
		address,
		"label2",
		deadline,
		signature2.v,
		signature2.r,
		signature2.s,
	);
	console.log("query by label2:", val2);


	let BASE_PERMIT = await vaultHub.HAS_MINTED_PERMIT_TYPE_HASH();
	let __combineMessage = ethers.utils.solidityKeccak256(
		["address", "uint", "bytes32", "bytes32"],
		[address, deadline, DOMAIN, BASE_PERMIT],
	);
	let _messageHash = ethers.utils.keccak256(ethers.utils.arrayify(__combineMessage.toLowerCase()));
	let _messageHashBytes = ethers.utils.arrayify(_messageHash);
	let _flatSig = await wallet.signMessage(_messageHashBytes);
	let _sig = ethers.utils.splitSignature(_flatSig);
	let minted = await  vaultHub.hasMinted(address, deadline, _sig.v, _sig.r, _sig.s);
	console.log("minted res:", minted)

	let TOTAL_SAVED_PERMIT = await vaultHub.TOTAL_SAVED_ITEMS_PERMIT_TYPE_HASH();
	let __combineMessage0 = ethers.utils.solidityKeccak256(
		["address", "uint", "bytes32", "bytes32"],
		[address, deadline, DOMAIN, TOTAL_SAVED_PERMIT],
	);
	let _messageHash0 = ethers.utils.keccak256(ethers.utils.arrayify(__combineMessage0.toLowerCase()));
	let _messageHashBytes0 = ethers.utils.arrayify(_messageHash0);
	let _flatSig0 = await wallet.signMessage(_messageHashBytes0);
	let _sig0 = ethers.utils.splitSignature(_flatSig0);
	let total = await vaultHub.totalSavedItems(address, deadline, _sig0.v, _sig0.r, _sig0.s);
	console.log("total:", total)

	let HAS_REGISTER_PERMIT = await vaultHub.VAULT_HAS_REGISTER_PERMIT_TYPE_HASH();
	let __combineMessage1 = ethers.utils.solidityKeccak256(
		["address", "uint", "bytes32", "bytes32"],
		[address, deadline, DOMAIN, HAS_REGISTER_PERMIT],
	);
	let _messageHash1 = ethers.utils.keccak256(ethers.utils.arrayify(__combineMessage1.toLowerCase()));
	let _messageHashBytes1 = ethers.utils.arrayify(_messageHash1);
	let _flatSig1 = await wallet.signMessage(_messageHashBytes1);
	let _sig1 = ethers.utils.splitSignature(_flatSig1);
	let hasRegister = await vaultHub.vaultHasRegister(address, deadline, _sig1.v, _sig1.r, _sig1.s);
	if(hasRegister == true){
		console.log("address:", address, " has register, please change one");
		return;
	}
}
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
