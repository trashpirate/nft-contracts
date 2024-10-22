// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/**
 *  @title Pausable
 *  @notice This contract provides a mechanism to pause and unpause the contract.
 *  @dev Adapted from Openzeppelin's Pausable contract.
 */
abstract contract Pausable {
    /*//////////////////////////////////////////////////////////////
                           STORAGE VARIABLES
    //////////////////////////////////////////////////////////////*/
    bool private s_paused;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event Paused(address indexed sender);
    event Unpaused(address indexed sender);

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error Pausable_ContractIsPaused();
    error Pausable_ContractIsUnpaused();

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /// @dev Function is only callable when the contract is not paused.
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /// @dev Function is only callable when the contract is paused.
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @dev Initializes the contract in paused state.
    constructor() {
        s_paused = true;
    }

    /// @dev Throws if the contract is paused.
    function _requirePaused() internal view {
        if (!s_paused) revert Pausable_ContractIsUnpaused();
    }

    /// @dev Throws if the contract is not paused.
    function _requireNotPaused() internal view {
        if (s_paused) revert Pausable_ContractIsPaused();
    }

    /// @dev Pause contract
    function _pause() internal whenNotPaused {
        s_paused = true;
        emit Paused(msg.sender);
    }

    /// @dev Unpause contract
    function _unpause() internal whenPaused {
        s_paused = false;
        emit Unpaused(msg.sender);
    }

    /// @dev Returns whether contract is paused
    function isPaused() external view returns (bool) {
        return s_paused;
    }
}
