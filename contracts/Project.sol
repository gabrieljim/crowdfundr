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
    bool public projectCanceledByOwner;
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

    function isProjectCanceled() public view returns (bool) {
        return ((block.timestamp > deadline && !fundingGoalReached) ||
            projectCanceledByOwner);
    }

    function _awardTier(uint256 amountContributed) internal {
        uint8 tierType = 1;
        idCounter++;

        if (amountContributed >= 1 ether) {
            tierType = 3;
        } else if (amountContributed >= 0.25 ether) {
            tierType = 2;
        }

        /*
         * Shift the counter two bits to the left and add the tierType to the two empty 0s
         */
        uint256 id = (idCounter << 2) | tierType;
        ownerOf[id] = msg.sender;
        tierOf[msg.sender] = id;
    }

    function getUserTier() external view returns (uint256) {
        uint256 userTier = tierOf[msg.sender];

        /*
         * To get the first N bits of a byte, byte % 2 ** N
         *
         * The first two bits are the tier, so N = 2, therefore tier = userTier % 4
         */
        uint256 awardTier = userTier % 4;
        return awardTier;
    }

    function contribute() external payable {
        require(
            !isProjectCanceled() && !fundingGoalReached,
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
        require(!fundingGoalReached, "Funding goal already reached");
        projectCanceledByOwner = true;
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
        require(isProjectCanceled(), "Project still going.");
        require(contributions[msg.sender] > 0, "No available funds");

        uint256 amountToTransfer = contributions[msg.sender];
        contributions[msg.sender] = 0;
        uint256 userTier = tierOf[msg.sender];
        delete tierOf[msg.sender];
        delete ownerOf[userTier];
        payable(msg.sender).transfer(amountToTransfer);
    }
}
