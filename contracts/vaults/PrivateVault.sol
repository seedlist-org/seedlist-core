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
    mapping(uint64 => address) private labels;

    //用来标示label的hash值和label真实值之间的映射关系
    mapping(address => string) private hashToLabel;

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

    //keccak256('labelIsExistDirectly(address labelHash, uint256 deadline)')
    bytes32 public constant LABEL_EXIST_PERMIT_TYPE_HASH =
    0x5e9a0e1424c7f33522faa862eafa09a676e96246da16c8b58d5803ba8010584f;

    //keccak256('getPrivateDataByNameDirectly(address name, uint256 deadline)')
    bytes32 public constant GET_PRIVATE_DATA_BY_NAME_PERMIT_TYPE_HASH =
    0x91fb9dd060bd9ffe42a43373e9de88b3a9b106cbce07f242fd6f2c4a41ef921d;

    //keccak256('getPrivateDataByIndexDirectly(uint64 index, uint256 deadline)')
    bytes32 public constant GET_PRIVATE_DATA_BY_INDEX_PERMIT_TYPE_HASH =
        0x17558919af4007c4fb94572ba8e807922ff7db103814e127ad21ef481ca35d98;

    //keccak256('saveWithoutMintingDirectly(string memory data, string memory cryptoLabel, address labelHash, uint256 deadline)')
    bytes32 public constant SAVE_WITHOUT_MINTING_PERMIT_TYPE_HASH =
    0x6681e086fd2042ee88d7eb0f54dbe27796a216fb36f4e834a75b15d90b082727;

    //keccak256('saveWithMintingDirectly(string memory data, string memory cryptoLabel, address labelHash, uint256 deadline)')
    bytes32 public constant SAVE_WITH_MINTING_PERMIT_TYPE_HASH =
    0x8774f567563ee2634c371978f5cfa8e41e5d255912344cb6b7d652f94c66c8a4;

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
    function saveWithMinting(string memory data, string memory cryptoLabel, address labelHash) external auth {
        require(minted == false, "seedlist: mint has done");

        //label没有被使用过
        require(labelExist[labelHash] == false, "Label has exist");

        store[labelHash] = data;
        labels[total] = labelHash;
        hashToLabel[labelHash] = cryptoLabel;
        total++;
        labelExist[labelHash] = true;

        minted = true;
    }

    function saveWithMintingPermit(
        string memory data,
        string memory cryptoLabel,
        address labelHash,
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
                labelHash,
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
        address labelHash,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(minted == false, "seedlist: mint has done");
        saveWithMintingPermit(data, cryptoLabel, labelHash, deadline, v, r, s);

        //label没有被使用过
        require(labelExist[labelHash] == false, "Label has exist");

        store[labelHash] = data;
        labels[total] = labelHash;
        hashToLabel[labelHash] = cryptoLabel;
        total++;
        labelExist[labelHash] = true;

        minted = true;
    }

    ////////////////////////////
    function saveWithoutMinting(string memory data, string memory cryptoLabel, address labelHash) external auth {
        //label没有被使用过
        require(labelExist[labelHash] == false, "Label has exist");
        store[labelHash] = data;
        labels[total] = labelHash;
        hashToLabel[labelHash] = cryptoLabel;
        total++;
        labelExist[labelHash] = true;
    }

    function saveWithoutMintingPermit(
        string memory data,
        string memory cryptoLabel,
        address labelHash,
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
                labelHash,
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
        address labelHash,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        saveWithoutMintingPermit(data, cryptoLabel, labelHash, deadline, v, r, s);
        //label没有被使用过
        require(labelExist[labelHash] == false, "Label has exist");
        store[labelHash] = data;
        labels[total] = labelHash;
        hashToLabel[labelHash] = cryptoLabel;
        total++;
        labelExist[labelHash] = true;
    }

    ////////////////////////////
    function getPrivateDataByIndex(uint64 index) external view auth returns (string memory) {
        require(total > index, "Labels keys overflow");
        return store[labels[index]];
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
        return store[labels[index]];
    }

    ////////////////////////////
    function getPrivateDataByName(address name) external view auth returns (string memory) {
        require(labelExist[name] == true, "Label no exist");

        return store[name];
    }

    function getPrivateDataByNamePermit(
        address name,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view {
        require(deadline >= block.timestamp, "vault: execute timeout");
        bytes32 params = keccak256(
            abi.encodePacked(signer, name, deadline, DOMAIN_SEPARATOR, GET_PRIVATE_DATA_BY_NAME_PERMIT_TYPE_HASH)
        );
        verifyPermit(params, v, r, s, "vault: get data by name permit ERROR");
    }

    function getPrivateDataByNameDirectly(
        address name,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (string memory) {
        getPrivateDataByNamePermit(name, deadline, v, r, s);
        require(labelExist[name] == true, "Label no exist");

        return store[name];
    }

    ////////////////////////////
    function labelName(uint64 index) external view auth returns (string memory) {
        require(index < total);
        return hashToLabel[labels[index]];
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
        return hashToLabel[labels[index]];
    }

    //////////////////////////////////////////
    function labelIsExist(address labelHash) external view auth returns (bool) {
        bool exist = labelExist[labelHash];
        return exist;
    }

    function labelIsExistPermit(
        address labelHash,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view {
        require(deadline >= block.timestamp, "vault: execute timeout");
        bytes32 params = keccak256(
            abi.encodePacked(signer, labelHash, deadline, DOMAIN_SEPARATOR, LABEL_EXIST_PERMIT_TYPE_HASH)
        );
        verifyPermit(params, v, r, s, "vault: label exist permit ERROR");
    }

    function labelIsExistDirectly(
        address labelHash,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (bool) {
        labelIsExistPermit(labelHash, deadline, v, r, s);
        return labelExist[labelHash];
    }
}
