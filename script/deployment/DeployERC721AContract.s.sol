// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ERC721AContract} from "src/test/ERC721AContract.sol";
import {HelperConfig} from "script/helpers/HelperConfig.s.sol";

contract DeployERC721AContract is Script {
    HelperConfig public helperConfig;

    function run() external returns (ERC721AContract, HelperConfig) {
        helperConfig = new HelperConfig();
        HelperConfig.ConstructorArguments memory args = helperConfig.activeNetworkConfig();

        // after broadcast is real transaction, before just simulation
        vm.startBroadcast();
        uint256 gasLeft = gasleft();
        ERC721AContract nfts =
            new ERC721AContract(args.coreConfig, args.feeAddress, args.tokenAddress, args.tokenFee, args.ethFee);
        console.log("Deployment gas: ", gasLeft - gasleft());
        vm.stopBroadcast();
        return (nfts, helperConfig);
    }
}
