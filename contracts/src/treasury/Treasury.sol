//SPDX-License-Identifier: MIT
pragma solidity >=0.8.12;

import "../../interfaces/treasury/ISeed.sol";
import "../../interfaces/treasury/IERC20.sol";
import "../../interfaces/treasury/ITreasury.sol";

contract Treasury is ITreasury {
    //A valid deployer of the contract
    address public owner;

    //A valid caller of the contract;
    address public caller;

    // The Treasury contract enables the token casting capability, which is disabled by default;
    bool public callable;

    address public seedToken;

    uint256 public lastWithdrawAmount = 0;
    uint64  public withdrawCnt = 0;
    //if true, means starting the halving withdrawal mode
    bool public enableHalf = false;

    //Due to the use of integer shift halving, the precision of the last bit may be lost in the future,
    //so one cycle is approximately 23.1 million tokens to be minted;
    uint256 MAX_MINTABLE_AMOUNT_IN_CYCLE = 23100000_000000000000000000;

    //The initial amount distributed to users will be halved every cycle;
    uint256 GENESIS_MINTABLE_AMOUNT_FOR_USER = 2100_000000000000000000;

    //The amount of tokens issued to the treasury contract along with the user's issuing behavior;
    //bytes: 10110110001001010101110111110101111101010000000010000000000000000000
    uint256 GENESIS_MINTABLE_AMOUNT_FOR_TREASURE = 210_000000000000000000;

    //Used to mark which minting cycle is currently in
    uint16 public cycle = 0;

    constructor(address _seed) {
        seedToken = _seed;
        owner = msg.sender;
        callable = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Treasury: only owner can do");
        _;
    }

    function setCaller(address _caller) public onlyOwner {
        caller = _caller;
        callable = true;
    }

    modifier mintable() {
        require(callable == true, "Treasury: caller is invalid");
        require(msg.sender == caller, "Treasury: only caller can do");
        _;
    }

    function mint(address receiver) public override mintable returns (bool) {
        //calculate which cycle is currently in BY totalSupply;
        uint256 totalSupply = IERC20(seedToken).totalSupply();

        // If the current cycle is different from the calculated one,
        // it means that the next token cycle is entered, and the value of cycle is updated at this time
        if (totalSupply / MAX_MINTABLE_AMOUNT_IN_CYCLE > cycle) {
            cycle = cycle + 1;
        }

        require(GENESIS_MINTABLE_AMOUNT_FOR_TREASURE >> cycle > 0, "Treasury: mint stop");

        ISeed(seedToken).mint(address(this), GENESIS_MINTABLE_AMOUNT_FOR_TREASURE >> cycle);

        ISeed(seedToken).mint(receiver, GENESIS_MINTABLE_AMOUNT_FOR_USER >> cycle);
        return true;
    }

    receive() external payable {}

    function setHalf(bool enable) external onlyOwner returns(bool){
        enableHalf = enable;
        return true;
    }

    function withdraw(
        address receiver,
        address tokenAddress,
        uint256 amount
    ) external onlyOwner returns (bool) {
        require(receiver != address(0) && tokenAddress != address(0), "Treasury: ZERO ADDRESS");
        //The amount of each withdrawal does not exceed the normal amount of the previous amount,
        //When the number of withdrawals is not zero and the withdrawal amount is zero,
        //it means abandoning the withdrawal of SEED token
        if(tokenAddress==seedToken && enableHalf==true){
            if(withdrawCnt>0 && lastWithdrawAmount==0){
                return false;
            }
            if(withdrawCnt>0 && amount>lastWithdrawAmount>>1){
                amount = lastWithdrawAmount>>1;
            }

            lastWithdrawAmount = amount;
            withdrawCnt = withdrawCnt+1;
        }

        require(IERC20(tokenAddress).balanceOf(address(this))>=amount, "Treasury: amount invalid");
        IERC20(tokenAddress).transfer(receiver, amount);
        return true;
    }

    function withdrawETH(address payable receiver, uint256 amount) external onlyOwner returns (bool) {
        receiver.transfer(amount);
        return true;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Treasury: ZERO ADDRESS");
        owner = newOwner;
    }
}
