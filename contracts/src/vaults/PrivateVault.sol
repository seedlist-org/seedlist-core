// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.12;
import {PrivateVaultTypeHashs} from "../../libraries/Constants.sol";

contract PrivateVault {
    address private signer;
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

    bytes32 public DOMAIN_SEPARATOR;

    address private privateValidator;

    modifier auth() {
        require(msg.sender == caller, "vault:auth");
        _;
    }

    constructor(
        address _signer,
        address _caller
    ) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                PrivateVaultTypeHashs.PRIVATE_DOMAIN_TYPE_HASH,
                keccak256(bytes(PrivateVaultTypeHashs.PRIVATE_DOMAIN_NAME)),
                keccak256(bytes(PrivateVaultTypeHashs.PRIVATE_DOMAIN_VERSION)),
                chainId,
                address(this)
            )
        );

        signer = _signer;
        caller = _caller;
        total = 0;
        minted = false;
    }

    //cryptoLabel is encrypt message from Label value
    function saveWithMinting(
        string calldata data,
        string calldata cryptoLabel,
        address labelHash
    ) external auth {
        require(minted == false, "vault:minted");

        //label was unused
        require(labelExist[labelHash] == false, "vault:exist");

        store[labelHash] = data;
        labels[total] = labelHash;
        hashToLabel[labelHash] = cryptoLabel;
        total++;
        labelExist[labelHash] = true;

        minted = true;
    }

    function saveWithoutMinting(
        string calldata data,
        string calldata cryptoLabel,
        address labelHash
    ) external auth {
        //label was unused
        require(labelExist[labelHash] == false, "vault:exist");
        store[labelHash] = data;
        labels[total] = labelHash;
        hashToLabel[labelHash] = cryptoLabel;
        total++;
        labelExist[labelHash] = true;
    }

    function getPrivateDataByIndex(uint64 index) external view auth returns (string memory) {
        require(total > index, "vault:overflow");
        return store[labels[index]];
    }

    function getPrivateDataByName(address name) external view auth returns (string memory) {
        require(labelExist[name] == true, "vault:no exist");

        return store[name];
    }

    function labelName(uint64 index) external view auth returns (string memory) {
        require(index < total);
        return hashToLabel[labels[index]];
    }

    function labelIsExist(address labelHash) external view auth returns (bool) {
        bool exist = labelExist[labelHash];
        return exist;
    }
}
