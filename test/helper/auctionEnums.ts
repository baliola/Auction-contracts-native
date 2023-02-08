export enum AuctionState {
  OPEN = 0,
  CANCELLED = 1,
  ENDED = 2,
  DIRECT_BUY = 3,
  ENDED_BY_CREATOR = 4,
}

export enum AuctionType {
  FIXED_PRICE = 0,
  TIME_AUCTION = 1,
  OPEN_BID = 2,
  UNKNOWN = 3,
}

export enum AuctionEvents {
  NEW_BID = "NewBid",
  WITHDRAW_TOKEN = "WithdrawToken",
  WITHDRAW_FUNDS = "WithdrawFunds",
  CANCELLED = "AuctionCanceled",
  ENDED_BY_CREATOR = "EndedByCreator",
}

export enum AuctionManagerEvents {
  NEW_AUCTION = "NewAuction",
}
