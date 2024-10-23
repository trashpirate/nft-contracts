// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ERC721ABasic} from "src/examples/ERC721ABasic.sol";
import {HelperConfig} from "script/helpers/HelperConfig.s.sol";

contract DeployERC721ABasic is Script {
    HelperConfig public helperConfig;

    function run() external returns (ERC721ABasic, HelperConfig) {
        helperConfig = new HelperConfig();
        HelperConfig.ConstructorArguments memory args = helperConfig.getActiveNetworkConfigStruct().args;

        // after broadcast is real transaction, before just simulation
        vm.startBroadcast();
        uint256 gasLeft = gasleft();
        ERC721ABasic nfts = new ERC721ABasic(args.coreConfig);
        console.log("ERC721ABasic - Deployment gas: ", gasLeft - gasleft());
        vm.stopBroadcast();
        return (nfts, helperConfig);
    }
}
