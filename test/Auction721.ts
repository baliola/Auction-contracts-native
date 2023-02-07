import { openBidAuction721Fixture } from "./helper/snapshots/Erc721Manager";
import { expect } from "chai";
import { Auction721 } from "../typechain-types/Auction721";
import { AuctionType } from "./helper/auctionEnums";

describe("Auction 721", function () {
  describe("Deployments", function () {
    it("should create a new open bid", async function () {
      const fixtures = await openBidAuction721Fixture();

      const auction = fixtures.auction;

      const type = await auction.getAuctionType();
      expect(type).to.equal(AuctionType.OPEN_BID);
    });
  });
});
