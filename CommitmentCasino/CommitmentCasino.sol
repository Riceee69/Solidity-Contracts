// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

contract Casino{

    bytes32 userCommitment;
    bytes32 bankCommitment;
    uint256 userNumber;
    uint256 bankNumber;
    mapping(address => uint256) gameEthValues;
    address public bank;//the banks address usually set via constructor.

    function setUserCommitment(bytes32 commitment) external {
        require(userCommitment == 0x0);//only can initialize once when empty.
        userCommitment = commitment;
    }

    function revealUserNumber(uint256 number) external {
        require(bankCommitment != 0x0, "Bank needs to commit first");
        //abi.encodePacked to convert uint256 to bytes type.
        require(keccak256(abi.encodePacked(number)) == userCommitment, "Not the original number/userCommitment not set");
        userNumber = number;
    }

    function setBankCommitment(bytes32 commitment) external {
        require(bankCommitment == 0x0, "Already initialized");//only can initialize once when empty.
        bankCommitment = commitment;
    }

    function revealBankNumber(uint256 number) external {
        require(userCommitment != 0x0, "User needs to commit first");
        require(keccak256(abi.encodePacked(number)) == bankCommitment, "Not the original number/bankCommitment not set");
        bankNumber = number;
    }

    function playGame() external payable{
        require( keccak256(abi.encodePacked(userNumber)) == userCommitment && 
            keccak256(abi.encodePacked(bankNumber)) == bankCommitment, "Numbers not set/Commitments dont match");

        uint256 randomNumber = userNumber ^ bankNumber; //XOR Operator
        gameEthValues[msg.sender] = msg.value;

        if(randomNumber % 2 == 0){
            uint256 winningAmount = gameEthValues[msg.sender] * 2;
            (bool success, ) = msg.sender.call{value: winningAmount}("");
            require(success, "Transfer of winning amount failed");
        }

        bankCommitment = 0x0;
        userCommitment = 0x0;
    }

    
}


/* The only issue here is if user doesnt revel their number, to handle this just use a timeout function, after that
timeout bank wins automatically */