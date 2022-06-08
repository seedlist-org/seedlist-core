//SPDX-License-Identifier: MIT

pragma solidity >=0.8.12;

interface IPrivateVaultHub {
    function saveWithMinting(string memory data, string memory cryptoLabel) external;

    function saveWithoutMinting(string memory data, string memory cryptoLabel) external;

    function getLabelByIndex(uint64 index) external view returns (string memory);

    function getLabelByName(string memory name) external view returns (string memory);

    function labelName(uint64 index) external view returns (string memory);
}
