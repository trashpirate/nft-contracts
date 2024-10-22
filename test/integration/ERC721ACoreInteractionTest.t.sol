// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

import {ERC721ACore} from "src/ERC721ACore.sol";
import {HelperConfig} from "script/helpers/HelperConfig.s.sol";
import {DeployERC721ACore} from "script/deployment/DeployERC721ACore.s.sol";
import {MintNft, BatchMint, TransferNft, ApproveNft, BurnNft} from "script/interactions/ERC721ACoreInteractions.s.sol";

contract ERC721ACoreInteractionTest is Test {
    /*//////////////////////////////////////////////////////////////
                             CONFIGURATION
    //////////////////////////////////////////////////////////////*/
    DeployERC721ACore deployment;
    HelperConfig helperConfig;
    HelperConfig.NetworkConfig networkConfig;

    /*//////////////////////////////////////////////////////////////
                               CONTRACTS
    //////////////////////////////////////////////////////////////*/
    ERC721ACore nftContract;
    ERC20Mock token;

    /*//////////////////////////////////////////////////////////////
                                HELPERS
    //////////////////////////////////////////////////////////////*/
    address contractOwner;
    address USER = makeAddr("user");
    uint256 constant STARTING_BALANCE = 500_000_000 ether;

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/
    modifier skipFork() {
        if (block.chainid != 31337) {
            return;
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                                 SETUP
    //////////////////////////////////////////////////////////////*/
    function setUp() external {
        deployment = new DeployERC721ACore();
        (nftContract, helperConfig) = deployment.run();
        contractOwner = nftContract.owner();

        networkConfig = helperConfig.getActiveNetworkConfigStruct();
    }

    /*//////////////////////////////////////////////////////////////
                               TEST MINT
    //////////////////////////////////////////////////////////////*/
    function test__ERC721ACoreInteraction__SingleMint() public {
        MintNft mintNft = new MintNft();
        mintNft.mintNft(address(nftContract));
        assertEq(nftContract.balanceOf(msg.sender), 1);
    }

    /*//////////////////////////////////////////////////////////////
                            TEST BATCH MINT
    //////////////////////////////////////////////////////////////*/
    function test__ERC721ACoreInteraction__BatchMint() public {
        BatchMint batchMint = new BatchMint();
        batchMint.batchMint(address(nftContract));
        assertEq(nftContract.balanceOf(msg.sender), nftContract.getBatchLimit());
    }

    /*//////////////////////////////////////////////////////////////
                             TEST TRANSFER
    //////////////////////////////////////////////////////////////*/
    function test__ERC721ACoreInteraction__TransferNft() public {
        MintNft mintNft = new MintNft();
        mintNft.mintNft(address(nftContract));
        assert(nftContract.balanceOf(msg.sender) == 1);

        TransferNft transferNft = new TransferNft();
        transferNft.transferNft(address(nftContract));
        assertEq(nftContract.balanceOf(msg.sender), 0);
    }

    /*//////////////////////////////////////////////////////////////
                              TEST APPROVE
    //////////////////////////////////////////////////////////////*/
    function test__ERC721ACoreInteraction__ApproveNft() public {
        MintNft mintNft = new MintNft();
        mintNft.mintNft(address(nftContract));
        assertEq(nftContract.balanceOf(msg.sender), 1);

        ApproveNft approveNft = new ApproveNft();
        approveNft.approveNft(address(nftContract));

        assertEq(nftContract.getApproved(1), approveNft.SENDER());
    }

    /*//////////////////////////////////////////////////////////////
                               TEST BURN
    //////////////////////////////////////////////////////////////*/
    function test__ERC721ACoreInteraction__BurnNft() public {
        MintNft mintNft = new MintNft();
        mintNft.mintNft(address(nftContract));
        assertEq(nftContract.balanceOf(msg.sender), 1);

        BurnNft burnNft = new BurnNft();
        burnNft.burnNft(address(nftContract));

        assertEq(nftContract.balanceOf(msg.sender), 0);
    }
}
