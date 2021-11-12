const { expect } = require("chai");
const { ethers } = require("hardhat");
const BigNumber = ethers.BigNumber;
const provider = ethers.provider;
describe("EtherFreeze", async function () {
  it("Should update the balance by the amount transacted", async function () {
    const EtherFreeze = await ethers.getContractFactory("EtherFreeze");
    const etherFreeze = await EtherFreeze.deploy();

    await etherFreeze.deployed();

    await etherFreeze.deposit(100, {value: 100000});

    expect(await etherFreeze.getAccountBalance()).to.equal(100000);

  });

  it("Should record the block when the frozen assets were deposited", async function () {
    const EtherFreeze = await ethers.getContractFactory("EtherFreeze");
    const etherFreeze = await EtherFreeze.deploy();

    await etherFreeze.deployed();

    await etherFreeze.deposit(100, {value: 100000});
    const thisBlock = await provider.getBlockNumber();
    expect(await etherFreeze.getAccountDepositBlock()).to.equal(thisBlock)
  });

  it("Should record the block when the frozen assets are available", async function () {
    const EtherFreeze = await ethers.getContractFactory("EtherFreeze");
    const etherFreeze = await EtherFreeze.deploy();

    await etherFreeze.deployed();
    const startBlock = await provider.getBlockNumber();
    console.log(startBlock);
    await etherFreeze.deposit(100, {value: 100000});

    expect(await etherFreeze.getAccountAvailableBlock()).to.equal(startBlock + 100);
  });

  it("Should calculate rewards proportional to the wei deposited and blocks frozen", async function () {
    const EtherFreeze = await ethers.getContractFactory("EtherFreeze");
    const etherFreeze = await EtherFreeze.deploy();

    const weiPerEth = BigNumber.from("1000000000000000000");

    const depositInEth = BigNumber.from(100);
    const deposit = depositInEth.mul(weiPerEth);
    const multiplier = BigNumber.from(100)
    const blocksHeld = BigNumber.from(100)

    await etherFreeze.deployed();

    await etherFreeze.deposit(blocksHeld, {value: deposit});
    const expectedAward0 = deposit.mul(multiplier.mul(blocksHeld));
    const expectedAward1 = expectedAward0.div(weiPerEth);
    expect(await etherFreeze.getAccountRewardsAvailable()).to.equal(deposit * multiplier * blocksHeld / weiPerEth);
  });

  it("Should prohibit a blocks-frozen value less than 1", async function() {
    const EtherFreeze = await ethers.getContractFactory("EtherFreeze");
    const etherFreeze = await EtherFreeze.deploy();

    await etherFreeze.deployed();
    await expect(etherFreeze.deposit(0, {value: 10000})).to.be.revertedWith("Blocks frozen must be a positive integer");
  });

  it("Should release rewards in the account to the msg sender upon redundant deposit", async function() {
    const EtherFreeze = await ethers.getContractFactory("EtherFreeze");
    const etherFreeze = await EtherFreeze.deploy();

    await etherFreeze.deployed();

    await etherFreeze.deposit(100, {value: 100000});
    
  });

});
