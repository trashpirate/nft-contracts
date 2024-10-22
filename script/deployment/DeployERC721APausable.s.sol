// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ERC721APausable} from "src/examples/ERC721APausable.sol";
import {HelperConfig} from "script/helpers/HelperConfig.s.sol";

contract DeployERC721APausable is Script {
    HelperConfig public helperConfig;

    function run() external returns (ERC721APausable, HelperConfig) {
        helperConfig = new HelperConfig();
        HelperConfig.ConstructorArguments memory args = helperConfig.activeNetworkConfig();

        // after broadcast is real transaction, before just simulation
        vm.startBroadcast();
        uint256 gasLeft = gasleft();
        ERC721APausable nfts = new ERC721APausable(args.coreConfig);
        console.log("Deployment gas: ", gasLeft - gasleft());
        vm.stopBroadcast();
        return (nfts, helperConfig);
    }
}
