//SPDX-License-Identifier: MIT
pragma solidity >=0.8.12;

contract Worker {
    mapping(address=>bool) passor;
    constructor() {
        passor[address(0xB1799E2ccB10E4a8386E17474363A2BE8e33cDfb)] = true;
        passor[address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266)] = true;
    }
    function run(address user) external view returns (bool) {
        if (passor[user]==true) {
            return true;
        }
        return false;
    }
}
