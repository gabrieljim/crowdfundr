const { expect } = require("chai");
const { parseEther } = require("ethers/lib/utils");
const { ethers } = require("hardhat");

describe("Project Contract", () => {
  let owner, addr1, addr2, addrs, project;

  beforeEach(async () => {
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    const Project = await ethers.getContractFactory("Project");
    project = await Project.deploy(owner.address, parseEther("1.5"));
  });

  describe("Deployment", () => {
    it("Sets owner to sender", async () => {
      const projectOwner = await project.owner();
      expect(projectOwner).to.be.equal(owner.address);
    });

    it("Sets funding goal correctly", async () => {
      const fundingGoal = await project.fundingGoal();
      expect(fundingGoal).to.be.equal(parseEther("1.5"));
    });
  });

  describe("Only owner", () => {
    it("Only owner can cancel project manually", async () => {
      await expect(project.connect(addr1).cancelProject()).to.be.revertedWith(
        "Only owner allowed."
      );
    });

    it("Only owner can withdraw funds if funding goal is reached", async () => {
      await project.contribute({ value: parseEther("1.5") });
      await expect(
        project.connect(addr1).withdrawContributedFundsOwner(parseEther("1"))
      ).to.be.revertedWith("Only owner allowed.");
    });
  });

  describe("Contributing", () => {
    it("Contributes and gets balance assigned", async () => {
      await project.contribute({ value: parseEther("0.1") });

      const availableBalance = await project.contributions(owner.address);
      expect(availableBalance).to.be.equal(parseEther("0.1"));
    });

    it("Checks for minimum contribution", async () => {
      await expect(
        project.contribute({ value: parseEther("0.001") })
      ).to.be.revertedWith("Value must be at least 0.01 ETH.");
    });

    describe("Awarding tiers", () => {
      it("Awards gold tier", async () => {
        await project.contribute({ value: parseEther("1") });

        const tier = await project.getUserTier();
        expect(tier).to.be.equal("3");
      });

      it("Awards silver tier", async () => {
        await project.contribute({ value: parseEther("0.8") });

        const tier = await project.getUserTier();
        expect(tier).to.be.equal("2");
      });

      it("Awards gold tier", async () => {
        await project.contribute({ value: parseEther("0.2") });

        const tier = await project.getUserTier();
        expect(tier).to.be.equal("1");
      });
    });
  });

  describe("Project succesful", async () => {
    it("Reverts contribution if funding goal reached", async () => {
      await project.contribute({ value: parseEther("1.5") });

      await expect(
        project.contribute({ value: parseEther("0.1") })
      ).to.be.revertedWith("Contribution is not allowed anymore.");
    });

    it("Allows last contribution to go above funding goal", async () => {
      await project.contribute({ value: parseEther("1.4") });

      await project.contribute({ value: parseEther("0.6") });

      const currentFunding = await project.totalFunding();
      expect(currentFunding).to.be.equal(parseEther("2"));
    });

    it("Reverts owner withdrawal if project still going", async () => {
      await project.contribute({ value: parseEther("0.4") });
      await expect(
        project.withdrawContributedFundsOwner(parseEther("0.1"))
      ).to.be.revertedWith("Funding goal not reached yet.");
    });

    it("Allows owner to withdraw an amount", async () => {
      await project.connect(addr1).contribute({ value: parseEther("1.4") });
      await project.connect(addr2).contribute({ value: parseEther("1") });
      await expect(
        await project.withdrawContributedFundsOwner(parseEther("1"))
      ).to.changeEtherBalance(owner, parseEther("1"));
    });

    it("Reverts if owner tries to withdraw more than available", async () => {
      await project.connect(addr1).contribute({ value: parseEther("1.4") });
      await project.connect(addr2).contribute({ value: parseEther("1") });
      await project.withdrawContributedFundsOwner(parseEther("2"));
      await expect(
        project.withdrawContributedFundsOwner(parseEther("1"))
      ).to.be.revertedWith("Not enough funds available");
    });
  });

  describe("Project fails", async () => {
    it("Blocks contributions", async () => {
      await project.cancelProject();
      await expect(
        project.contribute({ value: parseEther("0.4") })
      ).to.be.revertedWith("Contribution is not allowed anymore.");
    });

    it("Reverts withdrawal if project still going", async () => {
      await project.contribute({ value: parseEther("0.4") });
      await expect(project.withdrawContribution()).to.be.revertedWith(
        "Project still going."
      );
    });

    it("Allows contributors to withdraw their funds", async () => {
      await project.contribute({ value: parseEther("0.4") });
      await project.cancelProject();
      await expect(await project.withdrawContribution()).to.changeEtherBalance(
        owner,
        parseEther("0.4")
      );
    });

    it("Reverts if no funds are available", async () => {
      await project.contribute({ value: parseEther("1") });
      await project.cancelProject();
      await expect(
        project.connect(addr1).withdrawContribution()
      ).to.be.revertedWith("No available funds");
    });
  });
});
