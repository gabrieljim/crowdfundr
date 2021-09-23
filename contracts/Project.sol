//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Project {
    uint256 public fundingGoal;
    uint256 public totalFunding;
    address public owner;
    uint256 public constant minimumContribution = 0.01 ether;
    bool public projectFailed;
    bool public fundingGoalReached;

    mapping(address => uint256) public contributions;
    mapping(address => uint256) tiers;

    constructor(address newOwner, uint256 startingFundingGoal) {
        require(newOwner != address(0));
        owner = newOwner;
        fundingGoal = startingFundingGoal;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner allowed.");
        _;
    }

    function contribute() external payable {
        require(
            !projectFailed && !fundingGoalReached,
            "Contribution is not allowed anymore."
        );
        require(
            msg.value >= minimumContribution,
            "Value must be at least 0.01 ETH."
        );
        assert(totalFunding <= fundingGoal);

        contributions[msg.sender] += msg.value;
        totalFunding += msg.value;

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
