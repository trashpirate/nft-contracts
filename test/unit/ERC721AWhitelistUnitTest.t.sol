// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";

import {DeployERC721AWhitelist} from "script/deployment/DeployERC721AWhitelist.s.sol";
import {ERC721AWhitelist} from "src/test/ERC721AWhitelist.sol";
import {Whitelist} from "src/extensions/Whitelist.sol";
import {HelperConfig} from "script/helpers/HelperConfig.s.sol";

contract ERC721AWhitelistUnitTest is Test {
    /*//////////////////////////////////////////////////////////////
                             CONFIGURATION
    //////////////////////////////////////////////////////////////*/
    DeployERC721AWhitelist deployer;
    HelperConfig helperConfig;
    HelperConfig.NetworkConfig networkConfig;

    /*//////////////////////////////////////////////////////////////
                               CONTRACTS
    //////////////////////////////////////////////////////////////*/
    ERC721AWhitelist nftContract;

    /*//////////////////////////////////////////////////////////////
                                HELPERS
    //////////////////////////////////////////////////////////////*/
    address USER = makeAddr("regular-user");

    // for testing add address to whitelist.csv in ../utils/merkle-tree-generator
    address VALID_USER;
    uint256 VALID_USER_KEY;

    // get merkle root by running the `generateTree.js` script in ../utils/merkle-tree-generator
    bytes32 MERKLE_ROOT = 0x7cfda1d6c2b32e261fbdf50526b103173ab06cb1879095dddc3d2c5feb96198a;
    bytes32 NEW_MERKLE_ROOT = 0xbac43dadde51c6caaf0ac2afedd5b01a2309d7949eb885502006523739248f9c;
    bytes32[] PROOF = [
        bytes32(0xfd28eb2cd1dab1d4e95dafc7b249eff8e75eabe37548efb05dada899264f25b4),
        0x603ab331089101552b9dde23779eab62af9b50242bdd77dd16f4dd86fe748129,
        0xf67ea6e5dd288a14836f06064b781d7e30ca3af8ea340931d7bde127af0a0757,
        0x77f4ff80b42f3ed7f596900be1a0e7a2abf1e01b26372fe2af0957c15c93d0ac,
        0x563314bbe031d9c0bcb7e68735ffe7d64b03eb46186064d3cbcab90aee1621f7
    ];
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event ClaimStatusSet(address indexed account, bool indexed claimed);
    event MerkleRootSet(address indexed account, bytes32 indexed merkleRoot);

    /*//////////////////////////////////////////////////////////////
                                 MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /*//////////////////////////////////////////////////////////////
                                 SETUP
    //////////////////////////////////////////////////////////////*/
    function setUp() external virtual {
        deployer = new DeployERC721AWhitelist();
        (nftContract, helperConfig) = deployer.run();

        networkConfig = helperConfig.getActiveNetworkConfigStruct();

        (VALID_USER, VALID_USER_KEY) = makeAddrAndKey("user");
    }

    /*//////////////////////////////////////////////////////////////
                          GET VALID USER ADDRESS
    //////////////////////////////////////////////////////////////*/
    function test__ERC721AWhitelist__GetValidUserAddress() external view {
        console.log("VALID_USER: ", VALID_USER);
        console.log("VALID_USER_KEY: ", VALID_USER_KEY);
    }

    /*//////////////////////////////////////////////////////////////
                             INITIALIZATION
    //////////////////////////////////////////////////////////////*/
    function test__ERC721AWhitelist__Initialization() external view {
        assertEq(nftContract.getMerkleRoot(), networkConfig.args.merkleRoot);
        assertEq(nftContract.hasClaimed(VALID_USER), false);
    }

    /*//////////////////////////////////////////////////////////////
                            SET MERKLE ROOT
    //////////////////////////////////////////////////////////////*/
    function test__ERC721AWhitelist__SetMerkleRoot() external {
        address owner = nftContract.owner();

        vm.prank(owner);
        nftContract.setMerkleRoot(NEW_MERKLE_ROOT);

        assertEq(nftContract.getMerkleRoot(), NEW_MERKLE_ROOT);
    }

    function test__ERC721AWhitelist__EmitEvent__SetMerkleRoot() public {
        address owner = nftContract.owner();

        vm.expectEmit(true, true, true, true);
        emit MerkleRootSet(owner, NEW_MERKLE_ROOT);

        vm.prank(owner);
        nftContract.setMerkleRoot(NEW_MERKLE_ROOT);
    }

    /*//////////////////////////////////////////////////////////////
                               TEST MINT
    //////////////////////////////////////////////////////////////*/

    /// SUCCESS
    //////////////////////////////////////////////////////////////*/
    function test__ERC721AWhitelist__Mint() external {
        uint256 balance = nftContract.balanceOf(VALID_USER);

        // mint
        vm.prank(VALID_USER);
        nftContract.mint(1, PROOF);

        assertEq(nftContract.balanceOf(VALID_USER), balance + 1);
    }

    /// EMIT EVENTS
    //////////////////////////////////////////////////////////////*/
    function test__ERC721AWhitelist__EmitEvent__ClaimStatusSet() external {
        vm.expectEmit(true, true, true, true);
        emit ClaimStatusSet(VALID_USER, true);

        // mint
        vm.prank(VALID_USER);
        nftContract.mint(1, PROOF);
    }

    /// REVERTS
    //////////////////////////////////////////////////////////////*/
    function test__ERC721AWhitelist__RevertsWhen__InvalidProof() external {
        vm.expectRevert(Whitelist.Whitelist__InvalidProof.selector);

        // mint
        vm.prank(USER);
        nftContract.mint(1, PROOF);
    }

    function test__ERC721AWhitelist__RevertsWhen__AlreadyClaimed() external {
        // mint
        vm.prank(VALID_USER);
        nftContract.mint(1, PROOF);

        vm.expectRevert(Whitelist.Whitelist__AlreadyClaimed.selector);

        // mint
        vm.prank(VALID_USER);
        nftContract.mint(1, PROOF);
    }

    /*//////////////////////////////////////////////////////////////
                           TEST CLAIM STATUS
    //////////////////////////////////////////////////////////////*/
    function test__ERC721AWhitelist__UpdatesClaimStatus() external {
        // mint
        vm.prank(VALID_USER);
        nftContract.mint(1, PROOF);

        assertEq(nftContract.hasClaimed(VALID_USER), true);
    }
}
