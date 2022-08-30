const { ethers } = require("ethers");

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
		ethers.utils.solidityKeccak256(["string"],["saveWithoutMintingPermit(address,string,string,address,uint256,uint8,bytes32,bytes32,bytes32)"]).substr(0,10));
	console.log("saveWithMintingPermit:", //don't contain memory key-word
		ethers.utils.solidityKeccak256(["string"],["saveWithMintingPermit(address,string,string,address,uint256,uint8,bytes32,bytes32,bytes32)"]).substr(0,10));
}

	main()
		.then(() => process.exit(0))
		.catch(error => {
			console.error(error);
		process.exit(1);
	});
