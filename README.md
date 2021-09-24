# Crowdfundr

This is the first project for the Optilistic course.

- [x] The smart contract is reusable; multiple projects can be registered and accept ETH concurrently.
- [x] The goal is a preset amount of ETH.
  - [x] This cannot be changed after a project gets created.
- [x] Regarding contributing:
  - [x] The contribute amount must be at least 0.01 ETH.
  - [x] There is no upper limit.
  - [x] Anyone can contribute to the project, including the creator.
  - [x] One address can contribute as many times as they like.
- [x] Regarding tiers:
  - [x] There are three tiers.
  - [x] Bronze tier is granted to anyone contribution.
  - [x] Silver tier is granted to a total contribution of at least 0.25 ETH.
  - [x] Gold tier is granted to a total contribution of at least 1 ETH.
  - [x] Tiers should be granted immediately so other apps can read them.
  - [x] "Total contribution" is scoped per-project (like kickstarter).
- [x] If the project is not fully funded within 30 days:
  - [x] The project goal is considered to have failed.
  - [x] No one can contribute anymore.
  - [x] Supporters get their money back.
  - [x] Tier grants are revoked.
- [x] Once a project becomes fully funded:
  - [x] No one else can contribute (however, the last contribution can go over the goal).
  - [x] The creator can withdraw any percentage of contributed funds.
- [x] The creator can choose to cancel their project before the 30 days are over, which has the same effect as a project failing.
