// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./Auction721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract AuctionManager721 {
    address baliola;
    address manager;

    event NewAuction(
        address indexed auctionAddress,
        address indexed seller,
        address indexed nft
    );

    modifier onlyManager() {
        require(msg.sender == manager, "only manager can call this function");
        _;
    }

    constructor(address _baliola, address _manager) {
        baliola = _baliola;
        manager = _manager;
    }

    function changeManager(address newManager)
        external
        onlyManager
        returns (bool)
    {
        manager = newManager;

        return true;
    }

    function changeBaliolaWallet(address newBaliolaWallet)
        external
        onlyManager
        returns (bool)
    {
        baliola = newBaliolaWallet;

        return true;
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }

    // create an auction
    function createAuction(
        uint256 _endTime,
        bool _directBuyAuction,
        uint256 _directBuyPrice,
        uint256 _startPrice,
        address _nftAddress,
        uint256 _tokenId
    ) external returns (address) {
        if (_directBuyAuction) {
            require(
                _directBuyPrice > 0,
                "direct buy price must be greater than 0"
            ); // direct buy price must be greater than 0
            require(
                _startPrice < _directBuyPrice,
                "start price must be less than the direct buy price"
            ); // start price must be less than the direct buy price
        }

        if (_endTime != 0) {
            require(
                _endTime > (block.timestamp + 12 hours),
                "must be greater than 12 hours"
            );
        }

        Auction721 auction = new Auction721(
            payable(msg.sender),
            _endTime,
            payable(baliola),
            _directBuyAuction,
            _directBuyPrice,
            _startPrice,
            _nftAddress,
            _tokenId
        );
        IERC721 _nftToken = IERC721(_nftAddress); // get the nft token
        _nftToken.transferFrom(msg.sender, address(auction), _tokenId); // transfer the token to the auction

        emit NewAuction(address(auction), msg.sender, _nftAddress);
        return address(auction);
    }

    /// @dev Default payable function to not allow sending to contract
    ///  Remember this does not necessarily prevent the contract
    ///  from accumulating funds.
    fallback() external payable {
        revert();
    }
}
