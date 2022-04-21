//SPDX-License-Identifier: MIT
pragma solidity >= 0.8.12;

import "./interfaces/ISeed.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/ITreasury.sol";
import "./libraries/SafeMath.sol";

contract Treasury is ITreasury {
    using SafeMath for uint256;

    //合约的有效部署者
    address public owner;
    //合约的有效调用者，该调用者一旦设置无法重置；
    address public caller;
    // Treasury合约开启通证铸造能力，默认关闭；一旦开启，无法重置；
    bool public callable;

    address public seedToken;

    //由于采用整数移位减半,会导致末位精度丢失，因此一个周期近似为2121万个tokens被铸造;
    uint256 MAX_MINTABLE_AMOUNT_IN_CYCLE = 21210000_000000000000000000;

    //分发给用户的初始量，每个周期会减半；
    uint256 GENESIS_MINTABLE_AMOUNT_FOR_USER = 2100_000000000000000000;

    //伴随用户下发行为，下发到treasury合约的token量;
    uint256 GENESIS_MINTABLE_AMOUNT_FOR_TREASURE = 210_000000000000000000; //bytes: 10110110001001010101110111110101111101010000000010000000000000000000

    //用来标记当前位于哪个铸币周期
    uint16  public cycle= 0;

    constructor(address _seed) {
        seedToken = _seed;
        owner = msg.sender;
        callable = false;
    }

    //caller 只能被设置一次且只能被owner设置
    function setCaller(address _caller) public {
        require(callable == false, "seedlist: caller has been set");
        require(msg.sender == owner, "seedlist: only owner can set caller");
        caller = _caller;
        callable = true;
    }

    modifier mintable {
        require(callable == true, "seedlist: caller is invalid");
        require(msg.sender==caller, "seedlist: only caller can do it");
        _;
    }

    modifier onlyOwner {
        require(msg.sender==owner, "seedlist: only owner can do it");
        _;
    }

    function mint(address receiver) public mintable override returns(bool){
       //通过totalSupply，计算当前在哪个周期；
        uint256 totalSupply = IERC20(seedToken).totalSupply();

       // 如果当前cycle和计算出来的不同，则表明进入了下一个通证周期, 此时更新cycle的值
        if(totalSupply/MAX_MINTABLE_AMOUNT_IN_CYCLE>cycle){
            cycle = cycle+1;
        }

        require(GENESIS_MINTABLE_AMOUNT_FOR_TREASURE>>cycle > 0, "seedlist: treasury mint stop");

        ISeed(seedToken).mint(address(this), GENESIS_MINTABLE_AMOUNT_FOR_TREASURE>>cycle);

        ISeed(seedToken).mint(receiver, GENESIS_MINTABLE_AMOUNT_FOR_USER>>cycle);

        return true;
    }

    function withdraw(address receiver, address tokenAddress, uint256 amount) external onlyOwner returns(bool){
        require(receiver!=address(0) && tokenAddress!=address(0), "seedlist: ZERO ADDRESS");
        IERC20(tokenAddress).transfer(receiver, amount);
        return true;
    }

}
