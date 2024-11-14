A smart contract implementing auction mechanics where the seller offers an item for sale and sets a reserve price. Potential buyers, known as bidders, submit bids for the item. The highest bid that is equal to or exceeds the reserve price wins the auction. The auction ends when a predetermined time limit is reached.
---
# ```Input:```
```createAuction(uint itemNumber, uint startingPrice,uint duration) :``` This function allows the contract owner to create a new auction. It takes three parameters: itemNumber (the number of the item for auction).The itemNumber should be unique for each item, startingPrice in wei(the starting price of the auction) the startingPrice cannot be 0, and duration (the duration of the auction in seconds) cannot be 0. The function does not return anything.The auction starts as soon as this function is called.

```bid(uint itemNumber,uint bidAmount) :``` This is a payable function allows a user to place a bid on an item. It takes two parameters: itemNumber (the number of the item for which the bid is being placed) and bidAmount (the amount of the bid). The function does not return anything.

```cancelAuction(uint itemNumber) :``` This function allows the contract owner to cancel an auction. It takes one parameter: itemNumber (the number of the item for which the auction is being cancelled). An auction can only be cancelled if the auction is still active.The function does not return anything.

 
# ```Output:```
```checkAuctionActive(uint itemNumber) returns(bool):``` This function allows a user to check the status of an auction. It takes one parameter: itemNumber (the number of the item for which the auction status is being checked).

```timeLeft(uint itemNumber) returns(uint):```This function returns the time left in seconds for the auction for the given item Number , if the auction has not not started or it has already ended then the transaction should revert.

```checkHighestBidder(uint itemNumber) returns(address):``` This function allows a user to check the highest bidder of an item. It takes one parameter: itemNumber (the number of the item for which the owner is being checked). The function returns the address of the highest bidder if the auction is active or has ended, or address 0 if the auction has not started or has been cancelled.

```checkActiveBidPrice(uint itemNumber) returns(uint):``` This function returns the Highest bid price for the given item number if the auction is still active. If the auction has ended or has not started for the given item number then transaction should revert.
