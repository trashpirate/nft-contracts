// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ERC721ACore} from "src/ERC721ACore.sol";
import {HelperConfig} from "script/helpers/HelperConfig.s.sol";

contract DeployERC721ACore is Script {
    HelperConfig public helperConfig;

    function run() external returns (ERC721ACore, HelperConfig) {
        helperConfig = new HelperConfig();
        HelperConfig.ConstructorArguments memory args = helperConfig.getActiveNetworkConfigStruct().args;

        // after broadcast is real transaction, before just simulation
        vm.startBroadcast();
        uint256 gasLeft = gasleft();
        ERC721ACore nfts = new ERC721ACore(args.coreConfig);
        console.log("ERC721ACore - Deployment gas: ", gasLeft - gasleft());
        vm.stopBroadcast();
        return (nfts, helperConfig);
    }
}
