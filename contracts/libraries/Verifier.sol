// SPDX-License-Identifier: MIT
pragma solidity >=0.8.12;

library Verifier {
    function verifyPermit(
        address signer,
        bytes32 params,
        uint8 v,
        bytes32 r,
        bytes32 s,
        string memory notification
    ) internal pure {
        bytes32 paramsHash = keccak256(abi.encodePacked(params));
        bytes32 digest = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", paramsHash));

        //Determine whether the result address of ecrecover is equal to addr; if not, revert directly
        require(ecrecover(digest, v, r, s) == signer, notification);
    }
}
