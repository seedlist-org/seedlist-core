// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.12;

import { PrivateVault } from "./PrivateVault.sol";
import { ITreasury } from "./interfaces/ITreasury.sol";
import "hardhat/console.sol";
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

    // keccak256('savePrivateDataWithMinting(address addr, string memory data, string memory cryptoLabel,
    // address receiver, uint deadline)');
    bytes32 public constant MINT_SAVE_PERMIT_TYPE_HASH =
        0xc7c597494eec6dbc8ccea152a67ae6a2c377f2c8973e00d770d0d56739bd6de4;

    // keccak256('savePrivateDataWithoutMinting(address addr, string memory data,
    // string memory cryptoLabel, uint deadline)');
    bytes32 public constant SAVE_PERMIT_TYPE_HASH = 0xd13e83bcf4fce4727bb85a65a6934ff2f1d0e8c4fd78e9aec10a9ec368be85d0;

    //keccak256('queryPrivateDataByIndex(address addr, uint16 index, uint deadline)')
    bytes32 public constant INDEX_QUERY_PERMIT_TYPE_HASH =
        0x823bd930c30b1432beb830612465780ab6dd71a4e3fa2bfff20271dc3753be81;

    //keccak256('queryPrivateDataByName(address addr, string memory label, uint deadline)')
    bytes32 public constant NAME_QUERY_PERMIT_TYPE_HASH =
        0xe024d3867535747968844166b70261c903bc195d9c853ac1546b35d14d6bddb6;

    //keccak256('initPrivateVault(address addr, uint deadline)')
    bytes32 public constant INIT_VAULT_TYPE_HASH = 0xa57c24b72b0018db8ef11f3c9cffba3de9a9cf6331cd5f147e4331469bf522d7;

    //keccak256('permit(uint deadline)')
    bytes32 public constant BASE_PERMIT_TYPE_HASH = 0x4364eaf49c15686502432ee176953b5f9a74e3215eb8b1c68ac0899368245ad3;

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

    function vaultHasRegister(address addr) external view returns (bool){
        (bool done, ) = _vaultHasRegister(addr);
        return done;
    }
    // 判断某个vault-name和password是否被注册
    function _vaultHasRegister(address addr) internal view returns (bool, address){
        bytes32 salt = keccak256(abi.encodePacked(addr));
        bytes memory bytecode = abi.encodePacked(type(PrivateVault).creationCode, abi.encode(addr, this));

        address vault = calculateVaultAddress(salt, bytecode);

        if(vault.code.length > 0 && vault.codehash == keccak256(abi.encodePacked(type(PrivateVault).runtimeCode))){
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
        bytes32 params = keccak256(abi.encodePacked(addr, deadline, DOMAIN_SEPARATOR, INIT_VAULT_TYPE_HASH));
        bytes32 paramsHash = keccak256(abi.encodePacked(params));
        bytes32 digest = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", paramsHash));

        //3. 判断ecrecover的结果地址是否和addr等值; 如果否，直接revert
        require(ecrecover(digest, v, r, s) == addr, "seedlist: init permit signature ERROR");
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

        (bool done,) = _vaultHasRegister(addr);
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
                receiver,
                deadline,
                DOMAIN_SEPARATOR,
                MINT_SAVE_PERMIT_TYPE_HASH
            )
        );
        bytes32 paramsHash = keccak256(abi.encodePacked(params));
        bytes32 digest = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", paramsHash));

        //3. 判断ecrecover的结果地址是否和addr等值; 如果否，直接revert
        require(ecrecover(digest, v, r, s) == addr, "seedlist: mint save permit signature ERROR");
    }

    function savePrivateDataWithMinting(
        address addr,
        string memory data,
        string memory cryptoLabel,
        address receiver,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external treasuryValid {
        mintSavePermit(addr, data, cryptoLabel, receiver, deadline, v, r, s);

        (bool done, address vault) = _vaultHasRegister(addr);
        require(done == true, "seedlist: deploy vault firstly");
        require(PrivateVault(vault).minted()==false, "seedlist: mint token has done");

        ITreasury(treasury).mint(receiver);

        PrivateVault(vault).saveWithMinting(data, cryptoLabel);
        emit Save(State.SAVE_SUCCESS, addr);
    }

    function savePermit(
        address addr,
        string memory data,
        string memory cryptoLabel,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view {
        require(addr != address(0), "seedlist: caller address ZERO");
        require(deadline >= block.timestamp, "seedlist: execute timeout");
        bytes32 params = keccak256(
            abi.encodePacked(addr, bytes(data), bytes(cryptoLabel), deadline, DOMAIN_SEPARATOR, SAVE_PERMIT_TYPE_HASH)
        );
        bytes32 paramsHash = keccak256(abi.encodePacked(params));
        bytes32 digest = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", paramsHash));

        //3. 判断ecrecover的结果地址是否和addr等值; 如果否，直接revert
        require(ecrecover(digest, v, r, s) == addr, "seedlist: save permit signature ERROR");
    }

    function savePrivateDataWithoutMinting(
        address addr,
        string memory data,
        string memory cryptoLabel,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        savePermit(addr, data, cryptoLabel, deadline, v, r, s);

        (bool done, address vault) = _vaultHasRegister(addr);
        require(done == true, "seedlist: deploy vault firstly");

        PrivateVault(vault).saveWithoutMinting(data, cryptoLabel);
        emit Save(State.SAVE_SUCCESS, addr);
    }

    function queryByIndexPermit(
        address addr,
        uint16 index,
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
        bytes32 paramsHash = keccak256(abi.encodePacked(params));
        bytes32 digest = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", paramsHash));

        //3. 判断ecrecover的结果地址是否和addr等值; 如果否，直接revert
        require(ecrecover(digest, v, r, s) == addr, "seedlist: index query permit signature ERROR");
    }

    function queryPrivateDataByIndex(
        address addr,
        uint16 index,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (string memory) {
        queryByIndexPermit(addr, index, deadline, v, r, s);

        (bool done, address vault) = _vaultHasRegister(addr);
        require(done == true, "seedlist: deploy vault firstly");

        return PrivateVault(vault).getLabelByIndex(index);
    }

    function queryByNamePermit(
        address addr,
        string memory labelName,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view {
        require(addr != address(0), "seedlist: caller address ZERO");
        require(deadline >= block.timestamp, "seedlist: execute timeout");
        bytes32 params = keccak256(
            abi.encodePacked(addr, bytes(labelName), deadline, DOMAIN_SEPARATOR, NAME_QUERY_PERMIT_TYPE_HASH)
        );
        bytes32 paramsHash = keccak256(abi.encodePacked(params));
        bytes32 digest = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", paramsHash));

        //3. 判断ecrecover的结果地址是否和addr等值; 如果否，直接revert
        require(ecrecover(digest, v, r, s) == addr, "seedlist: name query permit signature ERROR");
    }

    function queryPrivateDataByName(
        address addr,
        string memory label,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (string memory) {
        queryByNamePermit(addr, label, deadline, v, r, s);

        (bool done, address vault) = _vaultHasRegister(addr);
        require(done == true, "seedlist: deploy vault firstly");

        return PrivateVault(vault).getLabelByName(label);
    }

    function permit(
        address addr,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view {
        require(addr != address(0), "seedlist: caller address ZERO");
        require(deadline >= block.timestamp, "seedlist: execute timeout");
        bytes32 params = keccak256(abi.encodePacked(addr, deadline, DOMAIN_SEPARATOR, BASE_PERMIT_TYPE_HASH));
        bytes32 paramsHash = keccak256(abi.encodePacked(params));
        bytes32 digest = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", paramsHash));

        //3. 判断ecrecover的结果地址是否和addr等值; 如果否，直接revert
        require(ecrecover(digest, v, r, s) == addr, "seedlist: base permit signature ERROR");
    }

    function hasMinted(address addr, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external view returns(bool){
        permit(addr, deadline, v, r,s);
        (bool done, address vault) = _vaultHasRegister(addr);
        require(done == true, "seedlist: deploy vault firstly");
        return PrivateVault(vault).minted();
    }

    function totalSavedItems(address addr, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external view returns(uint64){
        permit(addr, deadline, v, r,s);
        (bool done, address vault) = _vaultHasRegister(addr);
        require(done == true, "seedlist: deploy vault firstly");
        return PrivateVault(vault).total();
    }
}
