//SPDX-License-Identifier: MIT
pragma solidity >= 0.6.6;

interface ISeed{
    function mint(address account, uint256 amount) external returns(bool);
    function maxSupply() external view returns(uint256);
}