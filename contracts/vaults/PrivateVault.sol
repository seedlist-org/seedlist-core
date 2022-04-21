// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.12;

import "hardhat/console.sol";

contract PrivateVault {
    address private signer;
    address private caller;

    // 每个vault只能参与一次mint seed 行为
    bool public minted;

    //用来判断某个label是否已经存在
    mapping(address => bool) private labelExist;

    // 用来标示某个label被存储的位置
    mapping(uint64 => string) private labels;

    // 用来存储真实的加密数据
    mapping(address => string) private store;

    uint64 public total;

    modifier auth() {
        require(msg.sender == caller || msg.sender == signer, "Caller is invalid");
        _;
    }

    constructor(address _signer, address _caller) {
        signer = _signer;
        caller = _caller;
        total = 0;
        minted = false;
    }

    //cryptoLabel 是加密后的label值
    function saveWithMinting(string memory data, string memory cryptoLabel) external auth {
        require(minted == false, "seedlist: mint has done");
        address labelAddr = address(uint160(uint256(keccak256(abi.encodePacked(cryptoLabel)))));
        //label没有被使用过
        require(labelExist[labelAddr] == false, "Label has exist");

        store[labelAddr] = data;
        labels[total] = cryptoLabel;
        total++;
        labelExist[labelAddr] = true;

        minted = true;
    }

    function saveWithoutMinting(string memory data, string memory cryptoLabel) external auth {
        address labelAddr = address(uint160(uint256(keccak256(abi.encodePacked(cryptoLabel)))));
        //label没有被使用过
        require(labelExist[labelAddr] == false, "Label has exist");
        store[labelAddr] = data;
        labels[total] = cryptoLabel;
        total++;
        labelExist[labelAddr] = true;
    }

    function getLabelByIndex(uint16 index) external view auth returns (string memory) {
        require(total > index, "Labels keys overflow");
        address _addr = address(uint160(uint256(keccak256(abi.encodePacked(labels[index])))));
        return store[_addr];
    }

    function getLabelByName(string memory name) external view auth returns (string memory) {
        address _addr = address(uint160(uint256(keccak256(abi.encodePacked(name)))));
        require(labelExist[_addr] == true, "Label no exist");

        return store[_addr];
    }
}
