//SPDX-License-Identifier: MIT
pragma solidity >=0.8.12;
import "../../interfaces/validator/IWorker.sol";

contract Worker is IWorker {
    mapping(address => bool) passor;

    constructor() {
        passor[address(0xB1799E2ccB10E4a8386E17474363A2BE8e33cDfb)] = true;
        passor[address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266)] = true;
    }

    function run(bytes memory params) external view returns (bool) {
        abi.decode(params, (address, uint24)); //demo about decoding params
        if (passor[tx.origin] == true) {
            return true;
        }
        return false;
    }
}
