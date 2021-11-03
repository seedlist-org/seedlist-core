//SPDX-License-Identifier: MIT
pragma solidity >= 0.6.6;

interface ITreasury {
    event MintMessage(address receiver, uint256 amount, string msg);
    function Mint(address verifier, address receiver) external returns(bool);
}
interface IVerifier {
    function Mint(address receiver) external returns(bool);
}
