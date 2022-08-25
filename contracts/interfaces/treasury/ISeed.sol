//SPDX-License-Identifier: MIT
pragma solidity >=0.8.12;

interface ISeed {
    function mint(address account, uint256 amount) external returns (bool);
}
