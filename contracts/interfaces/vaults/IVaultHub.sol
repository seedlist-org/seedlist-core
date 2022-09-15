//SPDX-License-Identifier: MIT

pragma solidity >=0.8.12;

interface IVaultHub {
    function vaultHasRegister(
        address addr,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (bool);

    function initPrivateVault(
        address addr,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (bool);

    function savePrivateDataWithMinting(
        address addr,
        string calldata data,
        string calldata cryptoLabel,
        address labelHash,
        address receiver,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable;

    function savePrivateDataWithoutMinting(
        address addr,
        string calldata data,
        string calldata cryptoLabel,
        address labelHash,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable;

    function queryPrivateDataByIndex(
        address addr,
        uint64 index,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (string memory);

    function queryPrivateDataByName(
        address addr,
        address labelHash,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (string memory);

    function hasMinted(
        address addr,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (bool);

    function totalSavedItems(
        address addr,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (uint64);

    function getLabelNameByIndex(
        address addr,
        uint256 deadline,
        uint64 index,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (string memory);

    function queryPrivateVaultAddress(
        address addr,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (address);

    function labelExist(
        address addr,
        address labelHash,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (bool);
}
