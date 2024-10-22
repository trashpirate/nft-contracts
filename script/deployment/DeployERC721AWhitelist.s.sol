// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ERC721AWhitelist} from "src/examples/ERC721AWhitelist.sol";
import {HelperConfig} from "script/helpers/HelperConfig.s.sol";

contract DeployERC721AWhitelist is Script {
    HelperConfig public helperConfig;

    function run() external returns (ERC721AWhitelist, HelperConfig) {
        helperConfig = new HelperConfig();
        HelperConfig.ConstructorArguments memory args = helperConfig.activeNetworkConfig();

        // after broadcast is real transaction, before just simulation
        vm.startBroadcast();
        uint256 gasLeft = gasleft();
        ERC721AWhitelist nfts = new ERC721AWhitelist(args.coreConfig, args.merkleRoot);
        console.log("Deployment gas: ", gasLeft - gasleft());
        vm.stopBroadcast();
        return (nfts, helperConfig);
    }
}
