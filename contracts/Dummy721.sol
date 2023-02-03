// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Dummy721 is ERC721 {
    uint256 _tokenCounter;
    mapping(uint256 => uint256) public itemValue;
    uint256 maxValue = 10000; // Max value of an item

    constructor() ERC721("Super NFT", "SPRNFT") {}

    /**
    Returns an random number
  */
    function random() private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.difficulty,
                        block.timestamp,
                        block.number
                    )
                )
            );
    }

    function myItems() external view returns (uint256[] memory items) {
        // Returns an array of items that the user owns
        items = new uint256[](balanceOf(msg.sender));
        uint256 _counter = 0;
        for (uint256 i = 1; i < _tokenCounter; i++) {
            // i = 1 because the token counter is increased before the id is assigned
            if (ownerOf(i) == msg.sender) {
                // if the user owns the item
                items[_counter] = i; // add the item to the array
                _counter++; // increase the counter
            }
        }
        return items;
    }

    function getItem() public payable returns (uint256) {
        require(msg.value == 0 ether); // 0.5 AVAX is the cost of an item
        uint256 newItemId = _tokenCounter; // Get the current counter value
        _tokenCounter++; // Increase the counter
        _mint(msg.sender, newItemId); // Mint the new item to the player
        itemValue[newItemId] = random() % maxValue; // Set the item value to a random number modulus used to make sure that the value isn't bigger than maxValue
        return newItemId; // Return the new item id
    }
}
