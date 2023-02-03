// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./Auction1155.sol";
import "./@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "./@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract AuctionManager1155 is ERC1155Holder {
    address baliola;
    address manager;

    event NewAuction(
        address indexed auctionAddress,
        address indexed seller,
        address indexed nft,
        uint256 amount
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

    function createTimeAuction(
        uint256 _endTime,
        uint256 _startPrice,
        address _nftAddress,
        uint256 _tokenId,
        uint256 _nftAmount
    ) external returns (address) {
        bool _directBuyStatus = false;
        uint256 _directBuyPrice = 0;

        require(
            _endTime > (block.timestamp + 12 hours),
            "must be greater than 12 hours"
        );

        Auction1155 auction = new Auction1155(
            payable(msg.sender),
            _endTime,
            payable(baliola),
            _directBuyStatus,
            _directBuyPrice,
            _startPrice,
            _nftAddress,
            _tokenId,
            _nftAmount
        );
        IERC1155 _nftToken = IERC1155(_nftAddress); // get the nft token
        _nftToken.safeTransferFrom(
            msg.sender,
            address(auction),
            _tokenId,
            _nftAmount,
            ""
        );
        emit NewAuction(address(auction), msg.sender, _nftAddress, _nftAmount);

        return address(auction);
    }

    function createOpenBidAuction(
        uint256 _startPrice,
        address _nftAddress,
        uint256 _tokenId,
        uint256 _nftAmount
    ) external returns (address) {
        uint256 _endTime = 0;
        bool _directBuyStatus = false;
        uint256 _directBuyPrice = 0;

        Auction1155 auction = new Auction1155(
            payable(msg.sender),
            _endTime,
            payable(baliola),
            _directBuyStatus,
            _directBuyPrice,
            _startPrice,
            _nftAddress,
            _tokenId,
            _nftAmount
        );
        IERC1155 _nftToken = IERC1155(_nftAddress); // get the nft token
        _nftToken.safeTransferFrom(
            msg.sender,
            address(auction),
            _tokenId,
            _nftAmount,
            ""
        );
        emit NewAuction(address(auction), msg.sender, _nftAddress, _nftAmount);

        return address(auction);
    }

    /// @dev Default payable function to not allow sending to contract
    ///  Remember this does not necessarily prevent the contract
    ///  from accumulating funds.
    fallback() external payable {
        revert();
    }
}
