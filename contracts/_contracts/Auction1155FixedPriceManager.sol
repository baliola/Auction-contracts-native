// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./Auction1155FixedPrice.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract FixedPriceAuctionManager1155 is ERC1155Holder {
    uint256 _auctionIdCounter = 1; // auction Id counter
    address baliola;
    address manager;

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

    // create an auction
    function createAuction(
        uint256 price,
        address _nftAddress,
        uint256 _tokenId,
        uint256 _nftAmount
    ) external returns (address) {
        AuctionFixedPrice1155 auction = new AuctionFixedPrice1155(
            payable(msg.sender),
            payable(baliola),
            _nftAddress,
            _tokenId,
            _nftAmount,
            price
        ); // create the auction

        IERC1155 _nftToken = IERC1155(_nftAddress); // get the nft token

        _nftToken.safeTransferFrom(
            address(this),
            address(auction),
            _tokenId,
            _nftAmount,
            ""
        ); // transfer the token to the auction

        return address(auction);
    }

    /// @dev Default payable function to not allow sending to contract
    ///  Remember this does not necessarily prevent the contract
    ///  from accumulating funds.
    fallback() external payable {
        revert();
    }
}
