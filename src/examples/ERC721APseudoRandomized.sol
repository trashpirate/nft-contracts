// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {PseudoRandomized} from "src/extensions/PseudoRandomized.sol";
import {ERC721ACore, ERC721A} from "src/ERC721ACore.sol";

/// @title NFTPseudoRandomized
/// @author Nadina Oates
/// @notice Contract implementing ERC721A standard with pseudorandomized token uris

contract ERC721APseudoRandomized is ERC721ACore, PseudoRandomized {
    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Constructor
    constructor(ERC721ACore.CoreConfig memory coreConfig)
        ERC721ACore(coreConfig)
        PseudoRandomized(coreConfig.maxSupply)
    {}

    /*//////////////////////////////////////////////////////////////
                           EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Mints NFT for a eth and a token fee
    /// @param quantity number of NFTs to mint
    function mint(uint256 quantity) external payable override validQuantity(quantity) {
        _mintRandom(msg.sender, quantity);
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice retrieves tokenURI
    /// @dev override required by ERC721A
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override(ERC721ACore, PseudoRandomized)
        returns (string memory)
    {
        return PseudoRandomized.tokenURI(tokenId);
    }

    /// @notice checks for supported interface
    /// @dev function override required by ERC721A
    /// @param interfaceId interfaceId to be checked
    function supportsInterface(bytes4 interfaceId) public view override(ERC721A, ERC721ACore) returns (bool) {
        return ERC721ACore.supportsInterface(interfaceId);
    }

    /*//////////////////////////////////////////////////////////////
                           INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Retrieves base uri
    /// @dev override required by ERC721A
    function _baseURI() internal view override(ERC721A, ERC721ACore) returns (string memory) {
        return ERC721ACore._baseURI();
    }

    /// @notice sets first tokenId to 1
    /// @dev override required by ERC721A
    function _startTokenId() internal view override(ERC721ACore, PseudoRandomized) returns (uint256) {
        return PseudoRandomized._startTokenId();
    }
}
