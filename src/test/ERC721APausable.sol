// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Pausable} from "src/utils/Pausable.sol";
import {ERC721ACore} from "src/ERC721ACore.sol";

/// @title NFTPausable
/// @author Nadina Oates
/// @notice Contract implementing ERC721A standard with pausable extension

contract ERC721APausable is ERC721ACore, Pausable {
    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Constructor
    constructor(ERC721ACore.CoreConfig memory coreConfig) ERC721ACore(coreConfig) {}

    /*//////////////////////////////////////////////////////////////
                           EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Mints NFT for a eth and a token fee
    /// @param quantity number of NFTs to mint
    function mint(uint256 quantity) external payable whenNotPaused validQuantity(quantity) {
        _safeMint(msg.sender, quantity);
    }

    /// @notice Pauses contract (only owner)
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice Unpauses contract (only owner)
    function unpause() external onlyOwner {
        _unpause();
    }
}
