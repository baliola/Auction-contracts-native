// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Auction721 {
    uint256 public endTime; // Timestamp of the end of the auction (in seconds)
    uint256 public startTime; // The block timestamp which marks the start of the auction
    uint256 public maxBid; // The maximum bid
    address payable public maxBidder; // The address of the maximum bidder
    address payable public creator; // The address of the auction creator
    uint256 public tokenId; // The id of the token
    bool public isCancelled; // If the the auction is cancelled
    bool public isDirectBuy; // True if the auction ended due to direct buy
    uint256 public minIncrement; // The minimum increment for the bid
    uint256 public directBuyPrice; // The price for a direct buy
    uint256 public startPrice; // The starting price for the auction
    address public nftAddress; // The address of the NFT contract
    IERC721 nft721; // The NFT token
    bool public directBuyStatus; // indicating whether the auction has a directbuy price
    bool public isEndedByCreator;
    address payable public baliolaWallet;

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }

    event NewBid(address indexed bidder, uint256 amount);
    event WithdrawToken(address indexed withdrawer);
    event WithdrawFunds(address indexed withdrawer, uint256 amount);
    event AuctionCanceled();
    event EndedByCreator();

    enum AuctionState {
        OPEN,
        CANCELLED,
        ENDED,
        DIRECT_BUY,
        ENDED_BY_CREATOR
    }

    enum AuctionType {
        FIXED_PRICE,
        TIME_AUCTION,
        OPEN_BID,
        UNKNOWN
    }

    function endAuctionByCreator() external returns (bool) {
        require(msg.sender == creator, "only the creator can end the auction!");
        require(
            getAuctionState() == AuctionState.OPEN,
            "can only end auction when it's open!"
        );

        isEndedByCreator = true;
        emit EndedByCreator();

        return true;
    }

    function cancelAuction() external returns (bool) {
        require(
            msg.sender == creator,
            "Only the auction creator can cancel the auction"
        );
        require(
            getAuctionState() == AuctionState.OPEN,
            "can only cancel auction if the auction is open"
        );
        isCancelled = true;

        nft721.transferFrom(address(this), creator, tokenId);
        maxBidder.transfer(maxBid);
        emit AuctionCanceled();
        return true;
    }

    function getAuctionState() public view returns (AuctionState) {
        if (isEndedByCreator) return AuctionState.ENDED_BY_CREATOR;
        if (isCancelled) return AuctionState.CANCELLED;
        if (isDirectBuy) return AuctionState.DIRECT_BUY;

        if (endTime == 0) {
            return AuctionState.OPEN;
        } else if (block.timestamp >= endTime) {
            return AuctionState.ENDED;
        } else {
            return AuctionState.OPEN;
        }
    }

    modifier mustEnd() {
        require(
            getAuctionState() != AuctionState.OPEN,
            "this action can only be done when the auction is ended"
        );
        _;
    }

    function getAuctionType() public view returns (AuctionType) {
        if (isOpenBid()) return AuctionType.OPEN_BID;
        if (isTimeAuction()) return AuctionType.TIME_AUCTION;
        if (isFixedPrice()) return AuctionType.FIXED_PRICE;
        else return AuctionType.UNKNOWN;
    }

    function isOpenBid() private view returns (bool status) {
        if (endTime == 0 && directBuyStatus == false) return true;
        else return false;
    }

    function isTimeAuction() private view returns (bool status) {
        if (endTime != 0 && directBuyStatus == false) return true;
        else return false;
    }

    function isFixedPrice() private view returns (bool status) {
        if (endTime == 0 && directBuyStatus == true) return true;
        else return false;
    }

    constructor(
        address payable _creator,
        uint256 _endTime,
        address payable _baliola,
        bool _directBuyStatus,
        uint256 _directBuyPrice,
        uint256 _startPrice,
        address _nftAddress,
        uint256 _tokenId
    ) {
        creator = _creator;
        endTime = _endTime;
        startTime = block.timestamp;
        minIncrement = 1e17; // 0.1 native currency
        directBuyStatus = _directBuyStatus;
        directBuyPrice = _directBuyPrice;
        startPrice = _startPrice;
        nft721 = IERC721(_nftAddress);
        nftAddress = _nftAddress;
        tokenId = _tokenId;
        maxBidder = _creator;
        baliolaWallet = _baliola;
        checkAuctionType();
    }

    function checkAuctionType() private view {
        AuctionType _type = getAuctionType();

        if (_type == AuctionType.UNKNOWN) revert("unknown auction type");

        if (_type == AuctionType.FIXED_PRICE && directBuyPrice == 0)
            revert(
                "cannot create fixed price auction with direct buy price : 0"
            );

        if (_type == AuctionType.OPEN_BID && directBuyPrice != 0)
            revert("open bid auction cannot have a direct buy price");

        if (_type == AuctionType.TIME_AUCTION && directBuyPrice != 0)
            revert("time auction cannot have a direct buy price");
    }

    function placeBid() external payable returns (bool) {
        uint256 bidAmount = msg.value;
        address payable bidder = payable(msg.sender);

        require(bidder != creator, "The auction creator can not place a bid");
        require(
            getAuctionState() == AuctionState.OPEN,
            "can only place bid if the auction open"
        );

        require(
            bidAmount > startPrice,
            "the bid must be higher than the start price"
        );

        if (directBuyStatus && bidAmount >= directBuyPrice) {
            isDirectBuy = true;
        }

        if (bidder == maxBidder) {
            return handleSameMaxBidder(bidAmount);
        }

        return handleDifferentMaxBidder(bidder, bidAmount);
    }

    function handleSameMaxBidder(uint256 bidAmount) private returns (bool) {
        uint256 _maxBid = maxBid; // maxbid stack cache

        require(
            bidAmount > minIncrement,
            "the bid must be higher than the minimum increment"
        );

        _maxBid = _maxBid + bidAmount;

        if (_maxBid >= directBuyPrice) {
            isDirectBuy = true; // The auction has ended
        }

        maxBid = _maxBid;

        return true;
    }

    function handleDifferentMaxBidder(address payable bidder, uint256 bidAmount)
        private
        returns (bool)
    {
        address payable lastHighestBidder = maxBidder;
        uint256 lastHighestBid = maxBid;

        require(
            bidAmount >= lastHighestBid + minIncrement,
            "The bid must be higher than the current bid + the minimum increment"
        );
        maxBid = bidAmount;
        maxBidder = bidder;

        if (lastHighestBid != 0) {
            lastHighestBidder.transfer(lastHighestBid);
        }

        emit NewBid(bidder, bidAmount);

        return true;
    }

    function withdrawToken() external mustEnd returns (bool) {
        address _maxBidder = maxBidder; // max bidder cache

        require(
            msg.sender == _maxBidder,
            " Only the highest bidder can  withdraw the token"
        );

        nft721.transferFrom(address(this), _maxBidder, tokenId);

        emit WithdrawToken(_maxBidder);

        return true;
    }

    function withdrawFunds() external mustEnd returns (bool) {
        address payable _creator = creator; // creator stack cache
        uint256 _maxBid = maxBid; // maxbid stack cache

        require(
            msg.sender == _creator,
            "The auction creator can only withdraw the funds"
        );

        uint256 principal = _calculatePrincipal(_maxBid);
        uint256 fee = _calculateFee(principal);
        uint256 reward = _calculateReward(_maxBid, fee);

        _creator.transfer(reward);
        baliolaWallet.transfer(fee);

        emit WithdrawFunds(_creator, _maxBid);

        return true;
    }

    function _calculatePrincipal(uint256 _maxBid)
        private
        pure
        returns (uint256)
    {
        return (_maxBid * 100) / 103;
    }

    function _calculateFee(uint256 _principal) private pure returns (uint256) {
        return (_principal * 3) / 100;
    }

    function _calculateReward(uint256 _maxBid, uint256 _fee)
        private
        pure
        returns (uint256)
    {
        return _maxBid - _fee;
    }

    /// @dev Default payable function to not allow sending to contract
    ///  Remember this does not necessarily prevent the contract
    ///  from accumulating funds.
    fallback() external payable {
        revert();
    }
}
