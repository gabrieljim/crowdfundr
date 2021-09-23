//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./Project.sol";

contract ProjectFactory {
    mapping(address => Project[]) projects;

    function createProject(address owner, uint256 fundingGoal) external {
        Project newProject = new Project(owner, fundingGoal);
        projects[owner].push(newProject);
    }

    function getProjectsOf(address account)
        external
        view
        returns (Project[] memory)
    {
        return projects[account];
    }
}
