import { ethers, deployments } from "hardhat";
import { contractIdentifier } from "../../../identifier";
import { Account } from "../account";
import { Dummy721 } from "../../../typechain-types/contracts/Dummy721";

export class ERC721 {
  private static readonly ident = contractIdentifier.Dummy1155;
  private constructor() {}

  public static async get() {
    return deployments.createFixture(this.fixture);
  }

  private static async fixture() {
    await deployments.fixture(this.ident);

    const accounts = await Account.get();
    const contract: Dummy721 = await ethers.getContract(this.ident);

    return contract;
  }
}
