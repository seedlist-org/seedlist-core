//SPDX-License-Identifier: MIT
pragma solidity >= 0.6.6;

interface ITreasury {
    function Mint(address verifier, address receiver) external returns(bool);
}
