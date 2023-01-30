// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract AuctionFixedPrice1155 is ERC1155Holder {
    address payable public creator; // The address of the auction creator
    uint256 public tokenId; // The id of the token
    bool public isEnded; // If the the auction is cancelled
    address public nftAddress; // The address of the NFT contract
    IERC1155 nft1155; // The NFT token
    bool public isEndedByCreator;
    address payable public baliolaWallet;
    uint256 public initialNftAmount; // initial amount of nft
    uint256 public availableNFT; // total of available nft
    uint256 public price; // the price per 1 nft

    enum AuctionState {
        OPEN,
        ENDED_BY_CREATOR,
        OUT_OF_SUPPLY
    }

    event AuctionEnded();
    event OutOfSupply();
    event hasBought(address indexed buyer, uint256 amount);
    event Refilled(uint256 amount);

    function getAuctionState() public view returns (AuctionState) {
        if (availableNFT == 0) return AuctionState.OUT_OF_SUPPLY;
        if (isEnded) return AuctionState.ENDED_BY_CREATOR;
        return AuctionState.OPEN;
    }

    constructor(
        address payable _creator,
        address payable _baliola,
        address _nftAddress,
        uint256 _tokenId,
        uint256 _nftAmount,
        uint256 _price
    ) {
        creator = _creator;
        nft1155 = IERC1155(_nftAddress);
        nftAddress = _nftAddress;
        tokenId = _tokenId;
        baliolaWallet = _baliola;
        initialNftAmount = _nftAmount;
        availableNFT = _nftAmount;
        price = _price;
    }

    function refill(uint256 amount) external returns (bool) {
        address _creator = msg.sender;
        require(
            getAuctionState() == AuctionState.OPEN,
            "can only refill when auction is still open"
        );

        require(_creator == creator, "only creator can refill");
        availableNFT = availableNFT + amount;

        emit Refilled(amount);

        return true;
    }

    function buy(uint256 _amount) external payable returns (bool) {
        uint256 txFee = msg.value;
        address _buyer = msg.sender;
        address payable _creator = creator;

        require(_buyer != _creator, "creator cannot buy nft!");
        require(availableNFT != 0, "out of supply! no nft is being selled!");
        require(_amount <= availableNFT, "not enough available nft!");
        require(
            getAuctionState() == AuctionState.OPEN,
            "can only buy nft when auction is open!"
        );
        require(
            txFee == price * _amount,
            "can only buy if the fee is correct!"
        );

        availableNFT = availableNFT - _amount;

        nft1155.safeTransferFrom(address(this), _buyer, tokenId, _amount, "");
        _creator.transfer(txFee);

        emit hasBought(_buyer, _amount);

        if (availableNFT == 0) {
            emit OutOfSupply();
        }

        return true;
    }

    function EndAuction() external returns (bool) {
        require(
            msg.sender == creator,
            "Only the auction creator can end the auction"
        );
        require(
            getAuctionState() == AuctionState.OPEN,
            "can only end auction if the auction is open"
        );
        isEnded = true;
        nft1155.safeTransferFrom(
            address(this),
            creator,
            tokenId,
            availableNFT,
            ""
        );
        availableNFT = 0;
        emit AuctionEnded();
        return true;
    }

    /// @dev Default payable function to not allow sending to contract
    ///  Remember this does not necessarily prevent the contract
    ///  from accumulating funds.
    fallback() external payable {
        revert();
    }
}
