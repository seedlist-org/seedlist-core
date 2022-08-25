// SPDX-License-Identifier: MIT
pragma solidity >=0.8.12;

library Constant {
    string public constant PRIVATE_DOMAIN_NAME = "privateVault@seedlist.org";
    string public constant PRIVATE_DOMAIN_VERSION = "1.0.0";
    // keccak256('EIP712Domain(string name, string version, uint256 chainId, address PrivateVaultContract)');
    bytes32 public constant PRIVATE_DOMAIN_TYPE_HASH =
        0xdad980a10e49615eb7fc5d7774307c8f04d959ac46349850121d52b1e409fc1e;

    //keccak256('labelNameDirectly(uint64 index, uint256 deadline)')
    bytes32 public constant PRIVATE_LABEL_NAME_PERMIT_TYPE_HASH =
        0xcbb2475c190d2e287f7de56c688846f7612f70b210a3856ad34c475cbad0dda7;

    //keccak256('labelIsExistDirectly(address labelHash, uint256 deadline)')
    bytes32 public constant PRIVATE_LABEL_EXIST_PERMIT_TYPE_HASH =
        0x5e9a0e1424c7f33522faa862eafa09a676e96246da16c8b58d5803ba8010584f;

    //keccak256('getPrivateDataByNameDirectly(address name, uint256 deadline)')
    bytes32 public constant PRIVATE_GET_PRIVATE_DATA_BY_NAME_PERMIT_TYPE_HASH =
        0x91fb9dd060bd9ffe42a43373e9de88b3a9b106cbce07f242fd6f2c4a41ef921d;

    //keccak256('getPrivateDataByIndexDirectly(uint64 index, uint256 deadline)')
    bytes32 public constant PRIVATE_GET_PRIVATE_DATA_BY_INDEX_PERMIT_TYPE_HASH =
        0x17558919af4007c4fb94572ba8e807922ff7db103814e127ad21ef481ca35d98;

    //keccak256('saveWithoutMintingDirectly(string memory data, string memory cryptoLabel, address labelHash, uint256 deadline)')
    bytes32 public constant PRIVATE_SAVE_WITHOUT_MINTING_PERMIT_TYPE_HASH =
        0x6681e086fd2042ee88d7eb0f54dbe27796a216fb36f4e834a75b15d90b082727;

    //keccak256('saveWithMintingDirectly(string memory data, string memory cryptoLabel, address labelHash, uint256 deadline)')
    bytes32 public constant PRIVATE_SAVE_WITH_MINTING_PERMIT_TYPE_HASH =
        0x8774f567563ee2634c371978f5cfa8e41e5d255912344cb6b7d652f94c66c8a4;

    string public constant VAULTHUB_DOMAIN_NAME = "vaulthub@seedlist.org";
    string public constant VAULTHUB_DOMAIN_VERSION = "1.0.0";
    // keccak256('EIP712Domain(string name, string version, uint256 chainId, address VaultHubContract)');
    bytes32 public constant VAULTHUB_DOMAIN_TYPE_HASH =
        0x6c055b4eb43bcfe637041a3adda3d9f2b05d93fc3a54fc8c978e7d0d95e35b66;

    // keccak256('savePrivateDataWithMinting(address addr, string memory data, string memory cryptoLabel, address labelHash,
    // address receiver, uint256 deadline)');
    bytes32 public constant VAULTHUB_MINT_SAVE_PERMIT_TYPE_HASH =
        0xe4f65c557ffdb3934e9fffd9af8d365eca51b20601a53082ce10b1e0ac04461f;

    // keccak256('savePrivateDataWithoutMinting(address addr, string memory data,
    // string memory cryptoLabel, address labelHash, uint256 deadline)');
    bytes32 public constant VAULTHUB_SAVE_PERMIT_TYPE_HASH =
        0x25f3fe064ef39028ecb8ad22c47a4f382a81ca1f21d802b4fdb8c3e213b9df72;

    //keccak256('queryPrivateDataByIndex(address addr, uint64 index, uint256 deadline)')
    bytes32 public constant VAULTHUB_INDEX_QUERY_PERMIT_TYPE_HASH =
        0xbcb00634c612072a661bb64fa073e7806d31f3790f1c827cd20f95542b5af679;

    //keccak256('queryPrivateDataByName(address addr, address labelHash, uint256 deadline)')
    bytes32 public constant VAULTHUB_NAME_QUERY_PERMIT_TYPE_HASH =
        0xab4ac209d4a97678c29d0f2f4ef3539a24e0ce6dbd2dd481c818134b61d28ecc;

    //keccak256('initPrivateVault(address addr, uint256 deadline)')
    bytes32 public constant VAULTHUB_INIT_VAULT_PERMIT_TYPE_HASH =
        0xef93604cd5c5e7d35e7ef7d38e1cac9e1cc450e49bc931effd1f65a5a993121d;

    //keccak256('vaultHasRegister(address addr, uint256 deadline)')
    bytes32 public constant VAULTHUB_VAULT_HAS_REGISTER_PERMIT_TYPE_HASH =
        0x5a14c87645febe5840f128409acb12772ff89f3398b05142d7e039c76e0844e8;

    //keccak256('hasMinted(address addr, uint256 deadline)')
    bytes32 public constant VAULTHUB_HAS_MINTED_PERMIT_TYPE_HASH =
        0xdbd66a895de1fdf2e44b84c83cf1e4f482f647eb80397d069bf7763a583ce1a5;

    //keccak256('totalSavedItems(address addr, uint256 deadline)')
    bytes32 public constant VAULTHUB_TOTAL_SAVED_ITEMS_PERMIT_TYPE_HASH =
        0xf65e93839555276acb1b1c33eb49dff5fa6a88c6991b9b84b680dc961b85f847;

    //keccak256('getLabelNameByIndex(address addr, uint256 deadline, uint64 index)')
    bytes32 public constant VAULTHUB_GET_LABEL_NAME_BY_INDEX_TYPE_HASH =
        0xbd5bc3ca2c7ea773b900edfe638ad04ce3697bf85885abdbe90a2f7c1266d9ee;

    //keccak256('labelExist(address addr, address labelHash, uint256 deadline)')
    bytes32 public constant VAULTHUB_LABEL_EXIST_TYPE_HASH =
        0xac1275bd89417f307b1ae27de4967e4910dfab4abd173eb3e6a3352c21ae42fe;

    //keccak256('queryPrivateVaultAddress(address addr, uint256 deadline)')
    bytes32 public constant VAULTHUB_QUERY_PRIVATE_VAULT_ADDRESS_PERMIT_TYPE_HASH =
        0x21b7e085fb49739c78b83ddb0a8a7e4b469211d08958f57d52ff68325943de04;
}
