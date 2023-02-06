import { HardhatRuntimeEnvironment } from "hardhat/types";
import {
  ethers,
  deployments,
  getUnnamedAccounts,
  getNamedAccounts,
} from "hardhat";
import { contractIdentifier, accountIdentifier } from "../../../identifier";

export class Snapshot {
  private constructor() {}

  public static async getAuctionManager1155() {}

  private static async auctionManager1155Fixtures() {}

  public static async getFixPriceAuctionManager721() {}

  private static async fixPRiceAuctionManager1155Fixtures() {}

  private static async getDummy721NFT() {}

  private static async getDummy1155NFT() {}
}
