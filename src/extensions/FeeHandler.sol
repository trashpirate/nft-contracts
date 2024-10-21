// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC721A, IERC721A} from "@erc721a/contracts/ERC721A.sol";

/**
 *  @title FeeHandler
 *  @notice This contract provides a mechanism to charge fees for minting NFTs.
 */
abstract contract FeeHandler {
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
                           STORAGE VARIABLES
    //////////////////////////////////////////////////////////////*/
    IERC20 private immutable i_feeToken;

    address private s_feeAddress;
    uint256 private s_tokenFee;
    uint256 private s_relativeTokenFee;
    uint256 private s_ethFee;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event TokenFeeSet(address indexed sender, uint256 indexed fee);
    event EthFeeSet(address indexed sender, uint256 indexed fee);
    event FeeAddressSet(address indexed sender, address indexed feeAddress);

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error FeeHandler_FeeAddressIsZeroAddress();
    error FeeHandler_InsufficientEthFee(uint256 value, uint256 fee);
    error FeeHandler_EthTransferFailed();

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    constructor(address feeToken, address feeAddress, uint256 tokenFee, uint256 ethFee) {
        if (feeAddress == address(0)) {
            revert FeeHandler_FeeAddressIsZeroAddress();
        }

        i_feeToken = IERC20(feeToken);
        s_feeAddress = feeAddress;
        s_tokenFee = tokenFee;
        s_relativeTokenFee = 10;
        s_ethFee = ethFee;
    }

    receive() external payable {}

    /*//////////////////////////////////////////////////////////////
                           INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Charges the minting fee in tokens
    /// @param tokenFee Fee in tokens
    function _chargeTokenFee(uint256 tokenFee) internal {
        if (tokenFee > 0) {
            i_feeToken.safeTransferFrom(msg.sender, s_feeAddress, tokenFee);
        }
    }

    /// @notice Charges the minting fee in ETH
    /// @param ethFee Fee in ETH
    function _chargeEthFee(uint256 ethFee) internal {
        if (ethFee > 0) {
            if (msg.value < ethFee) {
                revert FeeHandler_InsufficientEthFee(msg.value, ethFee);
            }
            (bool success,) = payable(s_feeAddress).call{value: ethFee}("");
            if (!success) revert FeeHandler_EthTransferFailed();
        }
    }

    // @notice Sets minting fee in ETH
    /// @param fee New fee in ETH
    function _setEthFee(uint256 fee) internal {
        s_ethFee = fee;
        emit EthFeeSet(msg.sender, fee);
    }

    /// @notice Sets minting fee in ERC20
    /// @param fee New fee in ERC20
    function _setTokenFee(uint256 fee) internal {
        s_tokenFee = fee;
        emit TokenFeeSet(msg.sender, fee);
    }

    /// @notice Sets the receiver address for the token/ETH fee
    /// @param feeAddress New receiver address for tokens and ETH received through minting
    function _setFeeAddress(address feeAddress) internal {
        if (feeAddress == address(0)) {
            revert FeeHandler_FeeAddressIsZeroAddress();
        }
        s_feeAddress = feeAddress;
        emit FeeAddressSet(msg.sender, feeAddress);
    }

    /*//////////////////////////////////////////////////////////////
                                GETTERS
    //////////////////////////////////////////////////////////////*/

    /// @notice Returns minting fee in ETH
    function getEthFee() public view returns (uint256) {
        return s_ethFee;
    }

    /// @notice Returns minting fee in ERC20
    function getTokenFee() public view returns (uint256) {
        return s_tokenFee;
    }

    /// @notice Returns fee token address
    function getFeeToken() public view returns (address) {
        return address(i_feeToken);
    }

    /// @notice Returns address that receives minting fees
    function getFeeAddress() public view returns (address) {
        return s_feeAddress;
    }
}
