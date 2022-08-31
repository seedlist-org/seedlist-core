//SPDX-License-Identifier: MIT
pragma solidity >=0.8.12;

interface ITreasury {
    function mint(address receiver) external returns (uint256);
}
