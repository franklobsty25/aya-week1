import { ethers } from "hardhat";

async function main() {
  const f = ethers.encodeBytes32String("Frank");
  const a = ethers.encodeBytes32String("Adu");
  const o = ethers.encodeBytes32String("Opoku");
  const k = ethers.encodeBytes32String("Kodie");

  const voting = await ethers.deployContract("Voting", [[f, a, o, k]]);

  await voting.waitForDeployment();

  await voting.vote(3);

  await voting.winningProposal();

  const encoded = await voting.winnerName();

  console.log(ethers.decodeBytes32String(encoded));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
