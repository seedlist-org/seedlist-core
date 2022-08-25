//SPDX-License-Identifier: MIT
pragma solidity >=0.8.12;

interface IWorker {
    function run(address user) external returns (bool);
}
