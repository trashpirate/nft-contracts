// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/**
 *  @title Whitelist
 *  @notice This contract provides a mechanism to whitelist addresses for minting NFTs.
 */
abstract contract Whitelist {
    /*//////////////////////////////////////////////////////////////
                           STORAGE VARIABLES
    //////////////////////////////////////////////////////////////*/
    bytes32 private s_merkleRoot;

    mapping(address claimer => bool) private s_hasClaimed;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event ClaimStatusSet(address indexed account, bool indexed claimed);
    event MerkleRootSet(address indexed account, bytes32 indexed merkleRoot);

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error Whitelist__AlreadyClaimed();
    error Whitelist__InvalidProof();

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/
    modifier onlyNotClaimed(address account) {
        if (s_hasClaimed[account]) {
            revert Whitelist__AlreadyClaimed();
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    constructor(bytes32 merkleRoot) {
        _setMerkleRoot(merkleRoot);
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Returns the claim status of an account
    /// @param account Account to check
    function hasClaimed(address account) public view returns (bool) {
        return s_hasClaimed[account];
    }

    /*//////////////////////////////////////////////////////////////
                           INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Sets the merkle root
    /// @param merkleRoot New merkle root
    function _setMerkleRoot(bytes32 merkleRoot) internal {
        s_merkleRoot = merkleRoot;
        emit MerkleRootSet(msg.sender, merkleRoot);
    }

    /// @notice Verifies the claimer's address
    /// @param account Account to verify
    /// @param merkleProof Proof of the claimer's address
    function _verifyClaimer(address account, bytes32[] calldata merkleProof) internal view returns (bool) {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account))));
        return MerkleProof.verify(merkleProof, s_merkleRoot, leaf);
    }

    /// @notice Sets the claim status of an account
    /// @param account Account to set the claim status for
    /// @param claimed Claim status
    function _setClaimStatus(address account, bool claimed) internal {
        s_hasClaimed[account] = claimed;
        emit ClaimStatusSet(account, claimed);
    }

    /*//////////////////////////////////////////////////////////////
                                GETTERS
    //////////////////////////////////////////////////////////////*/

    /// @notice Returns the merkle root
    function getMerkleRoot() external view returns (bytes32) {
        return s_merkleRoot;
    }
}
