// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ERC721AFeeHandler} from "src/test/ERC721AFeeHandler.sol";
import {HelperConfig} from "script/helpers/HelperConfig.s.sol";

contract DeployERC721AFeeHandler is Script {
    HelperConfig public helperConfig;

    function run() external returns (ERC721AFeeHandler, HelperConfig) {
        helperConfig = new HelperConfig();
        HelperConfig.ConstructorArguments memory args = helperConfig.activeNetworkConfig();

        // after broadcast is real transaction, before just simulation
        vm.startBroadcast();
        uint256 gasLeft = gasleft();
        ERC721AFeeHandler nfts =
            new ERC721AFeeHandler(args.coreConfig, args.feeAddress, args.tokenAddress, args.tokenFee, args.ethFee);
        console.log("Deployment gas: ", gasLeft - gasleft());
        vm.stopBroadcast();
        return (nfts, helperConfig);
    }
}
