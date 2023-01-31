module.exports = (artifacts: Truffle.Artifacts) => {
  return async (
    deployer: Truffle.Deployer,
    network: string,
    accounts: string[]
  ) => {
    const baliola = getBaliolaWallet(accounts);
    const manager = getAuctionManagerManagerAccounts(accounts);

    const auctionManager721 = artifacts.require("AuctionManager721");

    deployer.deploy(auctionManager721, baliola, manager);

    await auctionManager721.deployed();

    console.log(
      `deployed auction manager 721 at address ${auctionManager721.address}`
    );
  };
};
