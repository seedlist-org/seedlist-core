const { ethers } = require("ethers");

function calculateSolidityPermitHash() {
	console.log(
		"vaultHasRegister: ",
		ethers.utils.solidityKeccak256(["string"], ["vaultHasRegister(address addr, uint256 deadline)"]),
	);
	console.log("hasMinted: ", ethers.utils.solidityKeccak256(["string"], ["hasMinted(address addr, uint256 deadline)"]));
	console.log(
		"totalSavedItems: ",
		ethers.utils.solidityKeccak256(["string"], ["totalSavedItems(address addr, uint256 deadline)"]),
	);

	console.log(
		"queryPrivateVaultAddress: ",
		ethers.utils.solidityKeccak256(["string"], ["queryPrivateVaultAddress(address addr, uint256 deadline)"]),
	);

	console.log(
		"getLabelNameByIndex: ",
		ethers.utils.solidityKeccak256(["string"], ["getLabelNameByIndex(address addr, uint256 deadline, uint64 index)"]),
	);
	console.log(
		"savePrivateDataWithoutMinting: ",
		ethers.utils.solidityKeccak256(
			["string"],
			[
				"savePrivateDataWithoutMinting(address addr, string calldata data, string calldata cryptoLabel, address hashLabel, uint256 deadline)",
			],
		),
	);
	console.log(
		"savePrivateDataWithMinting: ",
		ethers.utils.solidityKeccak256(
			["string"],
			[
				"savePrivateDataWithMinting(address addr, string calldata data, string calldata cryptoLabel, address hashLabel, address receiver, uint256 deadline)",
			],
		),
	);
	console.log(
		"queryPrivateDataByIndex: ",
		ethers.utils.solidityKeccak256(
			["string"],
			["queryPrivateDataByIndex(address addr, uint64 index, uint256 deadline)"],
		),
	);
	console.log(
		"queryPrivateDataByName: ",
		ethers.utils.solidityKeccak256(
			["string"],
			["queryPrivateDataByName(address addr, address labelHash, uint256 deadline)"],
		),
	);
	console.log(
		"initPrivateVault: ",
		ethers.utils.solidityKeccak256(["string"], ["initPrivateVault(address addr, uint256 deadline)"]),
	);
	console.log(
		"labelExist: ",
		ethers.utils.solidityKeccak256(["string"], ["labelExist(address addr, address labelHash, uint256 deadline)"]),
	);
	console.log(
		"domain: ",
		ethers.utils.solidityKeccak256(
			["string"],
			["EIP712Domain(string name, string version, uint256 chainId, address VaultHubContract)"],
		),
	);

	console.log("====================================================");
	console.log(
		"private-vault-domain:",
		ethers.utils.solidityKeccak256(
			["string"],
			["EIP712Domain(string name, string version, uint256 chainId, address PrivateVaultContract)"],
		),
	);

	console.log(
		"private-labelNameDirectly:",
		ethers.utils.solidityKeccak256(["string"], ["labelNameDirectly(uint64 index, uint256 deadline)"]),
	);

	console.log(
		"private-getPrivateDataByNameDirectly:",
		ethers.utils.solidityKeccak256(["string"], ["getPrivateDataByNameDirectly(address name, uint256 deadline)"]),
	);

	console.log(
		"private-getPrivateDataByIndexDirectly:",
		ethers.utils.solidityKeccak256(["string"], ["getPrivateDataByIndexDirectly(uint64 index, uint256 deadline)"]),
	);

	console.log(
		"private-saveWithoutMintingDirectly:",
		ethers.utils.solidityKeccak256(
			["string"],
			[
				"saveWithoutMintingDirectly(string calldata data, string calldata cryptoLabel, address labelHash, uint256 deadline, bytes memory params)",
			],
		),
	);

	console.log(
		"private-labelExistDirectly:",
		ethers.utils.solidityKeccak256(["string"], ["labelIsExistDirectly(address labelHash, uint256 deadline)"]),
	);

	console.log(
		"private-updateValidator:",
		ethers.utils.solidityKeccak256(["string"], ["updateValidator(address _privateValidator, uint256 deadline)"]),
	);
}

