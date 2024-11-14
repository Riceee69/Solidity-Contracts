// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract YieldFarming is ERC20{

    struct PoolDeposit{
        uint256 depositAmount;
        uint256 depositTime;
        uint256 claimableRewards;
    }

    struct Pool{
        uint256 maxAmount;
        uint256 yieldPercent;
        uint256 minDeposit;
        uint256 rewardTime;
        uint256 totalDeposit;
        uint256 userCount;
        mapping (address => PoolDeposit) alreadyDeposited;
        mapping (uint256 => address) users;
    }

    uint256 public poolIds;
    address public owner;
    mapping (address => bool) isWhale;
    address[] whales;

    mapping(uint256 => Pool) public pools;

    constructor() ERC20("Name", "SYM"){
        owner = msg.sender;
    }

    modifier onlyOwner{
        require(msg.sender == owner, "Only contract deployer can access this function");
        _;
    }

    function addPool(uint maxAmount, uint yieldPercent, uint minDeposit, uint rewardTime) public onlyOwner {
        require(minDeposit < maxAmount, "min deposit is greater then pool capacity");

        pools[poolIds].maxAmount = maxAmount;
        pools[poolIds].yieldPercent = yieldPercent;
        pools[poolIds].minDeposit = minDeposit;
        pools[poolIds].rewardTime = rewardTime;

        poolIds++;
    }

    function depositWei(uint poolId) public payable {
        Pool storage pool = pools[poolId];
        // check for valid poolId
        require(
            poolId <= poolIds && 
            pool.alreadyDeposited[msg.sender].depositAmount == 0,
            "Wrong Id/ Already deposited" 
        );

        uint256 valueInWei = msg.value;

        //check if the wei value is acceptable
        require(
            valueInWei >= pool.minDeposit && 
            valueInWei <= pool.maxAmount &&
            valueInWei != 0 && 
            checkRemainingCapacity(poolId) >= valueInWei,
            "Pool deposit criteria not met"
        );

        pool.totalDeposit += msg.value;
        pool.alreadyDeposited[msg.sender].depositAmount = msg.value;
        pool.alreadyDeposited[msg.sender].depositTime = block.timestamp;
        pool.users[pool.userCount] = msg.sender;
        pool.userCount++;     

        (uint256 cumulativeDeposits, ) = checkUserDeposits(msg.sender);   

        if( cumulativeDeposits >= 10000 && !isWhale[msg.sender]){
            isWhale[msg.sender] = true;
            whales.push(msg.sender);    
        }
    }

    function withdrawWei(uint poolId, uint amount) public {
        Pool storage pool = pools[poolId];
        require(
            poolId <= poolIds && 
            pool.alreadyDeposited[msg.sender].depositAmount > 0 && 
            pool.alreadyDeposited[msg.sender].depositAmount >= amount, 
            "Wrong Id / Hasn't deposited / Withdraw amount more than deposit" 
        );

        pool.alreadyDeposited[msg.sender].depositAmount -= amount;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed.");

    }

     function claimRewards(uint poolId) public {
        uint256 totalClaimableRewards = checkClaimableRewards(poolId);
        if(isWhale[msg.sender]){
            totalClaimableRewards += 20 * totalClaimableRewards / 100; 
        }
        //to mint the tokens
        _mint(msg.sender, totalClaimableRewards);
    }

    function checkPoolDetails(uint poolId) public view returns (uint, uint, uint, uint) {
        Pool storage pool = pools[poolId];
        return (pool.maxAmount, pool.yieldPercent, pool.minDeposit, pool.rewardTime);
    }

    function checkUserDeposits(address user) public view returns (uint, uint) {
        uint256 cumulativeDeposits;
        uint256 cumulativeRewards;

        for(uint i = 0; i < poolIds; i++){
            Pool storage pool = pools[i];
            cumulativeDeposits += pool.alreadyDeposited[user].depositAmount;
            uint256 initialDepositTime = pool.alreadyDeposited[msg.sender].depositTime;
            uint256 totalDepositTime = block.timestamp - initialDepositTime;
            uint256 rewardTime = pool.rewardTime;
            uint256 depositAmount = pool.alreadyDeposited[msg.sender].depositAmount;
            if( depositAmount == 0 || totalDepositTime >= rewardTime){
               cumulativeRewards += 0;
            }else{
                uint256 yieldPercent = pool.yieldPercent;
            
                //needs fixedpoint logic (maybe).
                uint256 rewardPerRewardTime = depositAmount * yieldPercent / 100 ;
                uint256 totalRewardTimes = totalDepositTime / rewardTime;

                uint256 totalClaimableRewards = rewardPerRewardTime * totalRewardTimes;
                cumulativeRewards += totalClaimableRewards;
            }
        }

        return (cumulativeDeposits, cumulativeRewards);
    }

    function checkUserDepositInPool(uint poolId) public view returns (address[] memory, uint[] memory) {
        Pool storage pool = pools[poolId];
        address[] memory userAddresses = new address[](pool.userCount);
        uint[] memory userDeposits = new uint[](pool.userCount);

        for(uint256 i = 0; i < pool.userCount; i++ ){
            userAddresses[i] = pool.users[i];
            userDeposits[i] = (pool.alreadyDeposited[pool.users[i]].depositAmount);
        }

        return (userAddresses, userDeposits);
    }

    function checkClaimableRewards(uint poolId) public view returns (uint) {
        Pool storage pool = pools[poolId];
        uint256 initialDepositTime = pool.alreadyDeposited[msg.sender].depositTime;
        uint256 totalDepositTime = block.timestamp - initialDepositTime;
        uint256 rewardTime = pool.rewardTime;
        uint256 depositAmount = pool.alreadyDeposited[msg.sender].depositAmount;
        if( depositAmount == 0){
            return 0;
        }
        require( totalDepositTime >= rewardTime, "No claimable rewards yet");

        uint256 yieldPercent = pool.yieldPercent;
        
        //needs fixedpoint logic (maybe).
        uint256 rewardPerRewardTime = depositAmount * yieldPercent / 100 ;
        uint256 totalRewardTimes = totalDepositTime / rewardTime;

        uint256 totalClaimableRewards = rewardPerRewardTime * totalRewardTimes;
        return totalClaimableRewards;
    }

    function checkRemainingCapacity(uint poolId) public view returns (uint) {
        Pool storage pool = pools[poolId];
        uint256 totalDepositInPool;

        for(uint256 i = 0; i < pool.userCount; i++ ){
            totalDepositInPool += pool.alreadyDeposited[pool.users[i]].depositAmount;
        }

        return (pool.maxAmount - totalDepositInPool);
    }

    function checkWhaleWallets() public view returns (address[] memory) {

        return whales;
    }

}
