// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract TDReactiveNFT is ERC721URIStorage, Ownable {
    uint256 private tokenIdCounter = 1818;

    constructor() ERC721("TDReactive", "TDR") {}

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = ++tokenIdCounter;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}
