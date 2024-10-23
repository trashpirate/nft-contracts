// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ERC721APseudoRandomized} from "src/test/ERC721APseudoRandomized.sol";
import {HelperConfig} from "script/helpers/HelperConfig.s.sol";

contract DeployERC721APseudoRandomized is Script {
    HelperConfig public helperConfig;

    function run() external returns (ERC721APseudoRandomized, HelperConfig) {
        helperConfig = new HelperConfig();
        HelperConfig.ConstructorArguments memory args = helperConfig.activeNetworkConfig();

        // after broadcast is real transaction, before just simulation
        vm.startBroadcast();
        uint256 gasLeft = gasleft();
        ERC721APseudoRandomized nfts = new ERC721APseudoRandomized(args.coreConfig);
        console.log("Deployment gas: ", gasLeft - gasleft());
        vm.stopBroadcast();
        return (nfts, helperConfig);
    }
}
