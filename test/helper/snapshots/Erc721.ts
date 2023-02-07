import { ethers, deployments } from "hardhat";
import { contractIdentifier } from "../../../identifier";
import { Dummy721 } from "../../../typechain-types/contracts/Dummy721";
import { BigNumber } from "ethers";
import { Account } from "../account";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

export async function dummy721Fixtures() {
  return await loadFixture(fixture);
}

async function fixture() {
  const accounts = await Account.get();
  const contractIdent = contractIdentifier.Dummy721;

  await deployments.deploy(contractIdent, {
    from: accounts.deployer,
    autoMine: true,
    deterministicDeployment: true,
    skipIfAlreadyDeployed: true,
  });

  const contract: Dummy721 = await ethers.getContract(contractIdent);

  return { contract, accounts };
}
