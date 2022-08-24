// SPDX-License-Identifier: UNLICENSED
pragma solidity >= 0.8.12;
import "../../interfaces/vaults/IPrivateVault.sol";
import {Constant} from "../../libraries/Constant.sol";
import "../../interfaces/validator/IValidator.sol";
contract PrivateVault is IPrivateVaultHub {
    address private signer;
    address private validator;
    address public caller;

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

    uint256 private fee = 150000000000000;

    bytes32 public DOMAIN_SEPARATOR;


    modifier auth() {
        require(msg.sender == caller, "Caller is invalid");
        _;
    }

    constructor(address _signer, address _caller, address _validator) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                Constant.PRIVATE_DOMAIN_TYPE_HASH,
                keccak256(bytes(Constant.PRIVATE_DOMAIN_NAME)),
                keccak256(bytes(Constant.PRIVATE_DOMAIN_VERSION)),
                chainId,
                address(this)
            )
        );

        signer = _signer;
        caller = _caller;
        validator = _validator;
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
        require(deadline >= block.timestamp, "vault:execute timeout");
        bytes32 params = keccak256(
            abi.encodePacked(
                signer,
                bytes(data),
                bytes(cryptoLabel),
                labelHash,
                deadline,
                DOMAIN_SEPARATOR,
                Constant.PRIVATE_SAVE_WITH_MINTING_PERMIT_TYPE_HASH
            )
        );
        verifyPermit(params, v, r, s, "vault:minting permit ERROR");
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

        require(minted == false, "vault: mint has done");
        require(IValidator(validator).isValid(tx.origin)==true, "vault: validator unpass");
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
                Constant.PRIVATE_SAVE_WITHOUT_MINTING_PERMIT_TYPE_HASH
            )
        );
        verifyPermit(params, v, r, s, "vault: minting permit ERROR");
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
        require(IValidator(validator).isValid(tx.origin)==true, "vault: validator unpass");

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
            abi.encodePacked(signer, index, deadline, DOMAIN_SEPARATOR, Constant.PRIVATE_GET_PRIVATE_DATA_BY_INDEX_PERMIT_TYPE_HASH)
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
            abi.encodePacked(signer, name, deadline, DOMAIN_SEPARATOR, Constant.PRIVATE_GET_PRIVATE_DATA_BY_NAME_PERMIT_TYPE_HASH)
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
            abi.encodePacked(signer, index, deadline, DOMAIN_SEPARATOR, Constant.PRIVATE_LABEL_NAME_PERMIT_TYPE_HASH)
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
            abi.encodePacked(signer, labelHash, deadline, DOMAIN_SEPARATOR, Constant.PRIVATE_LABEL_EXIST_PERMIT_TYPE_HASH)
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
