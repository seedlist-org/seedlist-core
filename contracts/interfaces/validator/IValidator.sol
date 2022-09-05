//SPDX-License-Identifier: MIT
pragma solidity >=0.8.12;

interface IValidator {
    function isValid(bytes memory params) external returns (bool);
}
