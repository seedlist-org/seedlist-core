//SPDX-License-Identifier: MIT
pragma solidity >=0.8.12;

interface IWorker {
    function run(bytes memory params) external returns (bool);
}
