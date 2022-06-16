// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.12;

import { PrivateVault } from "./PrivateVault.sol";
import { ITreasury } from "./interfaces/ITreasury.sol";
import "./interfaces/IVaultHub.sol";

contract VaultHub is IVaultHub {
    enum State {
        INIT_SUCCESS,
        SAVE_SUCCESS
    }
    event VaultInit(State indexed result, address indexed signer);
    event Save(State indexed result, address indexed signer);

    address public treasury = address(0);
    address public owner;
    string public constant DOMAIN_NAME = "vaulthub@seedlist.org";
    string public constant DOMAIN_VERSION = "1.0.0";
    bytes32 public DOMAIN_SEPARATOR;

    // keccak256('EIP712Domain(string name, string version, uint256 chainId, address VaultHubContract)');
    bytes32 public constant DOMAIN_TYPE_HASH = 0x6c055b4eb43bcfe637041a3adda3d9f2b05d93fc3a54fc8c978e7d0d95e35b66;

    // keccak256('savePrivateDataWithMinting(address addr, string memory data, string memory cryptoLabel, address labelHash,
    // address receiver, uint256 deadline)');
    bytes32 public constant MINT_SAVE_PERMIT_TYPE_HASH =
    0xe4f65c557ffdb3934e9fffd9af8d365eca51b20601a53082ce10b1e0ac04461f;

    // keccak256('savePrivateDataWithoutMinting(address addr, string memory data,
    // string memory cryptoLabel, address labelHash, uint256 deadline)');
    bytes32 public constant SAVE_PERMIT_TYPE_HASH = 0x25f3fe064ef39028ecb8ad22c47a4f382a81ca1f21d802b4fdb8c3e213b9df72;

    //keccak256('queryPrivateDataByIndex(address addr, uint64 index, uint256 deadline)')
    bytes32 public constant INDEX_QUERY_PERMIT_TYPE_HASH =
    0xbcb00634c612072a661bb64fa073e7806d31f3790f1c827cd20f95542b5af679;

    //keccak256('queryPrivateDataByName(address addr, address labelHash, uint256 deadline)')
    bytes32 public constant NAME_QUERY_PERMIT_TYPE_HASH =
    0xab4ac209d4a97678c29d0f2f4ef3539a24e0ce6dbd2dd481c818134b61d28ecc;

    //keccak256('initPrivateVault(address addr, uint256 deadline)')
    bytes32 public constant INIT_VAULT_PERMIT_TYPE_HASH =
    0xef93604cd5c5e7d35e7ef7d38e1cac9e1cc450e49bc931effd1f65a5a993121d;

    //keccak256('vaultHasRegister(address addr, uint256 deadline)')
    bytes32 public constant VAULT_HAS_REGISTER_PERMIT_TYPE_HASH =
    0x5a14c87645febe5840f128409acb12772ff89f3398b05142d7e039c76e0844e8;

    //keccak256('hasMinted(address addr, uint256 deadline)')
    bytes32 public constant HAS_MINTED_PERMIT_TYPE_HASH =
    0xdbd66a895de1fdf2e44b84c83cf1e4f482f647eb80397d069bf7763a583ce1a5;

    //keccak256('totalSavedItems(address addr, uint256 deadline)')
    bytes32 public constant TOTAL_SAVED_ITEMS_PERMIT_TYPE_HASH =
    0xf65e93839555276acb1b1c33eb49dff5fa6a88c6991b9b84b680dc961b85f847;

    //keccak256('getLabelNameByIndex(address addr, uint256 deadline, uint64 index)')
    bytes32 public constant GET_LABEL_NAME_BY_INDEX_TYPE_HASH =
    0xbd5bc3ca2c7ea773b900edfe638ad04ce3697bf85885abdbe90a2f7c1266d9ee;

    //keccak256('labelExist(address addr, address labelHash, uint256 deadline)')
    bytes32 public constant LABEL_EXIST_TYPE_HASH =
    0xac1275bd89417f307b1ae27de4967e4910dfab4abd173eb3e6a3352c21ae42fe;

    //keccak256('queryPrivateVaultAddress(address addr, uint256 deadline)')
    bytes32 public constant QUERY_PRIVATE_VAULT_ADDRESS_PERMIT_TYPE_HASH =
    0x21b7e085fb49739c78b83ddb0a8a7e4b469211d08958f57d52ff68325943de04;

    constructor() {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                DOMAIN_TYPE_HASH,
                keccak256(bytes(DOMAIN_NAME)),
                keccak256(bytes(DOMAIN_VERSION)),
                chainId,
                address(this)
            )
        );

        owner = msg.sender;
    }

    function setTreasuryAddress(address _treasury) external {
        require(msg.sender == owner, "seedlist: caller must be owner");
        require(treasury == address(0), "seedlist: treasury has set");
        treasury = _treasury;
    }

    modifier treasuryValid() {
        require(treasury != address(0), "seedlist: treasury ZERO address");
        _;
    }

    function calculateVaultAddress(bytes32 salt, bytes memory bytecode) internal view returns (address) {
        return
            address(
                uint160(
                    uint256(
                        keccak256(
                            abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(abi.encodePacked(bytecode)))
                        )
                    )
                )
            );
    }

    function verifyPermit(
        address signer,
        bytes32 params,
        uint8 v,
        bytes32 r,
        bytes32 s,
        string memory notification
    ) internal view {
        bytes32 paramsHash = keccak256(abi.encodePacked(params));
        bytes32 digest = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", paramsHash));

        //3. 判断ecrecover的结果地址是否和addr等值; 如果否，直接revert
        require(ecrecover(digest, v, r, s) == signer, notification);
    }

    function hasRegisterPermit(
        address addr,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view {
        require(addr != address(0), "seedlist: caller address ZERO");
        require(deadline >= block.timestamp, "seedlist: execute timeout");
        bytes32 params = keccak256(
            abi.encodePacked(addr, deadline, DOMAIN_SEPARATOR, VAULT_HAS_REGISTER_PERMIT_TYPE_HASH)
        );
        verifyPermit(addr, params, v, r, s, "seedlist:has register permit ERROR");
    }

    function vaultHasRegister(
        address addr,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (bool) {
        hasRegisterPermit(addr, deadline, v, r, s);
        (bool done, ) = _vaultHasRegister(addr);
        return done;
    }

    // 判断某个vault-name和password是否被注册
    function _vaultHasRegister(address addr) internal view returns (bool, address) {
        bytes32 salt = keccak256(abi.encodePacked(addr));
        bytes memory bytecode = abi.encodePacked(type(PrivateVault).creationCode, abi.encode(addr, this));

        address vault = calculateVaultAddress(salt, bytecode);

        if (vault.code.length > 0 && vault.codehash == keccak256(abi.encodePacked(type(PrivateVault).runtimeCode))) {
            return (true, vault);
        }

        return (false, address(0));
    }

    function initPermit(
        address addr,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view {
        require(addr != address(0), "seedlist: caller address ZERO");
        require(deadline >= block.timestamp, "seedlist: execute timeout");
        bytes32 params = keccak256(abi.encodePacked(addr, deadline, DOMAIN_SEPARATOR, INIT_VAULT_PERMIT_TYPE_HASH));
        verifyPermit(addr, params, v, r, s, "seedlist: init permit ERROR");
    }

    function initPrivateVault(
        address addr,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (bool) {
        initPermit(addr, deadline, v, r, s);
        //4. 计算private vault的地址, 记为vaultAddr
        bytes32 salt = keccak256(abi.encodePacked(addr));
        bytes memory bytecode = abi.encodePacked(type(PrivateVault).creationCode, abi.encode(addr, this));

        (bool done, ) = _vaultHasRegister(addr);
        require(done == false, "seedlist: vault has been registed");
        //6. create2 部署合约
        address vault;
        assembly {
            vault := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        if (vault == address(0)) {
            //合约create2失败
            revert("seedlist: create2 private vault ERROR");
        }

        emit VaultInit(State.INIT_SUCCESS, addr);

        return true;
    }

    function mintSavePermit(
        address addr,
        string memory data,
        string memory cryptoLabel,
        address labelHash,
        address receiver,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view {
        require(addr != address(0), "seedlist: caller address ZERO");
        require(deadline >= block.timestamp, "seedlist: execute timeout");
        bytes32 params = keccak256(
            abi.encodePacked(
                addr,
                bytes(data),
                bytes(cryptoLabel),
                labelHash,
                receiver,
                deadline,
                DOMAIN_SEPARATOR,
                MINT_SAVE_PERMIT_TYPE_HASH
            )
        );
        verifyPermit(addr, params, v, r, s, "seedlist: mint save permit ERROR");
    }

    function savePrivateDataWithMinting(
        address addr,
        string memory data,
        string memory cryptoLabel,
        address labelHash,
        address receiver,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external treasuryValid {
        mintSavePermit(addr, data, cryptoLabel, labelHash, receiver, deadline, v, r, s);

        (bool done, address vault) = _vaultHasRegister(addr);
        require(done == true, "seedlist: deploy vault firstly");
        require(PrivateVault(vault).minted() == false, "seedlist: mint token has done");

        ITreasury(treasury).mint(receiver);

        PrivateVault(vault).saveWithMinting(data, cryptoLabel, labelHash);
        emit Save(State.SAVE_SUCCESS, addr);
    }

    function saveWithoutMintPermit(
        address addr,
        string memory data,
        string memory cryptoLabel,
        address labelHash,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view {
        require(addr != address(0), "seedlist: caller address ZERO");
        require(deadline >= block.timestamp, "seedlist: execute timeout");
        bytes32 params = keccak256(
            abi.encodePacked(addr, bytes(data), bytes(cryptoLabel), labelHash, deadline, DOMAIN_SEPARATOR, SAVE_PERMIT_TYPE_HASH)
        );
        verifyPermit(addr, params, v, r, s, "seedlist: save permit ERROR");
    }

    function savePrivateDataWithoutMinting(
        address addr,
        string memory data,
        string memory cryptoLabel,
        address labelHash,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        saveWithoutMintPermit(addr, data, cryptoLabel, labelHash, deadline, v, r, s);

        (bool done, address vault) = _vaultHasRegister(addr);
        require(done == true, "seedlist: deploy vault firstly");

        PrivateVault(vault).saveWithoutMinting(data, cryptoLabel, labelHash);
        emit Save(State.SAVE_SUCCESS, addr);
    }

    function queryByIndexPermit(
        address addr,
        uint64 index,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view {
        require(addr != address(0), "seedlist: caller address ZERO");
        require(deadline >= block.timestamp, "seedlist: execute timeout");
        bytes32 params = keccak256(
            abi.encodePacked(addr, index, deadline, DOMAIN_SEPARATOR, INDEX_QUERY_PERMIT_TYPE_HASH)
        );
        verifyPermit(addr, params, v, r, s, "seedlist: index query permit ERROR");
    }

    function queryPrivateDataByIndex(
        address addr,
        uint64 index,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (string memory) {
        queryByIndexPermit(addr, index, deadline, v, r, s);

        (bool done, address vault) = _vaultHasRegister(addr);
        require(done == true, "seedlist: deploy vault firstly");

        return PrivateVault(vault).getPrivateDataByIndex(index);
    }

    function queryByNamePermit(
        address addr,
        address labelHash,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view {
        require(addr != address(0), "seedlist: caller address ZERO");
        require(deadline >= block.timestamp, "seedlist: execute timeout");
        bytes32 params = keccak256(
            abi.encodePacked(addr, labelHash, deadline, DOMAIN_SEPARATOR, NAME_QUERY_PERMIT_TYPE_HASH)
        );
        verifyPermit(addr, params, v, r, s, "seedlist: name query permit ERROR");
    }

    function queryPrivateDataByName(
        address addr,
        address labelHash,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (string memory) {
        queryByNamePermit(addr, labelHash, deadline, v, r, s);

        (bool done, address vault) = _vaultHasRegister(addr);
        require(done == true, "seedlist: deploy vault firstly");

        return PrivateVault(vault).getPrivateDataByName(labelHash);
    }

    function queryPrivateVaultAddressPermit(
        address addr,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view {
        require(addr != address(0), "seedlist: caller address ZERO");
        require(deadline >= block.timestamp, "seedlist: execute timeout");
        bytes32 params = keccak256(
            abi.encodePacked(addr, deadline, DOMAIN_SEPARATOR, QUERY_PRIVATE_VAULT_ADDRESS_PERMIT_TYPE_HASH)
        );
        verifyPermit(addr, params, v, r, s, "seedlist: query vault address permit ERROR");
    }

    function queryPrivateVaultAddress(
        address addr,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (address) {
        queryPrivateVaultAddressPermit(addr, deadline, v, r, s);
        (bool done, address vault) = _vaultHasRegister(addr);
        require(done == true, "seedlist: deploy vault firstly");
        return vault;
    }

    function hasMintedPermit(
        address addr,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view {
        require(addr != address(0), "seedlist: caller address ZERO");
        require(deadline >= block.timestamp, "seedlist: execute timeout");
        bytes32 params = keccak256(abi.encodePacked(addr, deadline, DOMAIN_SEPARATOR, HAS_MINTED_PERMIT_TYPE_HASH));
        verifyPermit(addr, params, v, r, s, "seedlist: has minted permit ERROR");
    }

    function hasMinted(
        address addr,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (bool) {
        hasMintedPermit(addr, deadline, v, r, s);
        (bool done, address vault) = _vaultHasRegister(addr);
        require(done == true, "seedlist: deploy vault firstly");
        return PrivateVault(vault).minted();
    }

    function totalSavedItemsPermit(
        address addr,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view {
        require(addr != address(0), "seedlist: caller address ZERO");
        require(deadline >= block.timestamp, "seedlist: execute timeout");
        bytes32 params = keccak256(
            abi.encodePacked(addr, deadline, DOMAIN_SEPARATOR, TOTAL_SAVED_ITEMS_PERMIT_TYPE_HASH)
        );
        verifyPermit(addr, params, v, r, s, "seedlist: get total saved permit ERROR");
    }

    function totalSavedItems(
        address addr,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (uint64) {
        totalSavedItemsPermit(addr, deadline, v, r, s);
        (bool done, address vault) = _vaultHasRegister(addr);
        require(done == true, "seedlist: deploy vault firstly");
        return PrivateVault(vault).total();
    }

    function getLabelNamePermit(
        address addr,
        uint256 deadline,
        uint64 index,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view {
        require(addr != address(0), "seedlist: caller address ZERO");
        require(deadline >= block.timestamp, "seedlist: execute timeout");
        bytes32 params = keccak256(abi.encodePacked(addr, deadline, index, DOMAIN_SEPARATOR, GET_LABEL_NAME_BY_INDEX_TYPE_HASH));
        verifyPermit(addr, params, v, r, s, "seedlist: get lable name permit ERROR");
    }

    function getLabelNameByIndex(
        address addr,
        uint256 deadline,
        uint64 index,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (string memory) {
        getLabelNamePermit(addr, deadline, index, v, r, s);
        (bool done, address vault) = _vaultHasRegister(addr);
        require(done == true, "seedlist: deploy vault firstly");
        return PrivateVault(vault).labelName(index);
    }

    function getLabelExistPermit(
        address addr,
        address labelHash,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view {
        require(addr != address(0), "seedlist: caller address ZERO");
        require(deadline >= block.timestamp, "seedlist: execute timeout");
        bytes32 params = keccak256(abi.encodePacked(addr, labelHash, deadline, DOMAIN_SEPARATOR, LABEL_EXIST_TYPE_HASH));
        verifyPermit(addr, params, v, r, s, "seedlist:lable exist permit ERROR");
    }

    function labelExist(
        address addr,
        address labelHash,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (bool) {
        getLabelExistPermit(addr, labelHash, deadline, v, r, s);
        (bool done, address vault) = _vaultHasRegister(addr);
        require(done == true, "seedlist: deploy vault firstly");
        return PrivateVault(vault).labelIsExist(labelHash);
    }
}
