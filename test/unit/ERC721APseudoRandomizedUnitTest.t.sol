// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

import {StringToNumber} from "test/utils/Utils.sol";
import {DeployERC721APseudoRandomized} from "script/deployment/DeployERC721APseudoRandomized.s.sol";
import {ERC721APseudoRandomized, ERC721ACore} from "src/examples/ERC721APseudoRandomized.sol";
import {HelperConfig} from "script/helpers/HelperConfig.s.sol";
import {TestHelper} from "test/utils/TestHelper.sol";

contract ERC721APseudoRandomizedTest is Test {
    /*//////////////////////////////////////////////////////////////
                             CONFIGURATION
    //////////////////////////////////////////////////////////////*/
    DeployERC721APseudoRandomized deployment;
    HelperConfig helperConfig;
    HelperConfig.NetworkConfig networkConfig;

    /*//////////////////////////////////////////////////////////////
                               CONTRACTS
    //////////////////////////////////////////////////////////////*/
    ERC721APseudoRandomized nftContract;

    /*//////////////////////////////////////////////////////////////
                                HELPERS
    //////////////////////////////////////////////////////////////*/
    address USER = makeAddr("user");

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/
    modifier skipFork() {
        if (block.chainid != 31337) {
            return;
        }
        _;
    }

    modifier noMaxWallet() {
        address owner = nftContract.owner();
        vm.prank(owner);
        nftContract.setMaxWalletSize(0);
        _;
    }

    modifier noBatchLimit() {
        address owner = nftContract.owner();
        vm.prank(owner);
        nftContract.setBatchLimit(100);
        _;
    }

    /*//////////////////////////////////////////////////////////////
                                 SETUP
    //////////////////////////////////////////////////////////////*/
    function setUp() external virtual {
        deployment = new DeployERC721APseudoRandomized();
        (nftContract, helperConfig) = deployment.run();

        networkConfig = helperConfig.getActiveNetworkConfigStruct();
    }

    /*//////////////////////////////////////////////////////////////
                          TEST SUPPORTS INTERFACE
    //////////////////////////////////////////////////////////////*/
    function test__ERC721APseudoRandomized__SupportsInterface() public view {
        assertEq(nftContract.supportsInterface(0x80ac58cd), true); // ERC721
        assertEq(nftContract.supportsInterface(0x2a55205a), true); // ERC2981
    }

    /*//////////////////////////////////////////////////////////////
                             TEST TOKEN URI
    //////////////////////////////////////////////////////////////*/
    function test__ERC721APseudoRandomized__batchTokenURI() public {
        uint256 roll = 2;
        uint256 batchLimit = nftContract.getBatchLimit();
        for (uint256 index = 0; index < 20; index++) {
            vm.prevrandao(bytes32(uint256(index + roll)));
            vm.startPrank(USER);
            nftContract.mint(batchLimit);
            vm.stopPrank();
        }

        for (uint256 index = 0; index < nftContract.totalSupply() - 1; index++) {
            console.log(nftContract.tokenURI(index + 1));
        }
    }

    /// forge-config: default.fuzz.runs = 3
    function test__ERC721APseudoRandomized__UniqueTokenURI() public skipFork {
        uint256 roll = 3; // bound(roll, 0, 100000000000);
        TestHelper testHelper = new TestHelper();

        uint256 maxSupply = nftContract.getMaxSupply();

        vm.startPrank(USER);
        for (uint256 index = 0; index < maxSupply; index++) {
            vm.prevrandao(bytes32(uint256(index + roll)));

            nftContract.mint(1);
            assertEq(testHelper.isTokenUriSet(nftContract.tokenURI(index + 1)), false);
            console.log(nftContract.tokenURI(index + 1));
            testHelper.setTokenUri(nftContract.tokenURI(index + 1));
        }
        vm.stopPrank();
    }
}
