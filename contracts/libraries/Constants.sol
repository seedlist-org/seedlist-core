// SPDX-License-Identifier: MIT
pragma solidity >=0.8.12;

library VaultHubTypeHashs {
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

library PrivateVaultTypeHashs {
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

    //keccak256('saveWithoutMintingDirectly(string memory data, string memory cryptoLabel, address labelHash, uint256 deadline, bytes memory params)')
    bytes32 public constant PRIVATE_SAVE_WITHOUT_MINTING_PERMIT_TYPE_HASH =
        0x0146fc630af018bd01051793691b73d73b34e7977f68c1f081ed623cd3c2ab44;

    //keccak256('updateValidator(address _privateValidator, uint256 deadline)')
    bytes32 public constant PRIVATE_UPDATE_VALIDATOR_PERMIT_TYPE_HASH =
        0x79c473821b1882439e653292df5add05615ab1a78b695620f6cf37ab0fb6dbbc;
}

library VaultHubCallee {
    //vault hub used;  bytes4(keccak256(bytes(signature)))
    bytes4 public constant HAS_REGISTER_PERMIT = 0xf2ae01de;
    bytes4 public constant INIT_PERMIT = 0x560ee72b;
    bytes4 public constant GET_LABEL_EXIST_PERMIT = 0x15960843;
    bytes4 public constant GET_LABEL_NAME_PERMIT = 0x94f82d81;
    bytes4 public constant TOTAL_SAVED_ITEMS_PERMIT = 0x15b2755f;
    bytes4 public constant HAS_MINTED_PERMIT = 0x1a49dda4;
    bytes4 public constant QUERY_PRIVATE_VAULT_ADDRESS_PERMIT = 0x01c190bd;
    bytes4 public constant QUERY_BY_NAME_PERMIT = 0x79861a05;
    bytes4 public constant QUERY_BY_INDEX_PERMIT = 0xd5d76538;
    bytes4 public constant SAVE_WITHOUT_MINT_PERMIT = 0xdd181b56;
    bytes4 public constant MINT_SAVE_PERMIT = 0x95781f1f;
}

library PrivateVaultCallee {
    // private vault used
    bytes4 public constant LABEL_IS_EXIST_PERMIT = 0x727faffc;
    bytes4 public constant LABEL_NAME_PERMIT = 0x1046f7f9;
    bytes4 public constant GET_PRIVATE_DATA_BY_NAME_PERMIT = 0x3eeaa953;
    bytes4 public constant GET_PRIVATE_DATA_BY_INDEX_PERMIT = 0x01f8e063;
    bytes4 public constant SAVE_WITHOUT_MINTING_PERMIT = 0x3b99fa80;
    bytes4 public constant UPDATE_VALIDATOR_PERMIT = 0x22cf42d8;
}
