import { ethers, deployments } from "hardhat";
import { contractIdentifier } from "../../../identifier";
import { Account, MapProp } from "../account";
import { AuctionManager721 } from "../../../typechain-types/Auction721Manager.sol/AuctionManager721";
import { dummy721Fixtures } from "./Erc721";
import { BigNumber, Event } from "ethers";
import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { Result } from "@ethersproject/abi";
import Signer from "ethers";
import { Auction721 } from "../../../typechain-types/Auction721";

export type FixPriceAuctionParam = {
  _directBuyPrice: BigNumber;
  _startPrice: BigNumber;
  _nftAddress: string;
  _tokenId: number;
};

export type TimeAuctionParam = {
  _endTime: number;
  _startPrice: BigNumber;
  _nftAddress: string;
  _tokenId: number;
};

export type OpenBidAuctionParam = {
  _startPrice: BigNumber;
  _nftAddress: string;
  _tokenId: number;
};

async function fixture() {
  const accounts = await Account.get();
  const contractIdent = contractIdentifier.auctionManager721;

  await deployments.deploy(contractIdent, {
    from: accounts.deployer,
    args: [accounts.baliola, accounts.manager],
    autoMine: true,
    deterministicDeployment: true,
    skipIfAlreadyDeployed: true,
  });

  const contract: AuctionManager721 = await ethers.getContract(contractIdent);

  return contract;
}

export async function auctionManager721Fixtures() {
  return await loadFixture(fixture);
}

export async function openBidAuction721Fixture(startPrice = "0.1") {
  const { accounts, contract } = await dummy721Fixtures();
  const auctionManager = await auctionManager721Fixtures();
  const seller = accounts.user_1;

  const nft = contract;

  await nft.getItem({ from: seller });
  const tokenCounter = await nft._tokenCounter();

  // we substract by 1 because the token counter only return us the next token id that will be
  // consumed when minting an nft
  // but we want the current nft token Id not the next so we subtract by 1
  const tokenId = tokenCounter.toNumber() - 1;

  await nft.setApprovalForAll(auctionManager.address, true, { from: seller });

  const _param: OpenBidAuctionParam = {
    _nftAddress: nft.address,
    _startPrice: ethers.utils.parseEther(startPrice),
    _tokenId: tokenId,
  };

  const tx = await auctionManager.createOpenBidAuction(
    _param._startPrice,
    _param._nftAddress,
    _param._tokenId,
    { from: seller }
  );

  const result = await tx?.wait();

  const event = filterEvent(result?.events as Event[], "NewAuction") as Event;
  const eventArgs = event.args as Result;
  const auctionAddress = eventArgs["auctionAddress"] as string;

  const auction: Auction721 = await ethers.getContractAt(
    contractIdentifier.auction721,
    auctionAddress
  );

  return { seller, auction, nft, auctionManager };
}

export function filterEvent(events: Event[], eventName: string) {
  for (const event of events) {
    if (event.event === eventName) return event;
  }
}

/**
 * @param {number} _endTime end auction timestamp in seconds
 */
export async function timeAuction721Fixture(
  _endTime: number,
  startPrice = "0.1"
) {
  const { accounts, contract } = await dummy721Fixtures();
  const auctionManager = await auctionManager721Fixtures();
  const seller = accounts.user_1;

  const nft = contract;

  await nft.getItem({ from: seller });
  const tokenCounter = await nft._tokenCounter();

  // we substract by 1 because the token counter only return us the next token id that will be
  // consumed when minting an nft
  // but we want the current nft token Id not the next so we subtract by 1
  const tokenId = tokenCounter.toNumber() - 1;

  await nft.setApprovalForAll(auctionManager.address, true, { from: seller });

  const _param: TimeAuctionParam = {
    _endTime,
    _nftAddress: nft.address,
    _startPrice: ethers.utils.parseEther(startPrice),
    _tokenId: tokenId,
  };

  const tx = await auctionManager.createTimeAuction(
    _endTime,
    _param._startPrice,
    _param._nftAddress,
    _param._tokenId,
    { from: seller }
  );

  const result = await tx?.wait();

  const event = filterEvent(result?.events as Event[], "NewAuction") as Event;
  const eventArgs = event.args as Result;
  const auctionAddress = eventArgs["auctionAddress"] as string;

  const auction: Auction721 = await ethers.getContractAt(
    contractIdentifier.auction721,
    auctionAddress
  );

  return { seller, auction, nft, auctionManager };
}

export async function fixPriceAuction721Fixture(
  directBuyPrice = "1",
  startPrice = "0.1"
) {
  const { accounts, contract } = await dummy721Fixtures();
  const auctionManager = await auctionManager721Fixtures();
  const seller = accounts.user_1;

  const nft = contract;

  await nft.getItem({ from: seller });
  const tokenCounter = await nft._tokenCounter();

  // we substract by 1 because the token counter only return us the next token id that will be
  // consumed when minting an nft
  // but we want the current nft token Id not the next so we subtract by 1
  const tokenId = tokenCounter.toNumber() - 1;

  await nft.setApprovalForAll(auctionManager.address, true, { from: seller });

  const _param: FixPriceAuctionParam = {
    _directBuyPrice: ethers.utils.parseEther(directBuyPrice),
    _startPrice: ethers.utils.parseEther(startPrice),
    _nftAddress: nft.address,
    _tokenId: tokenId,
  };

  const tx = await auctionManager.createFixedPriceAuction(
    _param._directBuyPrice,
    _param._startPrice,
    _param._nftAddress,
    _param._tokenId,
    { from: seller }
  );

  const result = await tx?.wait();

  const event = filterEvent(result?.events as Event[], "NewAuction") as Event;
  const eventArgs = event.args as Result;
  const auctionAddress = eventArgs["auctionAddress"] as string;

  const auction: Auction721 = await ethers.getContractAt(
    contractIdentifier.auction721,
    auctionAddress
  );

  return { seller, auction, nft, auctionManager, directBuyPrice, startPrice };
}
