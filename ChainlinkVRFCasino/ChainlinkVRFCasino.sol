// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;


//to get random number from chainlink VRF Oracle.
import {VRFV2WrapperConsumerBase} from "@chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";

contract Casino is VRFV2WrapperConsumerBase{

uint256 lastRequestedRandomId;
mapping (address => uint256) public gameWeiValues;
address[] public lastThreeWinners;

// Mainnet: address constant LINK_ADDRESS = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
address constant LINK_ADDRESS = 0x779877A7B0D9E8603169DdbD7836e478b4624789;

// Mainnet: address constant LINK_WRAPPER_ADDRESS = 0x5A861794B927983406fCE1D062e00b9368d97Df6
address constant LINK_WRAPPER_ADDRESS = 0xab18414CD93297B0d12ac29E63Ca20f515b3DB46;

constructor() VRFV2WrapperConsumerBase (LINK_ADDRESS, LINK_WRAPPER_ADDRESS) {}

function fundBank() external payable {}

function startGame() external payable {
    require(lastRequestedRandomId == 0);//ensure only one player can play at a time.

    //requestRandomness takes 3 parameters: gas limit, total confirmations for randomness(ensures security), total random words
    lastRequestedRandomId = requestRandomness(10000, 3, 2);//default values of these parameters. 
    gameWeiValues[msg.sender] = msg.value;

}

//this function is implemented after a random number request is made.
function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override{
    require(lastRequestedRandomId == requestId);//checking if they match

    uint256 randomNumber = randomWords[0];

    if (randomNumber % 2 == 0) {

        //lottery game even/odd
        uint256 winningAmount = gameWeiValues [msg.sender] * 2;
        uint256 winningFees = winningAmount * 25 / 100 ; //need fixed-point arithmetic here.
        (bool success, ) = msg.sender.call{value: winningAmount-winningFees}("");
        require(success, "Transfer failed.");

        //pushing last 3  winners to Array 
        lastThreeWinners.push(msg.sender);
        if(lastThreeWinners.length > 3){
            for(uint256 i = 0; i < lastThreeWinners.length - 1; i++){
                lastThreeWinners[i] = lastThreeWinners[i+1];
            }
            lastThreeWinners.pop();
        }

        //sending the 25% of winner's amount to a random address from the Array
        randomNumber = randomWords[1];
        uint256 randomIndex = randomNumber % lastThreeWinners.length;
        uint256 feeWinningAddress = lastThreeWinners[ randomIndex ] ; //
        (bool success, ) = feeWinningAddress.call{value: winningFees}("");
        require(success, "Transfer failed.");

    }

    gameWeiValues [msg.sender] = 0;
    lastRequestedRandomId = 0;
}
}