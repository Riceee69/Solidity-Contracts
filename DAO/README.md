Decentralized Autonomous Organization (DAO) smart contract
---

# ```Input:```
```initializeDAO(uint _contributionTimeEnd, uint _voteTime, uint _quorum) :``` Initializes the DAO with specific parameters. _contributionTimeEnd sets the duration, in seconds from the initialization of the DAO, during which contributions are accepted._voteTime this parameter sets the duration, measured in seconds from the creation of a proposal, during which voting is open._quorum represents the minimum percentage of the combined total vote weightage from all contributors required for a proposal to be executed. Each vote holds a weight equivalent to the number of shares held by the individual voter.

```contribution() payable :``` Allows users to contribute ETH to the DAO. The amount contributed is converted into shares and added to the user's balance. The function ensures that contributions are only accepted within the set contribution time frame and that the amount is greater than zero.

```reedemShare(uint amount) :``` Enables investors to redeem their shares in exchange for the equivalent amount in Wei (1 wei equals 1 share) from the DAO's available funds. The function checks if the investor has enough shares and if the DAO has sufficient available funds before proceeding with the redemption.

```transferShare(uint amount, address to) :``` Allows investors to transfer a specified amount of their shares to another address. The function ensures that the investor has enough shares to transfer and that the DAO has enough available funds. The recipient is added to the list of investors if not already present.

```createProposal(string calldata description, uint amount, address payable recipient) :``` Used by the contract owner to create a new proposal for funding. The proposal includes a description, the amount requested, the recipient's address. The function checks if there are enough available funds before creating the proposal.

```voteProposal(uint proposalId) :``` Allows investors to cast their votes on a specific proposal.The function ensures that an investor can only vote once per proposal and that the voting period is still open. Each vote holds a weight equivalent to the number of shares held by the individual voter.

```executeProposal(uint proposalId) :``` Can be called by the contract owner to execute a proposal after the voting period has ended. The function checks if the proposal has received enough vote weightage to meet the quorum and then transfers the requested funds to the recipient if successful.

 

# ```Output:```
```proposalList() returns (string[],uint[],address[]):``` Returns 3 arrays, array of all the description, array of amount, and array of recipient, where each index of these represents a proposal.

```allInvestorList() returns (address[] memory):``` Provides a list of all investor addresses that have contributed to the DAO. This function is useful for tracking and managing the investor base.