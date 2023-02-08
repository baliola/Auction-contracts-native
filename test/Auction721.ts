import {
  fixPriceAuction721Fixture,
  openBidAuction721Fixture,
  timeAuction721Fixture,
} from "./helper/snapshots/Erc721Manager";
import { expect } from "chai";
import { Auction721 } from "../typechain-types/Auction721";
import { AuctionEvents, AuctionType, DAY_IN_SECS } from "./helper/auctionEnums";
import { time } from "@nomicfoundation/hardhat-network-helpers";
import { ethers, getUnnamedAccounts } from "hardhat";
import { Event } from "ethers";
import { filterEvent } from "./helper/snapshots/Erc721Manager";

describe("Auction 721", function () {
  describe("fix price auction", function () {
    it("should create a new fix price auction", async function () {
      const fixtures = await fixPriceAuction721Fixture();

      const auction = fixtures.auction;

      const type = await auction.getAuctionType();
      const actualSeller = await auction.creator();

      expect(actualSeller).to.equal(fixtures.seller);
      expect(type).to.equal(AuctionType.FIXED_PRICE);
    });

    describe("Bidding", function () {
      it("should place a bid ", async function () {
        const testAccounts = await ethers.getUnnamedSigners();

        const fixtures = await fixPriceAuction721Fixture();

        const bidder = testAccounts[0];
        const bidderAddress = bidder.address;

        const auction = fixtures.auction.connect(bidder);
        const price = ethers.utils.parseEther(fixtures.startPrice.concat("2"));
        const action = await auction.placeBid({
          value: price,
          from: bidderAddress,
        });
        const bid = await action.wait();

        const events = bid.events as Event[];
        const bidEvent = filterEvent(events, AuctionEvents.NEW_BID);

        // should emit appropriate events
        expect(bidEvent?.args?.bidder).to.equal(bidderAddress);
        expect(bidEvent?.args?.amount.toString()).to.equal(price.toString());

        const maxBid = await auction.maxBid();
        const maxBidder = await auction.maxBidder();

        // should change the max bid amount and maxbidder
        expect(maxBid.toString()).to.equal(price.toString());
        expect(maxBidder.toString()).to.equal(bidderAddress);
      });

      it("should increase a bid ", async function () {
        const testAccounts = await ethers.getUnnamedSigners();

        const fixtures = await fixPriceAuction721Fixture();

        const bidder = testAccounts[0];
        const bidderAddress = bidder.address;

        const auction = fixtures.auction.connect(bidder);
        const price = ethers.utils.parseEther(fixtures.startPrice.concat("2"));
        const action = await auction.placeBid({
          value: price,
          from: bidderAddress,
        });
        const bid = await action.wait();

        const events = bid.events as Event[];
        const bidEvent = filterEvent(events, AuctionEvents.NEW_BID);

        // should emit appropriate events
        expect(bidEvent?.args?.bidder).to.equal(bidderAddress);
        expect(bidEvent?.args?.amount.toString()).to.equal(price.toString());

        const secondPrice = ethers.utils.parseEther("1");
        const secondAction = await auction.placeBid({
          value: secondPrice,
          from: bidderAddress,
        });

        const secondBid = await action.wait();

        const maxBid = await auction.maxBid();
        const maxBidder = await auction.maxBidder();

        const expectedPrice = price.add(secondPrice);

        // should change the max bid amount and maxbidder
        expect(maxBid.toString()).to.equal(expectedPrice.toString());
        expect(maxBidder.toString()).to.equal(bidderAddress);
      });

      it("should outbid a bid ", async function () {
        const testAccounts = await ethers.getUnnamedSigners();

        const fixtures = await fixPriceAuction721Fixture();

        const bidder = testAccounts[0];
        const bidderAddress = bidder.address;

        let auction = fixtures.auction.connect(bidder);
        const price = ethers.utils.parseEther(fixtures.startPrice.concat("2"));
        const action = await auction.placeBid({
          value: price,
          from: bidderAddress,
        });
        const bid = await action.wait();

        const events = bid.events as Event[];
        const bidEvent = filterEvent(events, AuctionEvents.NEW_BID);

        // should emit appropriate events
        expect(bidEvent?.args?.bidder).to.equal(bidderAddress);
        expect(bidEvent?.args?.amount.toString()).to.equal(price.toString());

        const secondBidder = testAccounts[1];
        const secondBidderAddress = secondBidder.address;
        auction = fixtures.auction.connect(secondBidder);

        const secondPrice = ethers.utils.parseEther("1");
        const secondAction = await auction.placeBid({
          value: secondPrice,
          from: secondBidderAddress,
        });

        const secondBid = await secondAction.wait();

        const secondEvents = secondBid.events as Event[];
        const secondBidEvent = filterEvent(secondEvents, AuctionEvents.NEW_BID);

        const maxBid = await auction.maxBid();
        const maxBidder = await auction.maxBidder();

        // should emit appropriate events
        expect(secondBidEvent?.args?.bidder).to.equal(secondBidderAddress);
        expect(secondBidEvent?.args?.amount.toString()).to.equal(
          secondPrice.toString()
        );

        // should change the max bid amount and maxbidder
        expect(maxBid.toString()).to.equal(secondPrice.toString());
        expect(maxBidder.toString()).to.equal(secondBidderAddress);
      });

      it("should bid and end the auction", async function () {});
    });

    describe("Withdraw", function () {
      it("should cancel the auction ", async function () {});

      it("should end the auction ", async function () {});

      it("should withdraw nft ", async function () {});

      it("should withdraw funds ", async function () {});

      it("should withdraw with the correct amount of fees and reward", async function () {});
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
      const actualSeller = await auction.creator();

      expect(actualSeller).to.equal(fixtures.seller);
      expect(type).to.equal(AuctionType.TIME_AUCTION);
    });

    describe("Bidding", function () {
      it("should place a bid ", async function () {
        const testAccounts = await ethers.getUnnamedSigners();

        const endTime = (await time.latest()) + DAY_IN_SECS;
        const fixtures = await timeAuction721Fixture(endTime);

        const bidder = testAccounts[0];
        const bidderAddress = bidder.address;

        const auction = fixtures.auction.connect(bidder);
        const price = ethers.utils.parseEther(fixtures.startPrice.concat("2"));
        const action = await auction.placeBid({
          value: price,
          from: bidderAddress,
        });
        const bid = await action.wait();

        const events = bid.events as Event[];
        const bidEvent = filterEvent(events, AuctionEvents.NEW_BID);

        // should emit appropriate events
        expect(bidEvent?.args?.bidder).to.equal(bidderAddress);
        expect(bidEvent?.args?.amount.toString()).to.equal(price.toString());

        const maxBid = await auction.maxBid();
        const maxBidder = await auction.maxBidder();

        // should change the max bid amount and maxbidder
        expect(maxBid.toString()).to.equal(price.toString());
        expect(maxBidder.toString()).to.equal(bidderAddress);
      });

      it("should increase a bid ", async function () {
        const testAccounts = await ethers.getUnnamedSigners();

        const endTime = (await time.latest()) + DAY_IN_SECS;
        const fixtures = await timeAuction721Fixture(endTime);

        const bidder = testAccounts[0];
        const bidderAddress = bidder.address;

        const auction = fixtures.auction.connect(bidder);
        const price = ethers.utils.parseEther(fixtures.startPrice.concat("2"));
        const action = await auction.placeBid({
          value: price,
          from: bidderAddress,
        });
        const bid = await action.wait();

        const events = bid.events as Event[];
        const bidEvent = filterEvent(events, AuctionEvents.NEW_BID);

        // should emit appropriate events
        expect(bidEvent?.args?.bidder).to.equal(bidderAddress);
        expect(bidEvent?.args?.amount.toString()).to.equal(price.toString());

        const secondPrice = ethers.utils.parseEther("1");
        const secondAction = await auction.placeBid({
          value: secondPrice,
          from: bidderAddress,
        });

        const secondBid = await action.wait();

        const maxBid = await auction.maxBid();
        const maxBidder = await auction.maxBidder();

        const expectedPrice = price.add(secondPrice);

        // should change the max bid amount and maxbidder
        expect(maxBid.toString()).to.equal(expectedPrice.toString());
        expect(maxBidder.toString()).to.equal(bidderAddress);
      });

      it("should outbid a bid ", async function () {});
    });

    describe("Withdraw", function () {
      it("should cancel the auction ", async function () {});

      it("should end the auction ", async function () {});

      it("should withdraw nft ", async function () {});

      it("should withdraw funds ", async function () {});

      it("should withdraw with the correct amount of fees and reward", async function () {});
    });
  });

  describe("open bid auction", function () {
    it("should create a new open bid auction", async function () {
      const fixtures = await openBidAuction721Fixture();

      const auction = fixtures.auction;

      const type = await auction.getAuctionType();
      const actualSeller = await auction.creator();

      expect(actualSeller).to.equal(fixtures.seller);
      expect(type).to.equal(AuctionType.OPEN_BID);
    });

    describe("Bidding", function () {
      it("should place a bid ", async function () {
        const testAccounts = await ethers.getUnnamedSigners();

        const fixtures = await openBidAuction721Fixture();

        const bidder = testAccounts[0];
        const bidderAddress = bidder.address;

        const auction = fixtures.auction.connect(bidder);
        const price = ethers.utils.parseEther(fixtures.startPrice.concat("2"));
        const action = await auction.placeBid({
          value: price,
          from: bidderAddress,
        });
        const bid = await action.wait();

        const events = bid.events as Event[];
        const bidEvent = filterEvent(events, AuctionEvents.NEW_BID);

        // should emit appropriate events
        expect(bidEvent?.args?.bidder).to.equal(bidderAddress);
        expect(bidEvent?.args?.amount.toString()).to.equal(price.toString());

        const maxBid = await auction.maxBid();
        const maxBidder = await auction.maxBidder();

        // should change the max bid amount and maxbidder
        expect(maxBid.toString()).to.equal(price.toString());
        expect(maxBidder.toString()).to.equal(bidderAddress);
      });

      it("should increase a bid ", async function () {
        const testAccounts = await ethers.getUnnamedSigners();

        const fixtures = await openBidAuction721Fixture();

        const bidder = testAccounts[0];
        const bidderAddress = bidder.address;

        const auction = fixtures.auction.connect(bidder);
        const price = ethers.utils.parseEther(fixtures.startPrice.concat("2"));
        const action = await auction.placeBid({
          value: price,
          from: bidderAddress,
        });
        const bid = await action.wait();

        const events = bid.events as Event[];
        const bidEvent = filterEvent(events, AuctionEvents.NEW_BID);

        // should emit appropriate events
        expect(bidEvent?.args?.bidder).to.equal(bidderAddress);
        expect(bidEvent?.args?.amount.toString()).to.equal(price.toString());

        const secondPrice = ethers.utils.parseEther("1");
        const secondAction = await auction.placeBid({
          value: secondPrice,
          from: bidderAddress,
        });

        const secondBid = await action.wait();

        const maxBid = await auction.maxBid();
        const maxBidder = await auction.maxBidder();

        const expectedPrice = price.add(secondPrice);

        // should change the max bid amount and maxbidder
        expect(maxBid.toString()).to.equal(expectedPrice.toString());
        expect(maxBidder.toString()).to.equal(bidderAddress);
      });

      it("should outbid a bid ", async function () {});
    });

    describe("Withdraw", function () {
      it("should cancel the auction ", async function () {});

      it("should end the auction ", async function () {});

      it("should withdraw nft ", async function () {});

      it("should withdraw funds ", async function () {});

      it("should withdraw with the correct amount of fees and reward", async function () {});
    });
  });
});
