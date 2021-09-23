const { expect } = require("chai");
const { parseEther } = require("ethers/lib/utils");
const { ethers } = require("hardhat");

describe("Project Factory", function () {
  let owner, addr1, addr2, addrs, projectFactory, Project, project;

  beforeEach(async () => {
    const ProjectFactory = await ethers.getContractFactory("ProjectFactory");
    Project = await ethers.getContractFactory("Project");
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    projectFactory = await ProjectFactory.deploy();
  });

  describe("Creating a project", () => {
    beforeEach(async () => {
      await projectFactory.createProject(owner.address, parseEther("1"));

      const deployedProjects = await projectFactory.getProjectsOf(
        owner.address
      );
      project = await Project.attach(
        deployedProjects[deployedProjects.length - 1]
      );
    });

    it("Sets owner to sender", async () => {
      const newProjectOwner = await project.owner();
      expect(newProjectOwner).to.be.equal(owner.address);
    });

    it("Sets funding goal correctly", async () => {
      const fundingGoal = await project.fundingGoal();
      expect(fundingGoal).to.be.equal(parseEther("1"));
    });
  });
});
