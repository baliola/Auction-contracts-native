class ContractDeployer {
  private constructor() {}

  public static async deployManager721(
    deployer: Truffle.Deployer,
    network: string,
    accounts: string[]
  ) {
    const baliola = getBaliolaWallet(accounts);
    const manager = getAuctionManagerManagerAccounts(accounts);

    const auctionManager721 = artifacts.require("AuctionManager721");

    deployer.deploy(auctionManager721, baliola, manager);

    await auctionManager721.deployed();

    console.log(
      `deployed auction manager 721 at address ${auctionManager721.address}`
    );
  }

  public static async deployManager1155(
    deployer: Truffle.Deployer,
    network: string,
    accounts: string[]
  ) {
    const baliola = getBaliolaWallet(accounts);
    const manager = getAuctionManagerManagerAccounts(accounts);

    const auctionManager721 = artifacts.require("AuctionManager1155");

    deployer.deploy(auctionManager721, baliola, manager);

    await auctionManager721.deployed();

    console.log(
      `deployed auction manager 721 at address ${auctionManager721.address}`
    );
  }

  public static async deployFixedPriceManager1155(
    deployer: Truffle.Deployer,
    network: string,
    accounts: string[]
  ) {
    const baliola = getBaliolaWallet(accounts);
    const manager = getAuctionManagerManagerAccounts(accounts);

    const auctionManager721 = artifacts.require("FixedPriceAuctionManager1155");

    deployer.deploy(auctionManager721, baliola, manager);

    await auctionManager721.deployed();

    console.log(
      `deployed auction manager 721 at address ${auctionManager721.address}`
    );
  }
}

module.exports = ContractDeployer;
