// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.12;

import "hardhat/console.sol";
import "./interfaces/IPrivateVault.sol";

contract PrivateVault is IPrivateVaultHub {
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

    string public constant DOMAIN_NAME = "privateVault@seedlist.org";
    string public constant DOMAIN_VERSION = "1.0.0";
    bytes32 public DOMAIN_SEPARATOR;

    // keccak256('EIP712Domain(string name, string version, uint256 chainId, address PrivateVaultContract)');
    bytes32 public constant DOMAIN_TYPE_HASH = 0xdad980a10e49615eb7fc5d7774307c8f04d959ac46349850121d52b1e409fc1e;

    //keccak256('labelNameDirectly(uint64 index, uint256 deadline)')
    bytes32 public constant LABEL_NAME_PERMIT_TYPE_HASH =
        0xcbb2475c190d2e287f7de56c688846f7612f70b210a3856ad34c475cbad0dda7;

    //keccak256('getPrivateDataByNameDirectly(string memory name, uint256 deadline)')
    bytes32 public constant GET_PRIVATE_DATA_BY_NAME_PERMIT_TYPE_HASH =
        0x83a9c8c05ed0fb1e4d4baaef671e3f96099729926f732e6aaac34a751230c7b8;

    //keccak256('getPrivateDataByIndexDirectly(uint64 index, uint256 deadline)')
    bytes32 public constant GET_PRIVATE_DATA_BY_INDEX_PERMIT_TYPE_HASH =
        0x17558919af4007c4fb94572ba8e807922ff7db103814e127ad21ef481ca35d98;

    //keccak256('saveWithoutMintingDirectly(string memory data, string memory cryptoLabel, uint256 deadline)')
    bytes32 public constant SAVE_WITHOUT_MINTING_PERMIT_TYPE_HASH =
        0xdf412ff5be017ec35abe4df3f9a2b33c93ab92336a734ac392576c30bad057f5;

    //keccak256('saveWithMintingDirectly(string memory data, string memory cryptoLabel, uint256 deadline)')
    bytes32 public constant SAVE_WITH_MINTING_PERMIT_TYPE_HASH =
        0xd9066cfdcd2adeb7f91eaa0872abd8e0ce6c9e7c131f920e0b52e3b052a791c8;

    modifier auth() {
        require(msg.sender == caller, "Caller is invalid");
        _;
    }

    constructor(address _signer, address _caller) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                DOMAIN_TYPE_HASH,
                keccak256(bytes(DOMAIN_NAME)),
                keccak256(bytes(DOMAIN_VERSION)),
                chainId,
                address(this)
            )
        );

        signer = _signer;
        caller = _caller;
        total = 0;
        minted = false;
    }

    function verifyPermit(
        bytes32 params,
        uint8 v,
        bytes32 r,
        bytes32 s,
        string memory notification
    ) internal view {
        bytes32 paramsHash = keccak256(abi.encodePacked(params));
        bytes32 digest = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", paramsHash));

        //3. 判断ecrecover的结果地址是否和addr等值; 如果否，直接revert
        require(ecrecover(digest, v, r, s) == signer, notification);
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

    function saveWithMintingPermit(
        string memory data,
        string memory cryptoLabel,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view {
        require(deadline >= block.timestamp, "vault: execute timeout");
        bytes32 params = keccak256(
            abi.encodePacked(
                signer,
                bytes(data),
                bytes(cryptoLabel),
                deadline,
                DOMAIN_SEPARATOR,
                SAVE_WITH_MINTING_PERMIT_TYPE_HASH
            )
        );
        verifyPermit(params, v, r, s, "vault: save with minting permit ERROR");
    }

    function saveWithMintingDirectly(
        string memory data,
        string memory cryptoLabel,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(minted == false, "seedlist: mint has done");
        saveWithMintingPermit(data, cryptoLabel, deadline, v, r, s);
        address labelAddr = address(uint160(uint256(keccak256(abi.encodePacked(cryptoLabel)))));
        //label没有被使用过
        require(labelExist[labelAddr] == false, "Label has exist");

        store[labelAddr] = data;
        labels[total] = cryptoLabel;
        total++;
        labelExist[labelAddr] = true;

        minted = true;
    }

    ////////////////////////////
    function saveWithoutMinting(string memory data, string memory cryptoLabel) external auth {
        address labelAddr = address(uint160(uint256(keccak256(abi.encodePacked(cryptoLabel)))));
        //label没有被使用过
        require(labelExist[labelAddr] == false, "Label has exist");
        store[labelAddr] = data;
        labels[total] = cryptoLabel;
        total++;
        labelExist[labelAddr] = true;
    }

    function saveWithoutMintingPermit(
        string memory data,
        string memory cryptoLabel,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view {
        require(deadline >= block.timestamp, "vault: execute timeout");
        bytes32 params = keccak256(
            abi.encodePacked(
                signer,
                bytes(data),
                bytes(cryptoLabel),
                deadline,
                DOMAIN_SEPARATOR,
                SAVE_WITHOUT_MINTING_PERMIT_TYPE_HASH
            )
        );
        verifyPermit(params, v, r, s, "vault: save without minting permit ERROR");
    }

    function saveWithoutMintingDirectly(
        string memory data,
        string memory cryptoLabel,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        saveWithoutMintingPermit(data, cryptoLabel, deadline, v, r, s);
        address labelAddr = address(uint160(uint256(keccak256(abi.encodePacked(cryptoLabel)))));
        //label没有被使用过
        require(labelExist[labelAddr] == false, "Label has exist");
        store[labelAddr] = data;
        labels[total] = cryptoLabel;
        total++;
        labelExist[labelAddr] = true;
    }

    ////////////////////////////
    function getPrivateDataByIndex(uint64 index) external view auth returns (string memory) {
        require(total > index, "Labels keys overflow");
        address _addr = address(uint160(uint256(keccak256(abi.encodePacked(labels[index])))));
        return store[_addr];
    }

    function getPrivateDataByIndexPermit(
        uint64 index,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view {
        require(deadline >= block.timestamp, "vault: execute timeout");
        bytes32 params = keccak256(
            abi.encodePacked(signer, index, deadline, DOMAIN_SEPARATOR, GET_PRIVATE_DATA_BY_INDEX_PERMIT_TYPE_HASH)
        );
        verifyPermit(params, v, r, s, "vault: index label permit ERROR");
    }

    function getPrivateDataByIndexDirectly(
        uint64 index,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (string memory) {
        require(total > index, "Data keys overflow");
        getPrivateDataByIndexPermit(index, deadline, v, r, s);
        address _addr = address(uint160(uint256(keccak256(abi.encodePacked(labels[index])))));
        return store[_addr];
    }

    ////////////////////////////
    function getPrivateDataByName(string memory name) external view auth returns (string memory) {
        address _addr = address(uint160(uint256(keccak256(abi.encodePacked(name)))));
        require(labelExist[_addr] == true, "Label no exist");

        return store[_addr];
    }

    function getPrivateDataByNamePermit(
        string memory name,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view {
        require(deadline >= block.timestamp, "vault: execute timeout");
        bytes32 params = keccak256(
            abi.encodePacked(signer, bytes(name), deadline, DOMAIN_SEPARATOR, GET_PRIVATE_DATA_BY_NAME_PERMIT_TYPE_HASH)
        );
        verifyPermit(params, v, r, s, "vault: get data by name permit ERROR");
    }

    function getPrivateDataByNameDirectly(
        string memory name,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (string memory) {
        getPrivateDataByNamePermit(name, deadline, v, r, s);
        address _addr = address(uint160(uint256(keccak256(abi.encodePacked(name)))));
        require(labelExist[_addr] == true, "Label no exist");

        return store[_addr];
    }

    ////////////////////////////
    function labelName(uint64 index) external view auth returns (string memory) {
        require(index < total);
        return labels[index];
    }

    function labelNamePermit(
        uint64 index,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view {
        require(deadline >= block.timestamp, "vault: execute timeout");
        bytes32 params = keccak256(
            abi.encodePacked(signer, index, deadline, DOMAIN_SEPARATOR, LABEL_NAME_PERMIT_TYPE_HASH)
        );
        verifyPermit(params, v, r, s, "vault: label name permit ERROR");
    }

    function labelNameDirectly(
        uint64 index,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (string memory) {
        require(index < total);
        labelNamePermit(index, deadline, v, r, s);
        return labels[index];
    }
}
