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
    uint256 USER_DEFULT_AMOUNT = 950;
    uint256 TREASURY_DEFAULT_AMOUNT = 50; // 5% distributed
    constructor(address _seed) {
        seedToken = _seed;
    }

    function Mint(address verifier, address receiver) public mintable override returns(bool){
    //function Mint(address verifier, address receiver) public override returns(bool){
        if(verifier==address(0)) {
            ISeed(seedToken).mint( receiver, USER_DEFULT_AMOUNT * (10 ** 18));
            ISeed(seedToken).mint( address(this), TREASURY_DEFAULT_AMOUNT * (10 ** 18));
            return true;
        }
        return true;
    }

    function withdraw(address receiver, uint256 amount) external onlyOwner returns(bool){
        IERC20(seedToken).transfer(receiver, amount);
        return true;
    }

}
