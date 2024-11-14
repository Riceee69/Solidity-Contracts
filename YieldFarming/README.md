Smart contract for Yield Farming using an ERC20 token. Each Liquidity Pool has a unique reward rate and reward providing time. Additionally, the contract will also track "whale" wallets. A whale wallet is defined as any wallet that has deposited more than 10,000 Wei at any point in time. Whale wallets are provided an additional 20% reward only when he/she claims their reward.
---
# ```Input:```
```addPool(uint maxAmount, uint yieldPercent, uint minDeposit, uint rewardTime) :``` This function allows the owner of the contract to add a new liquidity pool.The pool ID starts from 0. The parameters are as follows:

```maxAmount:``` The maximum amount in Wei that the pool can hold.
```yieldPercent:``` The percentage of rewards that will be given out per unit of time.
```minDeposit:``` The minimum amount of Wei that must be deposited into the pool.
```rewardTime:``` The time interval in seconds at which rewards are provided. After every rewardTime, the user will receive their share of rewards.
```depositWei(uint poolId) :``` This function allows anyone to deposit Wei into a specific liquidity pool. The function checks if the yield farming is active, the amount sent is greater than the minimum deposit amount, and the pool exists. No user is allowed to deposit twice in the same pool.

```withdrawWei(uint poolId, uint amount) :``` This function enables a user to withdraw a specified amount of Wei they have deposited. If the user withdraws all of their deposited Wei, their unclaimed rewards are reset to zero.

```claimRewards(uint poolId):``` This function allows a user to claim their rewards. The rewards are proportional to the amount of time and the amount of Wei that the user has deposited. For example, if the yield percent is 2%, reward time is 10 seconds and a user who deposited 100 Wei and waited for 30 seconds would receive 6 tokens. This function can only be called if the claimable reward is greater than 0.

 
# ```Output:```
```checkPoolDetails(uint poolId) returns (uint, uint, uint, uint):``` This function returns the details of the specified pool including the maximum amount, yield percentage, minimum deposit, and reward providing time.

```checkUserDeposits(address user) returns (uint, uint):``` This function returns the total amount of Wei that the user has deposited in all pools and the total claimable rewards.

```checkUserDepositInPool(uint poolId) returns (address[], uint[]):``` This function returns two arrays - the list of addresses that have deposited in the specified pool, and the amount they have deposited.

```checkClaimableRewards(uint poolId) returns (uint):``` This function returns the number of tokens that a depositor will receive after the reward time has passed for the specified pool. For example, if the yield rate is 2% ,reward time is 10 seconds, a user who deposited 100 Wei and waited for 30 seconds would receive 6 tokens.

```checkRemainingCapacity(uint poolId) returns (uint):``` This function returns the remaining capacity of the specified pool in Wei.

```checkWhaleWallets() returns (address[]):``` This function will return an array of addresses that are considered "whale" wallets.
