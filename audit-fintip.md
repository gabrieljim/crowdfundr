# Micro-audit

Done by: Kyle Baker
Date: Sep 25 2021
Repo: https://github.com/gabrieljim/crowdfundr
Commit: a3a3f2d9717c77609ad6b3630cc495cb9c39ddff


## issues

### file: contracts/Project.sol 

#### line: 8
severity: code quality
comments: line features a mapping named `projects`, which contains a variety of arrays of `Project` contract addresses. While not a serious issue, code clarity can in general be increased by making the difference between a mapping and the arrays contained within that mapping more explicit.
```
	mapping(address => Project[]) projects;
```
recommendation: consider renaming mapping to `addressToProjects` to add clarity.


### file: contracts/Project.sol 

#### line: 22
severity: code quality
comments: No longer necessary in current version of solidity.
```
        require(newOwner != address(0));
```
recommendation: remove line


#### line: 33
severity: code quality
comments: 
Subjectively: moderately unclear naming. isProjectCanceled() describes both cancelation by owner (referred to in code as `projectCanceledByOwner`, as well as failure state due to time contraints. 
```
    function isProjectCanceled() public view returns (bool) {
        return ((block.timestamp > deadline && !fundingGoalReached) ||
            projectCanceledByOwner);
    }
```
Redesigning to check `isProjectActive()`, instead, would remove need for duplicate check of `!fundingGoalReached` on line 69:
```
        require(
            !isProjectCanceled() && !fundingGoalReached,
            "Contribution is not allowed anymore."
        );

```
New method would look like this, with more direct logic:
```
    function isProjectActive() public view returns (bool) {
        return (block.timestamp < deadline && !fundingGoalReached && !projectCanceledByOwner);
    }

```
Check on line 69 could then be changed to this:
```
        require(isProjectActive(), "Contribution is not allowed anymore.");

```
recommendation: considering replacing with a function that returns project status


#### line: 88
severity: high
comments: Project owner may want to cancel project even after receiving all funds, enabling a refund to users. This is not uncommon, and occurs with many kickstarter projects for various reasons. Without this option, refunds would become potentially complex and require new code written--likely at the additional expensive of a new contract written.
```
    function cancelProject() external onlyOwner {
        require(!fundingGoalReached, "Funding goal already reached");
        projectCanceledByOwner = true;
    }
```
recommendation: Remove prohibition on cancelling project after funding goal reached.


#### line: 68
severity: high
comments: This line will prevent funds from going over the funding goal. The project spec explicitly describes allowing a final contribution to push the contribution amount beyond the funding goal, and only preventing further contributions _after_ the goal is met.
The current code would:
- require a perfect last contribution to exactly fulfil the goal amount but not a single gwei more.
- create scenarios where a project could become impossible to fulfil because the amount remaining to reach the goal would be less than .01 eth.
```
59    function contribute() external payable {
60        require(
61            !isProjectCanceled() && !fundingGoalReached,
62            "Contribution is not allowed anymore."
63        );
64        require(
65            msg.value >= MINIMUM_CONTRIBUTION,
66            "Value must be at least 0.01 ETH."
67        );
68        assert(totalFunding <= fundingGoal);


```
recommendation: Remove assert() call.


### test/Project.test.js

#### line: 83
severity: code quality
comments: Test claims to test gold tier, actually tests bronze tier.
recommendation: correct test label

```
        ✓ Awards gold tier
        ✓ Awards silver tier
        ✓ Awards gold tier
```
