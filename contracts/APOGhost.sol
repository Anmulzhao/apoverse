// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title APOGhost
 * @dev Pixel art NFT creatures - summon, feed, and evolve your ghosts
 */
contract APOGhost is ERC721 {
    uint256 private _nextTokenId;
    
    // Ghost metadata
    struct Ghost {
        string name;
        uint8 level;
        uint16 experience;
        uint8 hunger;
        bool active;
    }
    
    mapping(uint256 => Ghost) public ghosts;
    
    event GhostSummoned(uint256 indexed tokenId, address indexed owner, string name);
    event GhostFed(uint256 indexed tokenId, uint8 newHunger);
    event GhostEvolved(uint256 indexed tokenId, uint8 newLevel);
    
    constructor() ERC721("APOVerse Ghosts", "APOG") {}
    
    function summon(string memory _name) public returns (uint256) {
        uint256 tokenId = _nextTokenId++;
        _mint(msg.sender, tokenId);
        
        ghosts[tokenId] = Ghost({
            name: _name,
            level: 1,
            experience: 0,
            hunger: 100,
            active: true
        });
        
        emit GhostSummoned(tokenId, msg.sender, _name);
        return tokenId;
    }
    
    function feed(uint256 _tokenId) public {
        require(ownerOf(_tokenId) == msg.sender, "Not your ghost");
        require(ghosts[_tokenId].active, "Ghost is dead");
        
        Ghost storage g = ghosts[_tokenId];
        g.hunger = 100;
        g.experience += 10;
        
        if(g.experience >= g.level * 100 && g.level < 100) {
            g.level++;
            emit GhostEvolved(_tokenId, g.level);
        }
        
        emit GhostFed(_tokenId, g.hunger);
    }
    
    function getGhostStats(uint256 _tokenId) public view returns (Ghost memory) {
        return ghosts[_tokenId];
    }
    
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        Ghost memory g = ghosts[_tokenId];
        return string(abi.encodePacked(
            "data:application/json;utf8,{\"name\":\"",
            g.name,
            "\",\"level\":",
            _uint2str(g.level),
            ",\"experience\":",
            _uint2str(g.experience),
            ",\"hunger\":",
            _uint2str(g.hunger),
            "}"
        ));
    }
    
    function _uint2str(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits--;
            buffer[digits] = bytes1(uint8(48 + value % 10));
            value /= 10;
        }
        return string(buffer);
    }
}