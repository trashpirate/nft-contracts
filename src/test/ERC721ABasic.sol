// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC721ACore} from "src/ERC721ACore.sol";

/// @title ERC721ABasic
/// @author Nadina Oates
/// @notice Contract implementing ERC721A standard with only core functions

contract ERC721ABasic is ERC721ACore {
    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Constructor
    constructor(ERC721ACore.CoreConfig memory coreConfig) ERC721ACore(coreConfig) {}

    /*//////////////////////////////////////////////////////////////
                           EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Mints NFT
    /// @param quantity number of NFTs to mint
    /// TODO: this needs to be implemented as abstract contract otherwise different function signatures may cause issues
    function mint(uint256 quantity) public payable virtual validQuantity(quantity) {
        _safeMint(msg.sender, quantity);
    }
}
