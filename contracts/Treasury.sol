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
    uint256 MINTABLE_AMOUNT = 2100000000000000000000; //bytes: 11100011101011101011010101110011011100100100000010100000000000000000000
    uint256 DIV_AMOUNT =      21210000000000000000000000;
    constructor(address _seed) {
        seedToken = _seed;
    }

    function Mint(address verifier, address receiver) public mintable override returns(bool){
        if(verifier==address(0)) {
            if(MINTABLE_AMOUNT == 0){
                return true;
            }

            uint256 totalSupply = IERC20(seedToken).totalSupply();

            if(totalSupply>=DIV_AMOUNT && totalSupply % DIV_AMOUNT == 0){
                MINTABLE_AMOUNT = MINTABLE_AMOUNT>>1;
                if(MINTABLE_AMOUNT==0){
                    ISeed(seedToken).mint(address(this), 210000000000000000000000);
                    return true;
                }

                if(MINTABLE_AMOUNT<56){  // 56: 111000
                    ISeed(seedToken).mint(address(this), 210000000000000000000000);
                }

            }

            ISeed(seedToken).mint(receiver, MINTABLE_AMOUNT);
            if(MINTABLE_AMOUNT/100>0){
                ISeed(seedToken).mint(address(this), MINTABLE_AMOUNT/100);
            }
            return true;
        }
        return true;
    }

    function withdraw(address receiver, uint256 amount) external onlyOwner returns(bool){
        IERC20(seedToken).transfer(receiver, amount);
        return true;
    }

}
