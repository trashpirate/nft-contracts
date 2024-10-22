// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC2981} from "@openzeppelin/contracts/token/common/ERC2981.sol";

import {ERC721A, IERC721A} from "@erc721a/contracts/ERC721A.sol";
import {ERC721ABurnable} from "@erc721a/contracts/extensions/ERC721ABurnable.sol";

/// @title ERC721ACore
/// @author Nadina Oates
/// @notice Contract implementing ERC721A standard using ERC20 token and/or ETH for minting
/// @dev Inherits from ERC721A and ERC721ABurnable and openzeppelin Ownable

contract ERC721ACore is ERC721A, ERC2981, ERC721ABurnable, Ownable {
    /*//////////////////////////////////////////////////////////////
                                 TYPES
    //////////////////////////////////////////////////////////////*/

    struct CoreConfig {
        string name;
        string symbol;
        string baseURI;
        string contractURI;
        address owner;
        uint256 maxSupply;
        uint256 maxWalletSize;
        uint256 batchLimit;
        uint96 royaltyNumerator;
    }

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    uint256 private immutable i_maxSupply;

    uint256 private s_batchLimit;
    uint256 private s_maxWalletSize;

    string private s_baseURI;
    string private s_contractURI;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event BatchLimitSet(address indexed sender, uint256 batchLimit);
    event MaxWalletSizeSet(address indexed sender, uint256 maxWalletSize);
    event BaseURIUpdated(address indexed sender, string indexed baseUri);
    event ContractURIUpdated(address indexed sender, string indexed contractUri);
    event RoyaltyUpdated(address indexed feeAddress, uint96 indexed royaltyNumerator);

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error ERC721ACore_InsufficientMintQuantity();
    error ERC721ACore_ExceedsMaxSupply();
    error ERC721ACore_ExceedsMaxPerWallet();
    error ERC721ACore_ExceedsBatchLimit();
    error ERC721ACore_TokenTransferFailed();
    error ERC721ACore_EthTransferFailed();
    error ERC721ACore_BatchLimitTooHigh();
    error ERC721ACore_NoBaseURI();

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier validQuantity(uint256 quantity) {
        if (quantity == 0) revert ERC721ACore_InsufficientMintQuantity();
        if (quantity > s_batchLimit) revert ERC721ACore_ExceedsBatchLimit();
        if (s_maxWalletSize > 0 && quantity > s_maxWalletSize) revert ERC721ACore_ExceedsMaxPerWallet();
        if (totalSupply() + quantity > i_maxSupply) {
            revert ERC721ACore_ExceedsMaxSupply();
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Constructor

    ///                     name: collection name
    ///                     symbol: nft symbol
    ///                     owner: contract owner
    ///                     ethFee: minting fee in native coin
    ///                     token: minting fee in erc20
    ///                     tokenAddress: erc20 token address used for fees
    ///                     feeAddress: address for fees
    ///                     baseURI: base uri
    ///                     contractURI: contract uri
    ///                     maxSupply: maximum nfts mintable
    constructor(CoreConfig memory config) ERC721A(config.name, config.symbol) Ownable(msg.sender) {
        if (bytes(config.baseURI).length == 0) revert ERC721ACore_NoBaseURI();

        i_maxSupply = config.maxSupply;

        s_batchLimit = config.batchLimit;
        s_maxWalletSize = config.maxWalletSize;

        // initialize metadata
        _setBaseURI(config.baseURI);
        _setContractURI(config.contractURI);
        _setDefaultRoyalty(config.owner, config.royaltyNumerator); // 5% = 500

        // set ownership
        if (config.owner != msg.sender) _transferOwnership(config.owner);
    }

    /*//////////////////////////////////////////////////////////////
                           EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Mints NFT
    /// @param quantity number of NFTs to mint
    function mint(uint256 quantity) public payable virtual validQuantity(quantity) {
        // _safeMint(msg.sender, quantity);
    }

    /// @notice Sets batch limit - maximum number of nfts that can be minted at once (only owner)
    /// @param batchLimit Maximum number of nfts that can be minted at once
    function setBatchLimit(uint256 batchLimit) external onlyOwner {
        if (batchLimit > 100) revert ERC721ACore_BatchLimitTooHigh();
        s_batchLimit = batchLimit;
        emit BatchLimitSet(msg.sender, batchLimit);
    }

    /// @notice Sets max wallet size - maximum number of nfts that can be minted per wallet (only owner)
    /// @param maxWalletSize Maximum number of nfts that can be minted per wallet
    function setMaxWalletSize(uint256 maxWalletSize) external onlyOwner {
        s_maxWalletSize = maxWalletSize;
        emit MaxWalletSizeSet(msg.sender, maxWalletSize);
    }

    /// @notice Withdraw tokens from contract (only owner)
    /// @param tokenAddress Contract address of token to be withdrawn
    /// @param receiverAddress Tokens are withdrawn to this address
    /// @return success of withdrawal
    function withdrawTokens(address tokenAddress, address receiverAddress) external onlyOwner returns (bool success) {
        IERC20 tokenContract = IERC20(tokenAddress);
        uint256 amount = tokenContract.balanceOf(address(this));
        success = tokenContract.transfer(receiverAddress, amount);
        if (!success) revert ERC721ACore_TokenTransferFailed();
    }

    /// @notice Withdraw ETH from contract (only owner)
    /// @param receiverAddress ETH withdrawn to this address
    /// @return success of withdrawal
    function withdrawETH(address receiverAddress) external onlyOwner returns (bool success) {
        uint256 amount = address(this).balance;
        (success,) = payable(receiverAddress).call{value: amount}("");
        if (!success) revert ERC721ACore_EthTransferFailed();
    }

    /// @notice Sets base Uri
    /// @param baseURI base uri
    function setBaseURI(string memory baseURI) external onlyOwner {
        _setBaseURI(baseURI);
    }

    /// @notice Sets contract uri
    /// @param _contractURI contract uri for contract metadata
    function setContractURI(string memory _contractURI) external onlyOwner {
        _setContractURI(_contractURI);
    }

    /// @notice Sets royalty
    /// @param feeAddress address receiving royalties
    /// @param royaltyNumerator numerator to calculate fees (denominator is 10000)
    function setRoyalty(address feeAddress, uint96 royaltyNumerator) external onlyOwner {
        _setDefaultRoyalty(feeAddress, royaltyNumerator);
        emit RoyaltyUpdated(feeAddress, royaltyNumerator);
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice retrieves contractURI
    function contractURI() public view returns (string memory) {
        return s_contractURI;
    }

    /// @notice retrieves tokenURI
    /// @dev override required by ERC721A
    function tokenURI(uint256 tokenId) public view virtual override(ERC721A, IERC721A) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    /// @notice checks for supported interface
    /// @dev function override required by ERC721
    /// @param interfaceId interfaceId to be checked
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721A, IERC721A, ERC2981)
        returns (bool)
    {
        return ERC721A.supportsInterface(interfaceId) || ERC2981.supportsInterface(interfaceId);
    }

    /*//////////////////////////////////////////////////////////////
                           INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Retrieves base uri
    function _baseURI() internal view virtual override returns (string memory) {
        return s_baseURI;
    }

    /// @notice sets first tokenId to 1
    /// @dev override required by ERC721A
    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    /*//////////////////////////////////////////////////////////////
                           PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Sets base uri
    /// @param baseURI base uri for NFT metadata
    function _setBaseURI(string memory baseURI) private {
        s_baseURI = baseURI;
        emit BaseURIUpdated(msg.sender, baseURI);
    }

    /// @notice Sets contract uri
    /// @param _contractURI contract uri for contract metadata
    function _setContractURI(string memory _contractURI) private {
        s_contractURI = _contractURI;
        emit ContractURIUpdated(msg.sender, _contractURI);
    }

    /*//////////////////////////////////////////////////////////////
                                GETTERS
    //////////////////////////////////////////////////////////////*/

    /// @notice Returns maximum supply
    function getMaxSupply() external view returns (uint256) {
        return i_maxSupply;
    }

    /// @notice Returns base uri
    function getBaseURI() external view returns (string memory) {
        return _baseURI();
    }

    /// @notice Returns contract uri
    function getContractURI() external view returns (string memory) {
        return s_contractURI;
    }

    /// @notice Returns number of nfts allowed minted at once
    function getBatchLimit() external view returns (uint256) {
        return s_batchLimit;
    }

    /// @notice Returns number of nfts allowed per wallet
    function getMaxWalletSize() external view returns (uint256) {
        return s_maxWalletSize;
    }
}
