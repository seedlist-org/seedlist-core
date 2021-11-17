//SPDX-License-Identifier: MIT
pragma solidity >= 0.8.2;

interface IRegistry {
    function registryEncryptMachine(string calldata version, address machine) external returns(bool);
    function versionHasRegister(string calldata version) external returns(bool);
    function machineHasRegister(address machine) external returns(bool);
}
