// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC721A} from "@erc721a/contracts/IERC721A.sol";

import {DeployERC721APausable} from "script/deployment/DeployERC721APausable.s.sol";
import {ERC721APausable} from "src/examples/ERC721APausable.sol";
import {Pausable} from "src/utils/Pausable.sol";
import {HelperConfig} from "script/helpers/HelperConfig.s.sol";

contract ERC721APausableUnitTest is Test {
    /*//////////////////////////////////////////////////////////////
                             CONFIGURATION
    //////////////////////////////////////////////////////////////*/
    DeployERC721APausable nftPausableDeployer;
    HelperConfig helperConfig;
    HelperConfig.NetworkConfig networkConfig;

    /*//////////////////////////////////////////////////////////////
                               CONTRACTS
    //////////////////////////////////////////////////////////////*/
    ERC721APausable nftContract;

    /*//////////////////////////////////////////////////////////////
                                HELPERS
    //////////////////////////////////////////////////////////////*/
    address USER = makeAddr("user");
    uint256 constant NEW_BATCH_LIMIT = 20;
    uint256 constant NEW_MAX_WALLET_SIZE = 20;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event Paused(address indexed sender);
    event Unpaused(address indexed sender);

    /*//////////////////////////////////////////////////////////////
                                 MODIFIERS
    //////////////////////////////////////////////////////////////*/
    modifier unpaused() {
        vm.startPrank(nftContract.owner());
        nftContract.unpause();
        vm.stopPrank();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                                 SETUP
    //////////////////////////////////////////////////////////////*/
    function setUp() external virtual {
        nftPausableDeployer = new DeployERC721APausable();
        (nftContract, helperConfig) = nftPausableDeployer.run();

        networkConfig = helperConfig.getActiveNetworkConfigStruct();
    }

    /*//////////////////////////////////////////////////////////////
                          TEST   INITIALIZATION
    //////////////////////////////////////////////////////////////*/
    function test__unit__Initialization() public view {
        assertEq(nftContract.isPaused(), true);
    }

    /*//////////////////////////////////////////////////////////////
                               TEST PAUSE
    //////////////////////////////////////////////////////////////*/
    function test__ERC721APausable__UnPause() public {
        address owner = nftContract.owner();

        vm.prank(owner);
        nftContract.unpause();

        assertEq(nftContract.isPaused(), false);
    }

    function test__ERC721APausable__Pause() public {
        address owner = nftContract.owner();

        vm.prank(owner);
        nftContract.unpause();

        vm.prank(owner);
        nftContract.pause();

        assertEq(nftContract.isPaused(), true);
    }

    function test__ERC721APausable__EmitEvent__Pause() public {
        address owner = nftContract.owner();

        vm.expectEmit(true, true, true, true);
        emit Unpaused(owner);

        vm.prank(owner);
        nftContract.unpause();
    }

    function test__ERC721APausable__EmitEvent__Unpause() public {
        address owner = nftContract.owner();
        vm.prank(owner);
        nftContract.unpause();

        vm.expectEmit(true, true, true, true);
        emit Paused(owner);

        vm.prank(owner);
        nftContract.pause();
    }

    function test__ERC721APausable__RevertsWhen__NotOwnerPauses() public {
        address owner = nftContract.owner();

        vm.prank(owner);
        nftContract.unpause();

        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, USER));
        vm.prank(USER);
        nftContract.pause();
    }

    function test__ERC721APausable__RevertsWhen__PauseAlreadyPaused() public {
        address owner = nftContract.owner();

        vm.expectRevert(Pausable.Pausable_ContractIsPaused.selector);

        vm.prank(owner);
        nftContract.pause();
    }

    function test__ERC721APausable__RevertsWhen__UnpauseAlreadyUnpaused() public {
        address owner = nftContract.owner();

        vm.prank(owner);
        nftContract.unpause();

        vm.expectRevert(Pausable.Pausable_ContractIsUnpaused.selector);

        vm.prank(owner);
        nftContract.unpause();
    }

    /*//////////////////////////////////////////////////////////////
                               TEST MINT
    //////////////////////////////////////////////////////////////*/

    /// SUCCESS
    //////////////////////////////////////////////////////////////*/
    function test__ERC721APausable__Mint(uint256 quantity) public unpaused {
        quantity = bound(quantity, 1, nftContract.getBatchLimit());

        vm.prank(USER);
        nftContract.mint(quantity);

        assertEq(nftContract.balanceOf(USER), quantity);
    }

    /// REVERTS
    //////////////////////////////////////////////////////////////*/
    function test__ERC721APausable__RevertWhen__MintPaused() public {
        vm.expectRevert(Pausable.Pausable_ContractIsPaused.selector);
        vm.prank(USER);
        nftContract.mint(1);
    }
}
