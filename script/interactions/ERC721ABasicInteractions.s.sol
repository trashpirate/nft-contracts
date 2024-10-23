// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

import {ERC721ABasic} from "src/test/ERC721ABasic.sol";

contract MintNft is Script {
    function mintNft(address recentContractAddress) public {
        vm.startBroadcast();
        uint256 gasLeft = gasleft();
        ERC721ABasic(recentContractAddress).mint(1);
        console.log("Minting gas: ", gasLeft - gasleft());
        vm.stopBroadcast();
        console.log("Minted 1 NFT with:", msg.sender);
    }

    function run() external {
        address recentContractAddress = DevOpsTools.get_most_recent_deployment("ERC721ABasic", block.chainid);
        mintNft(recentContractAddress);
    }
}

contract BatchMint is Script {
    function batchMint(address recentContractAddress) public {
        uint256 batchLimit = ERC721ABasic(recentContractAddress).getBatchLimit();

        vm.startBroadcast();

        uint256 gasLeft = gasleft();
        ERC721ABasic(recentContractAddress).mint(batchLimit);
        console.log("Minting gas: ", gasLeft - gasleft());
        vm.stopBroadcast();
        console.log("Minted batch with:", msg.sender);
    }

    function run() external {
        address recentContractAddress = DevOpsTools.get_most_recent_deployment("ERC721ABasic", block.chainid);
        batchMint(recentContractAddress);
    }
}

contract TransferNft is Script {
    address NEW_USER = makeAddr("new-user");

    function transferNft(address recentContractAddress) public {
        vm.startBroadcast();
        ERC721ABasic(recentContractAddress).transferFrom(tx.origin, NEW_USER, 1);
        vm.stopBroadcast();
    }

    function run() external {
        address recentContractAddress = DevOpsTools.get_most_recent_deployment("ERC721ABasic", block.chainid);
        transferNft(recentContractAddress);
    }
}

contract ApproveNft is Script {
    address public SENDER = makeAddr("sender");

    function approveNft(address recentContractAddress) public {
        vm.startBroadcast();
        ERC721ABasic(recentContractAddress).approve(SENDER, 1);
        vm.stopBroadcast();
    }

    function run() external {
        address recentContractAddress = DevOpsTools.get_most_recent_deployment("ERC721ABasic", block.chainid);
        approveNft(recentContractAddress);
    }
}

contract BurnNft is Script {
    address public SENDER = makeAddr("sender");

    function burnNft(address recentContractAddress) public {
        vm.startBroadcast();
        ERC721ABasic(recentContractAddress).burn(1);
        vm.stopBroadcast();
    }

    function run() external {
        address recentContractAddress = DevOpsTools.get_most_recent_deployment("ERC721ABasic", block.chainid);
        burnNft(recentContractAddress);
    }
}

/// TODO

/**
 * setBatchLimit
 *
 * setMaxWalletSize
 *
 * withdrawTokens
 *
 * withdrawETH
 *
 * setBaseURI
 *
 * setContractURI
 *
 * setRoyalty
 */
