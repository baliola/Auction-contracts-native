// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Dummy1155 is
    ERC1155,
    AccessControl,
    Pausable,
    ERC1155Burnable,
    ERC1155Supply
{
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    using Counters for Counters.Counter;
    using Strings for uint256;
    Counters.Counter private _tokenIdCounter;
    mapping(uint256 => address) private _owners;
    mapping(uint256 => string) private _tokenURIs;
    string public name;

    constructor(string memory _contractName) ERC1155("") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(URI_SETTER_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);

        name = _contractName;
    }

    // function setContractName(string memory _name) public onlyRole(URI_SETTER_ROLE) {
    //    name = _name;
    // }

    function setURI(string memory newuri) public onlyRole(URI_SETTER_ROLE) {
        _setURI(newuri);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    event MintedId(uint256 id);

    function mint(
        address account,
        uint256 amount,
        /* string memory uri,*/
        bytes memory data
    ) public {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _mint(account, tokenId, amount, data);
        _owners[tokenId] = account;
        //_setTokenURI(tokenId, uri);
        emit MintedId(tokenId);
    }

    function mintBatch(
        address to,
        uint256 countOfNFTs,
        uint256[] memory amounts,
        /* string[] memory uri,*/
        bytes memory data
    )
        public
        returns (
            uint256[] memory //onlyRole(MINTER_ROLE)
        )
    {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "Must have minter role to mint"
        );

        uint256[] memory ids = new uint256[](countOfNFTs);
        for (uint256 i = 0; i < countOfNFTs; i++) {
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            ids[i] = tokenId;
            _owners[tokenId] = to;
            //_setTokenURI(tokenId, uri[i]);
        }

        _mintBatch(to, ids, amounts, data);
        return ids;
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) whenNotPaused {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // ================================ CUSTOME URI ================================
    //==============================================================================

    // function _exists(uint256 tokenId) internal view virtual returns (bool) {
    //     return _owners[tokenId] != address(0);
    // }

    // function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
    //     require(_exists(tokenId), "URI Storage: URI set of nonexistent token");
    //     _tokenURIs[tokenId] = _tokenURI;
    //      emit URI(_tokenURI, tokenId);
    // }

    // function setTokenURI(uint256 tokenId, string memory URI) public virtual{
    //     require(hasRole(URI_SETTER_ROLE, _msgSender()), "Must have URI setter role to mint");
    //     _setTokenURI(tokenId, URI);
    // }

    //function tokenURI(uint256 tokenId) public view virtual returns (string memory) {
    //require(_exists(tokenId), "URI Storage: URI query for nonexistent token");

    //string memory _tokenURI = _tokenURIs[tokenId];
    //string memory base = _baseURI();

    // If there is no base URI, return the token URI.
    // if (bytes(base).length == 0) {
    //     return _tokenURI;
    // }

    // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
    // if (bytes(_tokenURI).length > 0) {
    //     return string(abi.encodePacked(base, _tokenURI));
    // }

    //return super.tokenURI(tokenId);
    //return _tokenURI;
    //}

    function getCurrentTokenId() public view virtual returns (uint256) {
        return _tokenIdCounter.current();
    }
}
