// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.12;

import { PrivateVault } from "./PrivateVault.sol";
import { ITreasury } from "../../interfaces/treasury/ITreasury.sol";
import "../../interfaces/vaults/IVaultHub.sol";
import { Constant, CalleeName } from "../../libraries/Constant.sol";

contract VaultHub is IVaultHub {
    enum State {
        INIT_SUCCESS,
        SAVE_SUCCESS
    }
    event VaultInit(State indexed result, address indexed signer);
    event Save(State indexed result, address indexed signer);

    address public treasury = address(0);
    address public owner;
    uint256 public fee = 150000000000000;
    bytes32 public immutable DOMAIN_SEPARATOR;
    address private validator;

    address public immutable vaultHubPermissionLib;
    address public immutable privateVaultPermissionLib;

    constructor(
        address _validator,
        address _vaultHubPermissionLib,
        address _privateVaultPermissionLib
    ) {
        require(_validator != address(0));

        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                Constant.VAULTHUB_DOMAIN_TYPE_HASH,
                keccak256(bytes(Constant.VAULTHUB_DOMAIN_NAME)),
                keccak256(bytes(Constant.VAULTHUB_DOMAIN_VERSION)),
                chainId,
                address(this)
            )
        );

        owner = msg.sender;
        validator = _validator;
        vaultHubPermissionLib = _vaultHubPermissionLib;
        privateVaultPermissionLib = _privateVaultPermissionLib;
    }

    function setFee(uint256 _fee) external {
        require(msg.sender == owner, "vHub:auth invalid");
        fee = _fee;
    }

    function transferOwnership(address newOwner) external {
        require(msg.sender == owner, "vHub:auth invalid");
        require(newOwner != address(0), "vHub:ZERO ADDRESS");
        owner = newOwner;
    }

    function setTreasuryAddress(address _treasury) external {
        require(msg.sender == owner, "vHub:caller must be owner");
        require(treasury == address(0), "vHub:treasury has set");
        treasury = _treasury;
    }

    modifier treasuryValid() {
        require(treasury != address(0), "vHub:ZERO address");
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

    function vaultHasRegister(
        address addr,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (bool) {
        (bool res, ) = vaultHubPermissionLib.staticcall(
            abi.encodeWithSelector(CalleeName.HAS_REGISTER_PERMIT, addr, deadline, v, r, s, DOMAIN_SEPARATOR)
        );
        require(res == true, "vHub:delegate ERROR");
        (bool done, ) = _vaultHasRegister(addr);
        return done;
    }

    // Determine whether a vault-name and password are registered
    function _vaultHasRegister(address addr) internal view returns (bool, address) {
        bytes32 salt = keccak256(abi.encodePacked(addr));
        bytes memory bytecode = abi.encodePacked(type(PrivateVault).creationCode, abi.encode(addr, this, validator, privateVaultPermissionLib));

        //Calculate the address of the private vault, record it as vaultAddr
        address vault = calculateVaultAddress(salt, bytecode);

        if (vault.code.length > 0 && vault.codehash == keccak256(abi.encodePacked(type(PrivateVault).runtimeCode))) {
            return (true, vault);
        }

        return (false, address(0));
    }

    function initPrivateVault(
        address addr,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (bool) {
        (bool res, ) = vaultHubPermissionLib.staticcall(
            abi.encodeWithSelector(CalleeName.INIT_PERMIT, addr, deadline, v, r, s, DOMAIN_SEPARATOR)
        );
        require(res == true, "vHub:delegate ERROR");

        bytes32 salt = keccak256(abi.encodePacked(addr));
        bytes memory bytecode = abi.encodePacked(type(PrivateVault).creationCode, abi.encode(addr, this, validator, privateVaultPermissionLib));

        (bool done, ) = _vaultHasRegister(addr);
        require(done == false, "vHub:vault existed");
        //create2: deploy contract
        address vault;
        assembly {
            vault := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        if (vault == address(0)) {
            revert("vHub:create2 private vault ERROR");
        }

        emit VaultInit(State.INIT_SUCCESS, addr);

        return true;
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
    ) external payable treasuryValid {
        require(msg.value >= fee, "vHub:more than 0.00015");
        (bool res, ) = vaultHubPermissionLib.staticcall(
            abi.encodeWithSelector(
                CalleeName.MINT_SAVE_PERMIT,
                addr,
                data,
                cryptoLabel,
                labelHash,
                receiver,
                deadline,
                v,
                r,
                s,
                DOMAIN_SEPARATOR
            )
        );
        require(res == true, "vHub:delegate ERROR");

        (bool done, address vault) = _vaultHasRegister(addr);
        require(done == true, "vHub:deploy firstly");
        require(PrivateVault(vault).minted() == false, "vHub:mint token has done");

        ITreasury(treasury).mint(receiver);

        PrivateVault(vault).saveWithMinting(data, cryptoLabel, labelHash);
        emit Save(State.SAVE_SUCCESS, addr);
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
    ) external payable {
        require(msg.value >= fee, "vHub:more than 0.00015");
        (bool res, ) = vaultHubPermissionLib.staticcall(
            abi.encodeWithSelector(
                CalleeName.SAVE_WITHOUT_MINT_PERMIT,
                addr,
                data,
                cryptoLabel,
                labelHash,
                deadline,
                v,
                r,
                s,
                DOMAIN_SEPARATOR
            )
        );
        require(res == true, "vHub:delegate ERROR");

        (bool done, address vault) = _vaultHasRegister(addr);
        require(done == true, "vHub:deploy firstly");

        PrivateVault(vault).saveWithoutMinting(data, cryptoLabel, labelHash);
        emit Save(State.SAVE_SUCCESS, addr);
    }

    function queryPrivateDataByIndex(
        address addr,
        uint64 index,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (string memory) {
        (bool res, ) = vaultHubPermissionLib.staticcall(
            abi.encodeWithSelector(CalleeName.QUERY_BY_INDEX_PERMIT,addr, index, deadline, v, r, s, DOMAIN_SEPARATOR)
        );
        require(res == true, "vHub:delegate ERROR");

        (bool done, address vault) = _vaultHasRegister(addr);
        require(done == true, "vHub:deploy firstly");

        return PrivateVault(vault).getPrivateDataByIndex(index);
    }

    function queryPrivateDataByName(
        address addr,
        address labelHash,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (string memory) {
        (bool res, ) = vaultHubPermissionLib.staticcall(
            abi.encodeWithSelector(
                CalleeName.QUERY_BY_NAME_PERMIT,
                addr,
                labelHash,
                deadline,
                v,
                r,
                s,
                DOMAIN_SEPARATOR
            )
        );
        require(res == true, "vHub:delegate ERROR");

        (bool done, address vault) = _vaultHasRegister(addr);
        require(done == true, "vHub:deploy firstly");

        return PrivateVault(vault).getPrivateDataByName(labelHash);
    }

    function queryPrivateVaultAddress(
        address addr,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (address) {
        (bool res, ) = vaultHubPermissionLib.staticcall(
            abi.encodeWithSelector(
                CalleeName.QUERY_PRIVATE_VAULT_ADDRESS_PERMIT,
                addr,
                deadline,
                v,
                r,
                s,
                DOMAIN_SEPARATOR
            )
        );
        require(res == true, "vHub:delegate ERROR");

        (bool done, address vault) = _vaultHasRegister(addr);
        require(done == true, "vHub:deploy firstly");
        return vault;
    }

    function hasMinted(
        address addr,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (bool) {
        (bool res, ) = vaultHubPermissionLib.staticcall(
            abi.encodeWithSelector(CalleeName.HAS_MINTED_PERMIT, addr, deadline, v, r, s, DOMAIN_SEPARATOR)
        );
        require(res == true, "vHub:delegate ERROR");
        (bool done, address vault) = _vaultHasRegister(addr);
        require(done == true, "vHub:deploy vault firstly");
        return PrivateVault(vault).minted();
    }

    function totalSavedItems(
        address addr,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (uint64) {
        (bool res, ) = vaultHubPermissionLib.staticcall(
            abi.encodeWithSelector(CalleeName.TOTAL_SAVED_ITEMS_PERMIT, addr, deadline, v, r, s, DOMAIN_SEPARATOR)
        );
        require(res == true, "vHub:delegate ERROR");

        (bool done, address vault) = _vaultHasRegister(addr);
        require(done == true, "vHub:deploy vault firstly");
        return PrivateVault(vault).total();
    }

    function getLabelNameByIndex(
        address addr,
        uint256 deadline,
        uint64 index,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (string memory) {
        (bool res, ) = vaultHubPermissionLib.staticcall(
            abi.encodeWithSelector(CalleeName.GET_LABEL_NAME_PERMIT, addr, deadline, index, v, r, s, DOMAIN_SEPARATOR)
        );
        require(res == true, "vHub:delegate ERROR");
        (bool done, address vault) = _vaultHasRegister(addr);
        require(done == true, "vHub:deploy vault firstly");
        return PrivateVault(vault).labelName(index);
    }

    function labelExist(
        address addr,
        address labelHash,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (bool) {
        (bool res, ) = vaultHubPermissionLib.staticcall(
            abi.encodeWithSelector(
                CalleeName.GET_LABEL_EXIST_PERMIT,
                addr,
                labelHash,
                deadline,
                v,
                r,
                s,
                DOMAIN_SEPARATOR
            )
        );
        require(res == true, "vHub:delegate ERROR");
        (bool done, address vault) = _vaultHasRegister(addr);
        require(done == true, "vHub:deploy vault firstly");
        return PrivateVault(vault).labelIsExist(labelHash);
    }

    function withdrawETH(address payable receiver, uint256 amount) external returns (bool) {
        require(msg.sender == owner, "vHub:auth invalid");
        receiver.transfer(amount);
        return true;
    }
}
