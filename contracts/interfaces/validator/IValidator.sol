//SPDX-License-Identifier: MIT
pragma solidity >= 0.8.12;

interface IValidator {
    function isValid(address sender) external returns (bool);
}
