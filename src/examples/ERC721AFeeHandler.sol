// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {FeeHandler} from "src/extensions/FeeHandler.sol";
import {ERC721ACore} from "src/ERC721ACore.sol";

/// @title NFTFeeHandler
/// @author Nadina Oates
/// @notice Contract implementing ERC721A standard with token and eth fee extension

contract ERC721AFeeHandler is ERC721ACore, FeeHandler {
    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Constructor
    constructor(
        ERC721ACore.CoreConfig memory coreConfig,
        address feeAddress,
        address tokenAddress,
        uint256 tokenFee,
        uint256 ethFee
    ) ERC721ACore(coreConfig) FeeHandler(tokenAddress, feeAddress, tokenFee, ethFee) {}

    /*//////////////////////////////////////////////////////////////
                           EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Mints NFT for a eth and a token fee
    /// @param quantity number of NFTs to mint
    function mint(uint256 quantity) external payable override validQuantity(quantity) {
        _safeMint(msg.sender, quantity);

        uint256 ethFee = getEthFee() * quantity;
        uint256 tokenFee = getTokenFee() * quantity;

        _chargeEthFee(ethFee);
        _chargeTokenFee(tokenFee);
    }

    /// @notice Sets minting fee in ETH (only owner)
    /// @param fee New fee in ETH
    function setEthFee(uint256 fee) external onlyOwner {
        _setEthFee(fee);
    }

    /// @notice Sets minting fee in ERC20 (only owner)
    /// @param fee New fee in ERC20
    function setTokenFee(uint256 fee) external onlyOwner {
        _setTokenFee(fee);
    }

    /// @notice Sets the receiver address for the token/ETH fee (only owner)
    /// @param feeAddress New receiver address for tokens and ETH received through minting
    function setFeeAddress(address feeAddress) external onlyOwner {
        _setFeeAddress(feeAddress);
    }
}
