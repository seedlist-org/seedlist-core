//SPDX-License-Identifier: MIT
pragma solidity >= 0.8.2;

import "./interfaces/ISeed.sol";
import "./interfaces/IERC20.sol";
import "./Owned.sol";
import "./interfaces/ITreasury.sol";
import "./interfaces/IRegistry.sol";
import "./libraries/SafeMath.sol";

contract Treasury is Owned, ITreasury {
    using SafeMath for uint256;
    //address constant Registry = "0xabcde";
    uint8 constant N=100;
    uint8 constant baseIncentive = 6;
    address public registry;
    address public seedToken;
    uint256 GENESIS_MINTABLE_AMOUNT = 2100000000000000000000; //bytes: 11100011101011101011010101110011011100100100000010100000000000000000000
    uint256 TREASURY_MINTABLE_AMOUNT_IN_CYCLE = 210000000000000000000000;
    uint256 DIV_AMOUNT = 21000000000000000000000000;
    uint256 userHasSupply = 0;

    struct counter{
        uint256 height; //计数器高度
        mapping(address=>uint256)record; //在height高度处，加密机使用的次数
        mapping(uint256=>address)machine; //加密机地址
        uint256 machineCnt; //这个计数器内统计的加密机的总数
        bool isEmpty; //当前这个计数器是否在用
    }

    // 最多有N(N=100)个计数器
    mapping(uint256=>counter)machineUsingRecorder;

    constructor(address _seed, address _registry) {
        require(_seed!=address(0x0) && _registry!=address(0x0));

        seedToken = _seed;
        registry = _registry;

        for(uint i=0; i<N; i++) {
            machineUsingRecorder[i].isEmpty = true;
        }
    }

    function getUsingRate(address _machine) internal view returns(uint256 , uint256){
        uint256 total;
        uint256 self;
        for(uint8 i=0; i<N; i++){
            if(machineUsingRecorder[i].isEmpty==false && block.number-N<machineUsingRecorder[i].height){
                for(uint256 j=0; j<machineUsingRecorder[i].machineCnt; j++){
                    total += machineUsingRecorder[i].record[machineUsingRecorder[i].machine[j]];
                    self += machineUsingRecorder[i].record[_machine];
                }
            }
        }
        return (total, self);
    }

    function updateMachineUsingRecorder(address _machine) internal {
        uint8 index=127;
        //先判断当前高度是否已经在计数器集合里
        for(uint8 i=0; i<N; i++){
            if(machineUsingRecorder[i].height==block.number){
                index = i;
                break;
            }
        }

        //如果当前高度在了，就直接更新
        if(index<N){
            //如果是第一次更新，要同步更新machineCnt
            if(machineUsingRecorder[index].record[_machine]==0){
                machineUsingRecorder[index].machine[machineUsingRecorder[index].machineCnt]=_machine;
                machineUsingRecorder[index].machineCnt++;
            }
            machineUsingRecorder[index].record[_machine]++;

            return;
        }

        //如果当前高度不在，就从头遍历machineUsingRecorder，找到第一个最远的，进行更新操作；
        for(uint8 i=0; i<N; i++){
            if(machineUsingRecorder[i].height<block.number-N){
                index = i;
                break;
            }
        }

        resetCounter(index);
        machineUsingRecorder[index].isEmpty = false;
        machineUsingRecorder[index].height = block.number;
        machineUsingRecorder[index].machine[machineUsingRecorder[index].machineCnt]=_machine;
        machineUsingRecorder[index].machineCnt++;
        machineUsingRecorder[index].record[_machine] = 1;
    }

    function resetCounter(uint256 index) internal {
        machineUsingRecorder[index].isEmpty = true;
        for(uint256 i=0; i<machineUsingRecorder[index].machineCnt; i++){
            delete(machineUsingRecorder[index].record[machineUsingRecorder[index].machine[i]]);
            delete(machineUsingRecorder[index].machine[i]);
        }
        machineUsingRecorder[index].machineCnt = 0;
        machineUsingRecorder[index].height = 0;
    }

    function Mint(address verifier, address receiver) public override returns(bool){
        if(userHasSupply>0 && userHasSupply.mod(DIV_AMOUNT) == 0) {
            GENESIS_MINTABLE_AMOUNT = GENESIS_MINTABLE_AMOUNT>>1;
        }

        //1.先判断加密机有没有注册
        if(IRegistry(registry).machineHasRegister(msg.sender)==false){
            revert("encrypt machine dont registry");
        }
        //2. 统计使用占比
        uint256 total;
        uint256 self;
        (total, self) = getUsingRate(msg.sender);
        uint256 mintAmount;
        if(total==0) {
            mintAmount = GENESIS_MINTABLE_AMOUNT;
        }else{
            mintAmount = uint256((baseIncentive/100) * GENESIS_MINTABLE_AMOUNT * (self/total));
        }

        ISeed(seedToken).mint(msg.sender, mintAmount);
        updateMachineUsingRecorder(msg.sender);
        emit MintMessage(address(msg.sender), mintAmount, "Mint for encrypt machiner successed");
        ISeed(seedToken).mint(receiver, GENESIS_MINTABLE_AMOUNT);
        userHasSupply += GENESIS_MINTABLE_AMOUNT;
        emit MintMessage(receiver, GENESIS_MINTABLE_AMOUNT, "Mint for user successed");
        return true;
    }
}

contract _Treasury is Owned, ITreasury {
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
