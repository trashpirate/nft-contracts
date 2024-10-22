// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

import {ERC721AContract} from "src/examples/ERC721AContract.sol";

contract MintNft is Script {
    function mintNft(address recentContractAddress) public {
        uint256 ethFee = ERC721AContract(payable(recentContractAddress)).getEthFee();
        vm.startBroadcast();

        uint256 gasLeft = gasleft();
        ERC721AContract(payable(recentContractAddress)).mint{value: ethFee}(1);
        console.log("Minting gas: ", gasLeft - gasleft());
        vm.stopBroadcast();
        console.log("Minted 1 ERC721 with:", msg.sender);
    }

    function run() external {
        address recentContractAddress = DevOpsTools.get_most_recent_deployment("ERC721AContract", block.chainid);
        mintNft(recentContractAddress);
    }
}

contract BatchMint is Script {
    function batchMint(address recentContractAddress) public {
        uint256 batchLimit = ERC721AContract(payable(recentContractAddress)).getBatchLimit();
        uint256 ethFee = batchLimit * ERC721AContract(payable(recentContractAddress)).getEthFee();
        vm.startBroadcast();

        uint256 gasLeft = gasleft();
        ERC721AContract(payable(recentContractAddress)).mint{value: ethFee}(batchLimit);
        console.log("Minting gas: ", gasLeft - gasleft());
        vm.stopBroadcast();
        console.log("Minted batch with:", msg.sender);
    }

    function run() external {
        address recentContractAddress = DevOpsTools.get_most_recent_deployment("ERC721AContract", block.chainid);
        batchMint(recentContractAddress);
    }
}
