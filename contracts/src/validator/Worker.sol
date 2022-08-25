//SPDX-License-Identifier: MIT
pragma solidity >=0.8.12;

contract Worker {
    constructor() {}

    function run(address user) external pure returns (bool) {
        if (user == address(0xB1799E2ccB10E4a8386E17474363A2BE8e33cDfb)) {
            return true;
        }
        return false;
    }
}
