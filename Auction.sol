// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract Auction {
    address owner;

    struct Item{
        uint256 startingPrice;
        uint256 endTime;
        address highestBidder;
        uint256 highestBid;
        bool exists;
    }

    mapping (uint256 => Item) public items;

    modifier onlyOwner {
        require(msg.sender == owner, "Unauthorised to access the function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

	function createAuction(uint256 itemNumber,uint256 startingPrice,uint256 duration) public onlyOwner {
        require(startingPrice > 0 && duration > 0, "Invalid Parameters");
        require(!items[itemNumber].exists, "Item Number already exists");

        items[itemNumber].startingPrice = startingPrice;
        items[itemNumber].endTime = block.timestamp + duration;
        items[itemNumber].exists = true;
    }

    function bid(uint256 itemNumber, uint256 bidAmount) public {
        Item storage item = items[itemNumber];
        require(block.timestamp <= item.endTime, "Auction time expired");
        require(bidAmount >= item.startingPrice, "Bid less than starting price");

        if(item.highestBid == 0){
            item.highestBid = bidAmount;
            item.highestBidder = msg.sender;
        }else{
            if(bidAmount > item.highestBid){
            item.highestBid = bidAmount;
            item.highestBidder = msg.sender; 
            }
        }
    }

    function checkAuctionActive(uint256 itemNumber) public view returns (bool) { 
        return block.timestamp <= items[itemNumber].endTime? true : false;
    }

	function cancelAuction(uint256 itemNumber) public onlyOwner{ 
        require(block.timestamp <= items[itemNumber].endTime, "Auction time already expired");

        items[itemNumber].startingPrice = 0;
        items[itemNumber].endTime = 0;
        items[itemNumber].highestBid = 0;
        items[itemNumber].highestBidder = address(0);
    }

	function timeLeft(uint256 itemNumber) public view returns (uint256) { 
        require(block.timestamp <= items[itemNumber].endTime, "Auction time already expired");
        
        return items[itemNumber].endTime - block.timestamp;
    }

	function checkHighestBidder(uint256 itemNumber) public view returns (address) { 
        return items[itemNumber].highestBidder;
    }

	function checkActiveBidPrice(uint256 itemNumber) public view returns (uint256){ 
        require (items[itemNumber].highestBid > 0, "Auction ended/cancelled");

        return items[itemNumber].highestBid;
    }
}