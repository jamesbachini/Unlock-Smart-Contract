const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Unlock', function () {
  let unlock;

  before(async () => {
    [owner,vc1,vc2,user1,user2] = await ethers.getSigners();
    const ownerBalance = await ethers.provider.getBalance(owner.address);
    console.log(`    Owner: ${owner.address} Balance: ${ethers.utils.formatEther(ownerBalance)} ETH`);
    
    const UnlockContract = await ethers.getContractFactory('Unlock');
    unlock = await UnlockContract.deploy(vc1.address, vc2.address);
    console.log(`    Unlock deployed to: ${unlock.address}`);
    
    await hre.ethers.provider.send('evm_increaseTime', [7 * 24 * 60 * 60]);
  });

  it('Deposit Funds From Two Users Check Price Increase', async function () {
    await unlock.connect(user1).deposit({value: ethers.utils.parseEther('1')});
    const bal1 = await unlock.balanceOf(user1.address);
    expect(bal1).to.be.gt(0);
    await unlock.connect(user2).deposit({value: ethers.utils.parseEther('1')});
    const bal2 = await unlock.balanceOf(user2.address);
    expect(bal2).to.be.lt(bal1);
  });

  it('Withdraw team funds', async function () {
    const due = await unlock.teamDue();
    expect(due).to.be.gt(0);
    await unlock.connect(owner).teamFunding(due);
    const bal1 = await unlock.balanceOf(owner.address);
    expect(bal1).to.be.gt(0);
  });

  it('Withdraw vc1 funds', async function () {
    const due = await unlock.vcDue(vc1.address);
    expect(due).to.be.gt(0);
    await unlock.connect(vc1).vcVesting(due);
    const bal1 = await unlock.balanceOf(owner.address);
    expect(bal1).to.be.gt(0);
  });

  it('Withdraw vc2 funds', async function () {
    const due = await unlock.vcDue(vc2.address);
    expect(due).to.be.gt(0);
    await unlock.connect(vc2).vcVesting(due);
    const bal1 = await unlock.balanceOf(owner.address);
    expect(bal1).to.be.gt(0);
  });

  it('Check market cap', async function () {
    const mktcap = await unlock.calculateMarketCap();
    expect(mktcap).to.be.gt(0);
  });

  it('Check TVL', async function () {
    const tvl = await unlock.calculateTVL();
    expect(tvl).to.be.gt(0);
  });
  
  it('Withdraw user funds', async function () {
    const bal1 = await unlock.balanceOf(user1.address);
    await unlock.connect(user1).withdraw(bal1);
  });
  


});
