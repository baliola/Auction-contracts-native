import { HardhatRuntimeEnvironment } from "hardhat/types";
import {
  ethers,
  deployments,
  getUnnamedAccounts,
  getNamedAccounts,
} from "hardhat";
import { contractIdentifier, accountIdentifier } from "../../../identifier";
import { Account } from "../account";
import { AuctionManager721 } from "../../../typechain-types/Auction721Manager.sol/AuctionManager721";

export class ERC721Manager {
  private static readonly ident = contractIdentifier.auctionManager721;
  static accessor contract: null | AuctionManager721;
  private constructor() {}

  public static async get() {
    return deployments.createFixture(this.fixture);
  }

  public static async reset() {
    this.contract = null;
  }

  private static async fixture() {
    await deployments.fixture(this.ident);

    const accounts = await Account.get();
    const contract: AuctionManager721 = await ethers.getContract(this.ident);

    this.contract = contract;

    return contract;
  }
}