async function main() {
	console.log(
		"hasRegisterPermit:",
		ethers.utils.solidityKeccak256( ["string"],["hasRegisterPermit(address,uint256,uint8,bytes32,bytes32,bytes32)"]).substr(0, 10),
	);

	console.log("initPermit:",
		ethers.utils.solidityKeccak256(["string"],["initPermit(address,uint256,uint8,bytes32,bytes32,bytes32)"]).substr(0,10));

	console.log("getLabelExistPermit:",
		ethers.utils.solidityKeccak256(["string"],["getLabelExistPermit(address,address,uint256,uint8,bytes32,bytes32,bytes32)"]).substr(0,10));

	console.log("getLabelNamePermit:",
		ethers.utils.solidityKeccak256(["string"],["getLabelNamePermit(address,uint256,uint64,uint8,bytes32,bytes32,bytes32)"]).substr(0,10));

	console.log("totalSavedItemsPermit:",
		ethers.utils.solidityKeccak256(["string"],["totalSavedItemsPermit(address,uint256,uint8,bytes32,bytes32,bytes32)"]).substr(0,10));

	console.log("hasMintedPermit:",
		ethers.utils.solidityKeccak256(["string"],["hasMintedPermit(address,uint256,uint8,bytes32,bytes32,bytes32)"]).substr(0,10));

	console.log("queryPrivateVaultAddressPermit:",
		ethers.utils.solidityKeccak256(["string"],["queryPrivateVaultAddressPermit(address,uint256,uint8,bytes32,bytes32,bytes32)"]).substr(0,10));

	console.log("queryByNamePermit:",
		ethers.utils.solidityKeccak256(["string"],["queryByNamePermit(address,address,uint256,uint8,bytes32,bytes32,bytes32)"]).substr(0,10));

	console.log("queryByIndexPermit:",
		ethers.utils.solidityKeccak256(["string"],["queryByIndexPermit(address,uint64,uint256,uint8,bytes32,bytes32,bytes32)"]).substr(0,10));

	console.log("saveWithoutMintPermit:",
		//ethers.utils.solidityKeccak256(["string"],["saveWithoutMintPermit(address,string memory,string memory,address,uint256,uint8,bytes32,bytes32,bytes32)"]).substr(0,10));
		ethers.utils.solidityKeccak256(["string"],["saveWithoutMintPermit(address,string,string,address,uint256,uint8,bytes32,bytes32,bytes32)"]).substr(0,10));

	console.log("mintSavePermit:",
		//ethers.utils.solidityKeccak256(["string"],["mintSavePermit(address,string memory,string memory,address,address,uint256,uint8,bytes32,bytes32,bytes32)"]).substr(0,10));
		ethers.utils.solidityKeccak256(["string"],["mintSavePermit(address,string,string,address,address,uint256,uint8,bytes32,bytes32,bytes32)"]).substr(0,10));


	console.log("\n\n=====================================\n\n")
// private vault used
	console.log("labelIsExistPermit:",
		ethers.utils.solidityKeccak256(["string"],["labelIsExistPermit(address,address,uint256,uint8,bytes32,bytes32,bytes32)"]).substr(0,10));
	console.log("labelNamePermit:",
		ethers.utils.solidityKeccak256(["string"],["labelNamePermit(address,uint64,uint256,uint8,bytes32,bytes32,bytes32)"]).substr(0,10));
	console.log("getPrivateDataByNamePermit:",
		ethers.utils.solidityKeccak256(["string"],["getPrivateDataByNamePermit(address,address,uint256,uint8,bytes32,bytes32,bytes32)"]).substr(0,10));
	console.log("getPrivateDataByIndexPermit:",
		ethers.utils.solidityKeccak256(["string"],["getPrivateDataByIndexPermit(address,uint64,uint256,uint8,bytes32,bytes32,bytes32)"]).substr(0,10));
	console.log("saveWithoutMintingPermit:",
		ethers.utils.solidityKeccak256(["string"],["saveWithoutMintingPermit(address,string,string,bytes,address,uint256,uint8,bytes32,bytes32,bytes32)"]).substr(0,10));
	console.log("saveWithMintingPermit:", //don't contain memory key-word
		ethers.utils.solidityKeccak256(["string"],["saveWithMintingPermit(address,string,string,address,uint256,uint8,bytes32,bytes32,bytes32)"]).substr(0,10));
	console.log("updateValidatorPermit:", //don't contain memory key-word
		ethers.utils.solidityKeccak256(["string"],["updateValidatorPermit(address,address,uint256,uint8,bytes32,bytes32,bytes32)"]).substr(0,10));


	console.log("\n\n===============================================\n\n");
	calculateSolidityPermitHash();
}

	main()
		.then(() => process.exit(0))
		.catch(error => {
			console.error(error);
		process.exit(1);
	});
