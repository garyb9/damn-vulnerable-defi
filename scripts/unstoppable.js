// const hre = require("hardhat");

async function main() {

  const attacker = hre.attacker;
  console.log(attacker)
  const DamnValuableToken = await ethers.getContractFactory("DamnValuableToken");
  const dvt = await DamnValuableToken.deploy();
  await dvt.deployed();
  console.log("DamnValuableToken deployed to:", dvt.address);


  const UnstoppableLender = await ethers.getContractFactory("UnstoppableLender");
  const lender = await UnstoppableLender.deploy(dvt.address);
  await lender.deployed();
  console.log("UnstoppableLender deployed to:", lender.address);


  const ReceiverUnstoppable = await ethers.getContractFactory("ReceiverUnstoppable");
  const receiver = await ReceiverUnstoppable.deploy(lender.address);
  await receiver.deployed();
  console.log("ReceiverUnstoppable deployed to:", receiver.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
