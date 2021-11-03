//SPDX-License-Identifier: MIT
pragma solidity >= 0.8.2;

import "./interfaces/ISeed.sol";
import "./interfaces/IERC20.sol";
import "./Owned.sol";
import "./interfaces/ITreasury.sol";
import "./libraries/SafeMath.sol";

contract Treasury is Owned, ITreasury {
    using SafeMath for uint256;

    address public seedToken;
    uint256 GENESIS_MINTABLE_AMOUNT = 2100000000000000000000; //bytes: 11100011101011101011010101110011011100100100000010100000000000000000000
    uint256 TREASURY_MINTABLE_AMOUNT_IN_CYCLE = 210000000000000000000000;
    uint256 DIV_AMOUNT = 21210000000000000000000000;
    constructor(address _seed) {
        seedToken = _seed;
    }

    function Mint(address verifier, address receiver) public mintable override returns(bool){
        uint256 totalSupply = IERC20(seedToken).totalSupply();

        if(totalSupply>=ISeed(seedToken).maxSupply()) {
            return true;
        }

        if(verifier==address(0)) {
            if(totalSupply.mod(DIV_AMOUNT) == 0) {
                ISeed(seedToken).mint(address(this), TREASURY_MINTABLE_AMOUNT_IN_CYCLE);
                if(totalSupply>0){
                    GENESIS_MINTABLE_AMOUNT = GENESIS_MINTABLE_AMOUNT>>1;
                }
                emit MintMessage(address(this), TREASURY_MINTABLE_AMOUNT_IN_CYCLE, "Mint for treasury successed");
            }

            ISeed(seedToken).mint(receiver, GENESIS_MINTABLE_AMOUNT);
            emit MintMessage(receiver, GENESIS_MINTABLE_AMOUNT, "Mint for user successed");
            return true;
        } else {
            IVerifier(verifier).Mint(receiver);
        }

        return true;
    }

    function withdraw(address receiver, uint256 amount) external onlyOwner returns(bool){
        IERC20(seedToken).transfer(receiver, amount);
        return true;
    }

}
