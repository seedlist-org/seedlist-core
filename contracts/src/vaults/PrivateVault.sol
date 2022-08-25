// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.12;
import "../../interfaces/vaults/IPrivateVault.sol";
import { Constant } from "../../libraries/Constant.sol";
import "../../interfaces/validator/IValidator.sol";

contract PrivateVault is IPrivateVaultHub {
    address private signer;
    address private validator;
    address public caller;

    // Each vault can only participate in the mint seed behavior once
    bool public minted;

    //Used to determine whether a label already exists
    mapping(address => bool) private labelExist;

    // Used to indicate where a label is stored
    mapping(uint64 => address) private labels;

    // The mapping relationship between the hash value used to indicate the label and the true value of the label
    mapping(address => string) private hashToLabel;

    // Used to store real encrypted data
    mapping(address => string) private store;

    uint64 public total;

    uint256 private fee = 150000000000000;

    bytes32 public DOMAIN_SEPARATOR;

    modifier auth() {
        require(msg.sender == caller, "vault:caller is invalid");
        _;
    }

    constructor(
        address _signer,
        address _caller,
        address _validator
    ) {
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

        //Determine whether the result address of ecrecover is equal to addr; if not, revert directly
        require(ecrecover(digest, v, r, s) == signer, notification);
    }

    //cryptoLabel is encrypt message from Label value
    function saveWithMinting(
        string memory data,
        string memory cryptoLabel,
        address labelHash
    ) external auth {
        require(minted == false, "vault:mint has done");

        //label was unused
        require(labelExist[labelHash] == false, "vault:label has exist");

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
        require(minted == false, "vault:mint has done");
        require(IValidator(validator).isValid(tx.origin) == true, "vault: validator unpass");
        saveWithMintingPermit(data, cryptoLabel, labelHash, deadline, v, r, s);

        //label was unused
        require(labelExist[labelHash] == false, "vault:label has exist");

        store[labelHash] = data;
        labels[total] = labelHash;
        hashToLabel[labelHash] = cryptoLabel;
        total++;
        labelExist[labelHash] = true;

        minted = true;
    }

    ////////////////////////////
    function saveWithoutMinting(
        string memory data,
        string memory cryptoLabel,
        address labelHash
    ) external auth {
        //label was unused
        require(labelExist[labelHash] == false, "vault:label has exist");
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
        require(deadline >= block.timestamp, "vault:execute timeout");
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
        verifyPermit(params, v, r, s, "vault:minting permit ERROR");
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
        require(IValidator(validator).isValid(tx.origin) == true, "vault: validator unpass");

        saveWithoutMintingPermit(data, cryptoLabel, labelHash, deadline, v, r, s);
        //label was unused
        require(labelExist[labelHash] == false, "vault:label has exist");
        store[labelHash] = data;
        labels[total] = labelHash;
        hashToLabel[labelHash] = cryptoLabel;
        total++;
        labelExist[labelHash] = true;
    }

    ////////////////////////////
    function getPrivateDataByIndex(uint64 index) external view auth returns (string memory) {
        require(total > index, "vault:labels keys overflow");
        return store[labels[index]];
    }

    function getPrivateDataByIndexPermit(
        uint64 index,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view {
        require(deadline >= block.timestamp, "vault:execute timeout");
        bytes32 params = keccak256(
            abi.encodePacked(
                signer,
                index,
                deadline,
                DOMAIN_SEPARATOR,
                Constant.PRIVATE_GET_PRIVATE_DATA_BY_INDEX_PERMIT_TYPE_HASH
            )
        );
        verifyPermit(params, v, r, s, "vault:index label permit ERROR");
    }

    function getPrivateDataByIndexDirectly(
        uint64 index,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (string memory) {
        require(total > index, "vault:data keys overflow");
        getPrivateDataByIndexPermit(index, deadline, v, r, s);
        return store[labels[index]];
    }

    ////////////////////////////
    function getPrivateDataByName(address name) external view auth returns (string memory) {
        require(labelExist[name] == true, "vault:label no exist");

        return store[name];
    }

    function getPrivateDataByNamePermit(
        address name,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view {
        require(deadline >= block.timestamp, "vault:execute timeout");
        bytes32 params = keccak256(
            abi.encodePacked(
                signer,
                name,
                deadline,
                DOMAIN_SEPARATOR,
                Constant.PRIVATE_GET_PRIVATE_DATA_BY_NAME_PERMIT_TYPE_HASH
            )
        );
        verifyPermit(params, v, r, s, "vault:get data by name permit ERROR");
    }

    function getPrivateDataByNameDirectly(
        address name,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (string memory) {
        getPrivateDataByNamePermit(name, deadline, v, r, s);
        require(labelExist[name] == true, "vaule:label no exist");

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
        require(deadline >= block.timestamp, "vault:execute timeout");
        bytes32 params = keccak256(
            abi.encodePacked(signer, index, deadline, DOMAIN_SEPARATOR, Constant.PRIVATE_LABEL_NAME_PERMIT_TYPE_HASH)
        );
        verifyPermit(params, v, r, s, "vault:label name permit ERROR");
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
        require(deadline >= block.timestamp, "vault:execute timeout");
        bytes32 params = keccak256(
            abi.encodePacked(
                signer,
                labelHash,
                deadline,
                DOMAIN_SEPARATOR,
                Constant.PRIVATE_LABEL_EXIST_PERMIT_TYPE_HASH
            )
        );
        verifyPermit(params, v, r, s, "vault:label exist permit ERROR");
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
