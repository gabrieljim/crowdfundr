//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Project {
    uint256 public fundingGoal;
    uint256 public totalFunding;
    uint256 public idCounter = 3;
    uint256 public deadline;
    address public owner;
    uint256 public constant MINIMUM_CONTRIBUTION = 0.01 ether;
    bool public projectFailed;
    bool public fundingGoalReached;

    mapping(address => uint256) public contributions;

    mapping(uint256 => address) public ownerOf;
    mapping(address => uint256) public tierOf;

    constructor(address newOwner, uint256 startingFundingGoal) {
        require(newOwner != address(0));
        owner = newOwner;
        fundingGoal = startingFundingGoal;
        deadline = block.timestamp + 30 days;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner allowed.");
        _;
    }

    function _awardTier(uint256 amountContributed) internal {
        uint8 tierType = 1;
        idCounter++;

        if (amountContributed >= 1 ether) {
            tierType = 3;
        } else if (amountContributed >= 0.25 ether) {
            tierType = 2;
        }

        uint256 id = (idCounter << 2) | tierType;
        ownerOf[id] = msg.sender;
        tierOf[msg.sender] = id;
    }

    function getUserTier() external view returns (uint256) {
        uint256 userTier = tierOf[msg.sender];
        uint256 awardTier = userTier % 4;
        return awardTier;
    }

    function contribute() external payable {
        require(
            !projectFailed && !fundingGoalReached,
            "Contribution is not allowed anymore."
        );
        require(
            msg.value >= MINIMUM_CONTRIBUTION,
            "Value must be at least 0.01 ETH."
        );
        assert(totalFunding <= fundingGoal);

        contributions[msg.sender] += msg.value;
        totalFunding += msg.value;
        _awardTier(contributions[msg.sender]);

        if (totalFunding >= fundingGoal) {
            fundingGoalReached = true;
        }
    }

    function cancelProject() external onlyOwner {
        projectFailed = true;
    }

    function withdrawContributedFundsOwner(uint256 amountToWithdraw)
        external
        onlyOwner
    {
        require(fundingGoalReached, "Funding goal not reached yet.");
        require(amountToWithdraw <= totalFunding, "Not enough funds available");

        totalFunding -= amountToWithdraw;
        payable(owner).transfer(amountToWithdraw);
    }

    function withdrawContribution() external {
        require(projectFailed, "Project still going.");
        require(contributions[msg.sender] > 0, "No available funds");

        uint256 amountToTransfer = contributions[msg.sender];
        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(amountToTransfer);
    }
}
