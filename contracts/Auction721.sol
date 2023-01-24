// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Auction721 {
    using SafeMath for uint256;
    uint256 public endTime; // Timestamp of the end of the auction (in seconds)
    uint256 public startTime; // The block timestamp which marks the start of the auction
    uint256 public maxBid; // The maximum bid
    address public maxBidder; // The address of the maximum bidder
    address public creator; // The address of the auction creator
    address public nftSeller; // the address of the nft seller
    uint256 public tokenId; // The id of the token
    bool public isCancelled; // If the the auction is cancelled
    bool public isDirectBuy; // True if the auction ended due to direct buy
    uint256 public minIncrement; // The minimum increment for the bid
    uint256 public directBuyPrice; // The price for a direct buy
    uint256 public startPrice; // The starting price for the auction
    address public nftAddress; // The address of the NFT contract
    IERC721 nft721; // The NFT token
    address public manager;
    bool public directBuyStatus; // indicating whether the auction has a directbuy price
    bool public isEndedByCreator;
    address public baliolaWallet;

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }

    event NewBid(address indexed bidder, uint256 amount); // A new bid was placed
    event WithdrawToken(address indexed withdrawer); // The auction winner withdrawed the token
    event WithdrawFunds(address indexed withdrawer, uint256 amount); // The auction owner withdrawed the funds
    event AuctionCanceled(); // The auction was cancelled
    event EndedByCreator();

    enum AuctionState {
        OPEN,
        CANCELLED,
        ENDED,
        DIRECT_BUY,
        ENDED_BY_CREATOR
    }

    modifier onlyManager() {
        require(msg.sender == manager, "only manager can call");
        _;
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
        // Cancel the auction
        require(
            msg.sender == creator,
            "Only the auction creator can cancel the auction"
        ); // Only the auction creator can cancel the auction
        require(
            getAuctionState() == AuctionState.OPEN,
            "can only cancel auction if the auction is open"
        ); // The auction must be open
        isCancelled = true; // The auction has been cancelled

        nft721.transferFrom(address(this), creator, tokenId); // Transfer the NFT token to the auction creator
        // TODO : refund maxbidder funds kepeng.transfer(maxBidder, maxBid);
        emit AuctionCanceled(); // Emit Auction Canceled event
        return true;
    }

    // Get the auction state
    function getAuctionState() public view returns (AuctionState) {
        if (isEndedByCreator) return AuctionState.ENDED_BY_CREATOR;
        if (isCancelled) return AuctionState.CANCELLED; // If the auction is cancelled return CANCELLED
        if (isDirectBuy) return AuctionState.DIRECT_BUY; // If the auction is ended by a direct buy return DIRECT_BUY

        if (endTime == 0) {
            return AuctionState.OPEN;
        } else if (block.timestamp >= endTime) {
            return AuctionState.ENDED;
        } else {
            return AuctionState.OPEN;
        }
    }

    // Auction constructor
    constructor(
        address _creator,
        uint256 _endTime,
        address _baliola,
        bool _directBuyStatus,
        uint256 _directBuyPrice,
        uint256 _startPrice,
        address _nftAddress,
        uint256 _tokenId,
        address _nftSeller
    ) {
        creator = _creator; // The address of the auction creator
        if (_endTime == 0) {
            endTime = 0;
        } else {
            endTime = _endTime; // The timestamp which marks the end of the auction (now + 30 days = 30 days from now)
        }
        startTime = block.timestamp; // The timestamp which marks the start of the auction
        minIncrement = 10000; // The minimum increment for the bid
        directBuyStatus = _directBuyStatus; // true if the auction has a fixed price, false otherwise
        directBuyPrice = _directBuyPrice; // The price for a direct buy
        startPrice = _startPrice; // The starting price for the auction
        nft721 = IERC721(_nftAddress); // The address of the nft token
        nftAddress = _nftAddress;
        tokenId = _tokenId; // The id of the token
        maxBidder = _creator; // Setting the maxBidder to auction creator.
        nftSeller = _nftSeller;
        manager = msg.sender;
        baliolaWallet = _baliola;
    }

    function handleSameMaxBidder(uint256 bidAmount) private returns (bool) {
        uint256 _directBuyPrice = directBuyPrice;

        require(
            bidAmount > minIncrement,
            "the bid must be higher than the minimum increment"
        );

        if (directBuyStatus) {
            if (bidAmount >= _directBuyPrice) {
                // If the bid is higher than the direct buy price
                isDirectBuy = true; // The auction has ended
            }

            maxBid = maxBid + bidAmount;

            if (maxBid >= _directBuyPrice) {
                isDirectBuy = true; // The auction has ended
            }

            return true;
        }

        maxBid = maxBid + bidAmount;

        return true;
    }

    function handleDifferentMaxBidder(address bidder, uint256 bidAmount)
        private
        returns (bool)
    {
        address lastHighestBidder = maxBidder; // The address of the last highest bidder
        uint256 lastHighestBid = maxBid; // The last highest bid

        require(
            bidAmount >= lastHighestBid + minIncrement,
            "The bid must be higher than the current bid + the minimum increment"
        ); // The bid must be higher than the current bid + the minimum increment
        maxBid = bidAmount; // The new highest bid
        maxBidder = bidder; // The address of the new highest bidder

        if (directBuyStatus) {
            if (bidAmount >= directBuyPrice) {
                // If the bid is higher than the direct buy price
                isDirectBuy = true; // The auction has ended
            }

            if (lastHighestBid != 0) {
                // TODO : transfer the prev bids to the prev highest bid
            }

            emit NewBid(bidder, bidAmount); // emit a new bid event

            return true; // The bid was placed successfully
        }

        if (lastHighestBid != 0) {
            // TODO : refund the previous bid to the previous highest bidder
        }

        emit NewBid(bidder, bidAmount); // emit a new bid event

        return true; // The bid was placed successfully
    }

    // Place a bid on the auction
    function placeBid(address bidder)
        external
        payable
        onlyManager
        returns (bool)
    {
        uint256 bidAmount = msg.value;

        require(bidder != creator, "The auction creator can not place a bid"); // The auction creator can not place a bid
        require(
            getAuctionState() == AuctionState.OPEN,
            "can only place bid if the auction open"
        ); // The auction must be open

        require(
            bidAmount > startPrice,
            "the bid must be higher than the start price"
        ); // The bid must be higher than the starting price

        // this will executed if the bidder is the same max bidder as before
        if (bidder == maxBidder) {
            return handleSameMaxBidder(bidAmount);
        } else {
            return handleDifferentMaxBidder(bidder, bidAmount);
        }
    }

    // Withdraw the token after the auction is over
    function withdrawToken() external returns (bool) {
        require(
            getAuctionState() == AuctionState.ENDED ||
                getAuctionState() == AuctionState.DIRECT_BUY ||
                getAuctionState() == AuctionState.ENDED_BY_CREATOR,
            "The auction must be ended by either a direct buy or timeout"
        ); // The auction must be ended by either a direct buy or timeout

        require(
            msg.sender == maxBidder,
            " Only the highest bidder can  withdraw the token"
        );

        nft721.transferFrom(address(this), maxBidder, tokenId); // Transfer the token to the highest bidder
        emit WithdrawToken(maxBidder); // Emit a withdraw token event

        return true;
    }

    // Withdraw the funds after the auction is over
    function withdrawFunds() external returns (bool) {
        require(
            getAuctionState() == AuctionState.ENDED ||
                getAuctionState() == AuctionState.DIRECT_BUY ||
                getAuctionState() == AuctionState.ENDED_BY_CREATOR,
            "The auction must be ended by either a direct buy, by creator, or timeout"
        );

        require(
            msg.sender == creator,
            "The auction creator can only withdraw the funds"
        );

        uint256 _maxBid = maxBid; // maxbid stack cache

        uint256 principal = _calculatePrincipal(_maxBid);
        uint256 fee = _calculateFee(principal);
        uint256 reward = _calculateReward(_maxBid, fee);

        // TODO : transfer funds to the creator  transfer(nftSeller, reward); // Transfers funds to the creator
        // TODO : transfer fee to baliola transfer(baliolaWallet, fee);

        emit WithdrawFunds(nftSeller, _maxBid); // Emit a withdraw funds event

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
}
