// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract DAO {
    address public owner;
    uint256 public voteTime;
    uint256 public voteEndTime;
    uint256 public quorum;
    uint256 public contributionDuration;
    uint256 proposalIds;
    address[] investors;

    mapping(uint256 => Proposal) proposals;
    mapping(address => uint256) public userShares;

    struct Proposal {
        string description;
        uint256 amount;
        address receipient;
        mapping(address => bool) alreadyVoted;
        uint256 votesReceived;
    }

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Unauthorised");
        _;
    }

    function initializeDAO(
        uint256 _contributionTimeEnd,
        uint256 _voteTime,
        uint256 _quorum
    ) public onlyOwner {
        require(
            _contributionTimeEnd > 0 && _voteTime > 0 && _quorum > 0,
            "Invalid parameters"
        );

        contributionDuration = block.timestamp + _contributionTimeEnd;
        voteTime = _voteTime;
        quorum = _quorum;
    }

    function contribution() public payable {
        require(
            block.timestamp <= contributionDuration && msg.value > 0,
            "Contribution Invalid"
        );

        if (userShares[msg.sender] == 0) {
            investors.push(msg.sender);
        }

        userShares[msg.sender] += msg.value;
    }

    function redeemShare(uint256 amount) public {
        require(
            userShares[msg.sender] >= amount && address(this).balance >= amount,
            "Insufficient DAO balance/shares"
        );

        userShares[msg.sender] -= amount;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }

    function transferShare(uint256 amount, address to) public {
        require(
            userShares[msg.sender] >= amount &&
                address(this).balance >= amount &&
                amount > 0,
            "Cannot Transfer Shares"
        );

        userShares[msg.sender] -= amount;
        userShares[to] += amount;
        if (userShares[to] == amount) investors.push(to);
    }

    function createProposal(
        string calldata description,
        uint256 amount,
        address payable receipient
    ) public onlyOwner {
        require(
            address(this).balance >= amount,
            "Insufficient balance for proposal value"
        );

        proposals[proposalIds].description = description;
        proposals[proposalIds].amount = amount;
        proposals[proposalIds].receipient = receipient;
        proposalIds++;

        voteEndTime = block.timestamp + voteTime;
    }

    function voteProposal(uint256 proposalId) public {
        require(block.timestamp <= voteEndTime, "Voting time has ended.");

        require(
            userShares[msg.sender] > 0 &&
                !proposals[proposalId].alreadyVoted[msg.sender],
            "Not a DAO member/ Already voted"
        );

        Proposal storage proposal = proposals[proposalId];
        proposal.votesReceived += userShares[msg.sender];
        proposal.alreadyVoted[msg.sender] = true;
    }

    function executeProposal(uint256 proposalId) public onlyOwner {
        //need fixed point logic
        uint256 votesRequired = (address(this).balance * quorum) / 100;
        require(
            proposals[proposalId].votesReceived >= votesRequired,
            "Quorum not met"
        );

        uint256 amount = proposals[proposalId].amount;
        (bool success, ) = proposals[proposalId].receipient.call{value: amount}(
            ""
        );
        require(success, "Transfer failed");
    }

    function proposalList() public view
    returns (string[] memory, uint[] memory, address[] memory)
    {
        require(proposalIds > 0, "No proposals yet");

        string[] memory proposalDescriptions = new string[](proposalIds);
        uint[] memory proposalAmounts = new uint[](proposalIds);
        address[] memory proposalReceipients = new address[](proposalIds);

        for (uint256 i = 0; i < proposalIds; i++) {
            proposalDescriptions[i] = proposals[i].description;
            proposalAmounts[i] = proposals[i].amount;
            proposalReceipients[i] = proposals[i].receipient;
        }

        return (proposalDescriptions, proposalAmounts, proposalReceipients);
    }

    function allInvestorList() public view returns (address[] memory) {
        require(investors.length > 0, "No investors yet");
        return investors;
    }
}
