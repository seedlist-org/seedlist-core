//SPDX-License-Identifier: MIT
pragma solidity >=0.8.12;
import "../../interfaces/validator/IValidator.sol";
import "../../interfaces/validator/IWorker.sol";
import "hardhat/console.sol";

contract PrivateValidator is IValidator {
    address public worker = address(0);
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) external {
        require(msg.sender == owner, "Validator:auth invalid");
        require(newOwner != address(0), "Validator:ZERO address");
        owner = newOwner;
    }

    function updateWorker(address newWorker) external {
        require(msg.sender == owner, "Validator: auth invalid");
        require(newWorker != address(0), "Validator:ZERO address");
        worker = newWorker;
    }

    function isValid(bytes memory params) external returns (bool) {
        if (worker == address(0)) {
            return true;
        }

        //(address router, uint24 fee) = abi.decode(params, (address, uint24));
        return IWorker(worker).run(params);
    }
}
