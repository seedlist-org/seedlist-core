//SPDX-License-Identifier: MIT

pragma solidity >=0.8.12;

interface IPrivateVaultHub {
    /*
    function saveWithMintingDirectly(
        string memory data,
        string memory cryptoLabel,
        address labelHash,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bytes memory params
    ) external;
*/

    function saveWithoutMintingDirectly(
        string memory data,
        string memory cryptoLabel,
        address labelHash,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bytes memory params
    ) external;

    function getPrivateDataByIndexDirectly(
        uint64 index,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (string memory);

    function getPrivateDataByNameDirectly(
        address name,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (string memory);

    function labelNameDirectly(
        uint64 index,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (string memory);

    function labelIsExistDirectly(
        address labelHash,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (bool);
}
