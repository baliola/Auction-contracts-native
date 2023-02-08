import {
  fixPriceAuction721Fixture,
  openBidAuction721Fixture,
  timeAuction721Fixture,
} from "./helper/snapshots/Erc721Manager";
import { expect } from "chai";
import { Auction721 } from "../typechain-types/Auction721";
import { AuctionType } from "./helper/auctionEnums";
import { time } from "@nomicfoundation/hardhat-network-helpers";

describe("Auction 721", function () {
  describe("fix price auction", function () {
    it("should create a new fix price auction", async function () {
      const fixtures = await fixPriceAuction721Fixture();

      const auction = fixtures.auction;

      const type = await auction.getAuctionType();
      expect(type).to.equal(AuctionType.FIXED_PRICE);
    });

    describe("Bidding", function () {
      // TODO
    });

    describe("Withdraw", function () {
      // TODO
    });
  });

  describe("time auction ", function () {
    it("should create a new time auction ", async function () {
      const current = await time.latest();
      const dayInSec = 86400;
      const endTime = current + dayInSec;

      const fixtures = await timeAuction721Fixture(endTime);

      const auction = fixtures.auction;

      const type = await auction.getAuctionType();
      expect(type).to.equal(AuctionType.TIME_AUCTION);
    });

    describe("Bidding", function () {
      // TODO
    });

    describe("Withdraw", function () {
      // TODO
    });
  });

  describe("open bid auction", function () {
    it("should create a new open bid auction", async function () {
      const fixtures = await openBidAuction721Fixture();

      const auction = fixtures.auction;

      const type = await auction.getAuctionType();
      expect(type).to.equal(AuctionType.OPEN_BID);
    });

    describe("Bidding", function () {
      // TODO
    });

    describe("Withdraw", function () {
      // TODO
    });
  });
});
