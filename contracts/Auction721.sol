// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Auction721 {
    using SafeMath for uint256;
    uint256 public endTime; // Timestamp of the end of the auction (in seconds)
    uint256 public startTime; // The block timestamp which marks the start of the auction
    uint256 public maxBid; // The maximum bid
    address payable public maxBidder; // The address of the maximum bidder
    address payable public creator; // The address of the auction creator
    address payable public nftSeller; // the address of the nft seller
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

    constructor(
        address payable _creator,
        uint256 _endTime,
        address payable _baliola,
        bool _directBuyStatus,
        uint256 _directBuyPrice,
        uint256 _startPrice,
        address _nftAddress,
        uint256 _tokenId,
        address payable _nftSeller
    ) {
        creator = _creator;
        if (_endTime == 0) {
            endTime = 0;
        } else {
            endTime = _endTime;
        }
        startTime = block.timestamp;
        minIncrement = 1e17; // 0.1 native currency
        directBuyStatus = _directBuyStatus;
        directBuyPrice = _directBuyPrice;
        startPrice = _startPrice;
        nft721 = IERC721(_nftAddress);
        nftAddress = _nftAddress;
        tokenId = _tokenId;
        maxBidder = _creator;
        nftSeller = _nftSeller;
        manager = msg.sender;
        baliolaWallet = _baliola;
    }

    function handleSameMaxBidder(uint256 bidAmount) private returns (bool) {
        require(
            bidAmount > minIncrement,
            "the bid must be higher than the minimum increment"
        );

        maxBid = maxBid + bidAmount;

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

    function placeBid(address payable bidder)
        external
        payable
        onlyManager
        returns (bool)
    {
        uint256 bidAmount = msg.value;

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

    function withdrawToken() external returns (bool) {
        address _maxBidder = maxBidder; // max bidder cache

        require(
            getAuctionState() == AuctionState.ENDED ||
                getAuctionState() == AuctionState.DIRECT_BUY ||
                getAuctionState() == AuctionState.ENDED_BY_CREATOR,
            "The auction must be ended by either a direct buy or timeout"
        );

        require(
            msg.sender == _maxBidder,
            " Only the highest bidder can  withdraw the token"
        );

        nft721.transferFrom(address(this), _maxBidder, tokenId);
        emit WithdrawToken(_maxBidder);

        return true;
    }

    function withdrawFunds() external returns (bool) {
        address payable _creator = creator; // creator stack cache
        uint256 _maxBid = maxBid; // maxbid stack cache
        address payable _nftSeller = nftSeller; // nftSeller stack cache

        require(
            getAuctionState() == AuctionState.ENDED ||
                getAuctionState() == AuctionState.DIRECT_BUY ||
                getAuctionState() == AuctionState.ENDED_BY_CREATOR,
            "The auction must be ended by either a direct buy, by creator, or timeout"
        );

        require(
            msg.sender == _creator,
            "The auction creator can only withdraw the funds"
        );

        uint256 principal = _calculatePrincipal(_maxBid);
        uint256 fee = _calculateFee(principal);
        uint256 reward = _calculateReward(_maxBid, fee);

        _nftSeller.transfer(reward);
        baliolaWallet.transfer(fee);

        emit WithdrawFunds(_nftSeller, _maxBid);

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
