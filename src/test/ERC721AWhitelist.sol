// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Whitelist} from "src/extensions/Whitelist.sol";
import {ERC721ACore} from "src/ERC721ACore.sol";

/// @title ERC721AWhitelist
/// @author Nadina Oates
/// @notice Contract implementing ERC721A standard with Whitelist extension

contract ERC721AWhitelist is ERC721ACore, Whitelist {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    error ERC721AWhitelist__InvalidMinter();

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Constructor
    constructor(ERC721ACore.CoreConfig memory coreConfig, bytes32 merkleRoot_)
        ERC721ACore(coreConfig)
        Whitelist(merkleRoot_)
    {}

    /*//////////////////////////////////////////////////////////////
                           EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Mints NFT for a eth and a token fee
    /// @param quantity number of NFTs to mint
    function mint(uint256 quantity, bytes32[] calldata merkleProof)
        external
        validQuantity(quantity)
        onlyNotClaimed(msg.sender)
    {
        if (_verifyClaimer(msg.sender, merkleProof)) {
            _setClaimStatus(msg.sender, true);
            _safeMint(msg.sender, quantity);
        } else {
            revert Whitelist__InvalidProof();
        }
    }

    /// @notice Sets the merkle root
    /// @param merkleRoot New merkle root
    function setMerkleRoot(bytes32 merkleRoot) external onlyOwner {
        _setMerkleRoot(merkleRoot);
    }
}
