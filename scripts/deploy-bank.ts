import { ethers } from "hardhat";

async function main() {
  const bank = await ethers.deployContract("Bank");

  await bank.waitForDeployment();

  console.log(await bank.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
