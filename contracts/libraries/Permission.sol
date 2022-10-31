// SPDX-License-Identifier: MIT
pragma solidity >=0.8.12;
import "./Verifier.sol";
import { VaultHubTypeHashs, PrivateVaultTypeHashs } from "./Constants.sol";

library VaultHubPermission {
    function hasRegisterPermit(
        address addr,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bytes32 DOMAIN_SEPARATOR
    ) external view {
        require(addr != address(0));
        require(deadline >= block.timestamp, "vHub:execute timeout");
        bytes32 params = keccak256(
            abi.encodePacked(
                addr,
                deadline,
                DOMAIN_SEPARATOR,
                VaultHubTypeHashs.VAULTHUB_VAULT_HAS_REGISTER_PERMIT_TYPE_HASH
            )
        );
        Verifier.verifyPermit(addr, params, v, r, s, "vHub:register permit");
    }

    function initPermit(
        address addr,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bytes32 DOMAIN_SEPARATOR
    ) external view {
        require(addr != address(0));
        require(deadline >= block.timestamp, "vHub:execute timeout");
        bytes32 params = keccak256(
            abi.encodePacked(addr, deadline, DOMAIN_SEPARATOR, VaultHubTypeHashs.VAULTHUB_INIT_VAULT_PERMIT_TYPE_HASH)
        );
        Verifier.verifyPermit(addr, params, v, r, s, "vHub:init permit");
    }

    function mintSavePermit(
        address addr,
        string calldata data,
        string calldata cryptoLabel,
        address labelHash,
        address receiver,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bytes32 DOMAIN_SEPARATOR
    ) external view {
        require(addr != address(0));
        require(deadline >= block.timestamp, "vHub:execute timeout");
        bytes32 params = keccak256(
            abi.encodePacked(
                addr,
                bytes(data),
                bytes(cryptoLabel),
                labelHash,
                receiver,
                deadline,
                DOMAIN_SEPARATOR,
                VaultHubTypeHashs.VAULTHUB_MINT_SAVE_PERMIT_TYPE_HASH
            )
        );
        Verifier.verifyPermit(addr, params, v, r, s, "vHub:mint save");
    }

    function saveWithoutMintPermit(
        address addr,
        string calldata data,
        string calldata cryptoLabel,
        address labelHash,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bytes32 DOMAIN_SEPARATOR
    ) external view {
        require(addr != address(0));
        require(deadline >= block.timestamp, "vHub:execute timeout");
        bytes32 params = keccak256(
            abi.encodePacked(
                addr,
                bytes(data),
                bytes(cryptoLabel),
                labelHash,
                deadline,
                DOMAIN_SEPARATOR,
                VaultHubTypeHashs.VAULTHUB_SAVE_PERMIT_TYPE_HASH
            )
        );
        Verifier.verifyPermit(addr, params, v, r, s, "vHub:save permit");
    }

    function queryByIndexPermit(
        address addr,
        uint64 index,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bytes32 DOMAIN_SEPARATOR
    ) external view {
        require(addr != address(0));
        require(deadline >= block.timestamp, "vHub:execute timeout");
        bytes32 params = keccak256(
            abi.encodePacked(
                addr,
                index,
                deadline,
                DOMAIN_SEPARATOR,
                VaultHubTypeHashs.VAULTHUB_INDEX_QUERY_PERMIT_TYPE_HASH
            )
        );
        Verifier.verifyPermit(addr, params, v, r, s, "vHub:index query");
    }

    function queryByNamePermit(
        address addr,
        address labelHash,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bytes32 DOMAIN_SEPARATOR
    ) external view {
        require(addr != address(0));
        require(deadline >= block.timestamp, "vHub:execute timeout");
        bytes32 params = keccak256(
            abi.encodePacked(
                addr,
                labelHash,
                deadline,
                DOMAIN_SEPARATOR,
                VaultHubTypeHashs.VAULTHUB_NAME_QUERY_PERMIT_TYPE_HASH
            )
        );
        Verifier.verifyPermit(addr, params, v, r, s, "vHub:name query");
    }

    function queryPrivateVaultAddressPermit(
        address addr,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bytes32 DOMAIN_SEPARATOR
    ) external view {
        require(addr != address(0));
        require(deadline >= block.timestamp, "vHub:execute timeout");
        bytes32 params = keccak256(
            abi.encodePacked(
                addr,
                deadline,
                DOMAIN_SEPARATOR,
                VaultHubTypeHashs.VAULTHUB_QUERY_PRIVATE_VAULT_ADDRESS_PERMIT_TYPE_HASH
            )
        );
        Verifier.verifyPermit(addr, params, v, r, s, "vHub:query address");
    }

    function hasMintedPermit(
        address addr,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bytes32 DOMAIN_SEPARATOR
    ) external view {
        require(addr != address(0));
        require(deadline >= block.timestamp, "vHub:execute timeout");
        bytes32 params = keccak256(
            abi.encodePacked(addr, deadline, DOMAIN_SEPARATOR, VaultHubTypeHashs.VAULTHUB_HAS_MINTED_PERMIT_TYPE_HASH)
        );
        Verifier.verifyPermit(addr, params, v, r, s, "vHub:has minted");
    }

    function totalSavedItemsPermit(
        address addr,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bytes32 DOMAIN_SEPARATOR
    ) external view {
        require(addr != address(0));
        require(deadline >= block.timestamp, "vHub:execute timeout");
        bytes32 params = keccak256(
            abi.encodePacked(
                addr,
                deadline,
                DOMAIN_SEPARATOR,
                VaultHubTypeHashs.VAULTHUB_TOTAL_SAVED_ITEMS_PERMIT_TYPE_HASH
            )
        );
        Verifier.verifyPermit(addr, params, v, r, s, "vHub:total saved");
    }

    function getLabelNamePermit(
        address addr,
        uint256 deadline,
        uint64 index,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bytes32 DOMAIN_SEPARATOR
    ) external view {
        require(addr != address(0));
        require(deadline >= block.timestamp, "vHub:execute timeout");
        bytes32 params = keccak256(
            abi.encodePacked(
                addr,
                deadline,
                index,
                DOMAIN_SEPARATOR,
                VaultHubTypeHashs.VAULTHUB_GET_LABEL_NAME_BY_INDEX_TYPE_HASH
            )
        );
        Verifier.verifyPermit(addr, params, v, r, s, "vHub:lable name permit");
    }

    function getLabelExistPermit(
        address addr,
        address labelHash,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bytes32 DOMAIN_SEPARATOR
    ) external view {
        require(addr != address(0));
        require(deadline >= block.timestamp, "vHub:execute timeout");
        bytes32 params = keccak256(
            abi.encodePacked(
                addr,
                labelHash,
                deadline,
                DOMAIN_SEPARATOR,
                VaultHubTypeHashs.VAULTHUB_LABEL_EXIST_TYPE_HASH
            )
        );
        Verifier.verifyPermit(addr, params, v, r, s, "vHub:exist permit");
    }
}