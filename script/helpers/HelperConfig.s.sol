// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {ERC721ACore} from "src/ERC721ACore.sol";

contract HelperConfig is Script {
    struct ConstructorArguments {
        ERC721ACore.CoreConfig coreConfig;
        // string name;
        // string symbol;
        // string baseURI;
        // string contractURI;
        // address owner;
        address feeAddress;
        address tokenAddress;
        uint256 tokenFee;
        uint256 ethFee;
        // uint256 maxSupply;
        // uint256 maxWalletSize;
        // uint256 batchLimit;
        bytes32 merkleRoot;
    }

    struct NetworkConfig {
        ConstructorArguments args;
    }

    // nft configurations
    string public NAME;
    string public SYMBOL;
    string public BASE_URI;
    string public CONTRACT_URI;
    uint256 public MAX_SUPPLY;
    uint256 public ETH_FEE;
    uint256 public TOKEN_FEE;

    bytes32 public MERKLE_ROOT;

    // chain configurations
    NetworkConfig public activeNetworkConfig;

    constructor() {
        NAME = vm.envString("COLLECTION_NAME");
        SYMBOL = vm.envString("SYMBOL");
        BASE_URI = vm.envString("BASE_URI");
        CONTRACT_URI = vm.envString("CONTRACT_URI");
        MAX_SUPPLY = vm.envUint("MAX_SUPPLY");
        ETH_FEE = vm.envUint("ETH_FEE");
        TOKEN_FEE = vm.envUint("TOKEN_FEE");
        MERKLE_ROOT = vm.envBytes32("MERKLE_ROOT");

        console.log("NAME: ", NAME);
        console.log("SYMBOL: ", SYMBOL);
        console.log("BASE_URI: ", BASE_URI);
        console.log("CONTRACT_URI: ", CONTRACT_URI);
        console.log("MAX_SUPPLY: ", MAX_SUPPLY);
        console.log("ETH_FEE: ", ETH_FEE);
        console.log("TOKEN_FEE: ", TOKEN_FEE);

        if (block.chainid == 1 || block.chainid == 123) {
            activeNetworkConfig = getMainnetConfig();
        } else if (block.chainid == 11155111) {
            activeNetworkConfig = getTestnetConfig();
        } else {
            activeNetworkConfig = getAnvilConfig();
        }
    }

    function getActiveNetworkConfigStruct() public view returns (NetworkConfig memory) {
        return activeNetworkConfig;
    }

    function getMainnetConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            args: ConstructorArguments({
                coreConfig: ERC721ACore.CoreConfig({
                    name: NAME,
                    symbol: SYMBOL,
                    baseURI: BASE_URI,
                    contractURI: CONTRACT_URI,
                    owner: vm.envAddress("OWNER_ADDRESS"),
                    maxSupply: MAX_SUPPLY,
                    maxWalletSize: 10,
                    batchLimit: 10,
                    royaltyNumerator: 500 // 5%
                }),
                feeAddress: vm.envAddress("FEE_ADDRESS"),
                tokenAddress: vm.envAddress("TOKEN_ADDRESS"),
                ethFee: ETH_FEE,
                tokenFee: TOKEN_FEE,
                merkleRoot: MERKLE_ROOT
            })
        });
    }

    function getTestnetConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            args: ConstructorArguments({
                coreConfig: ERC721ACore.CoreConfig({
                    name: NAME,
                    symbol: SYMBOL,
                    baseURI: BASE_URI,
                    contractURI: CONTRACT_URI,
                    owner: vm.envAddress("OWNER_ADDRESS"),
                    maxSupply: MAX_SUPPLY,
                    maxWalletSize: 10,
                    batchLimit: 10,
                    royaltyNumerator: 500 // 5%
                }),
                feeAddress: vm.envAddress("FEE_ADDRESS"),
                tokenAddress: vm.envAddress("TOKEN_ADDRESS"),
                ethFee: ETH_FEE,
                tokenFee: TOKEN_FEE,
                merkleRoot: MERKLE_ROOT
            })
        });
    }

    function getAnvilConfig() public returns (NetworkConfig memory) {
        // Deploy mock contracts
        vm.startBroadcast();
        ERC20Mock token = new ERC20Mock();
        vm.stopBroadcast();

        return NetworkConfig({
            args: ConstructorArguments({
                coreConfig: ERC721ACore.CoreConfig({
                    name: NAME,
                    symbol: SYMBOL,
                    baseURI: BASE_URI,
                    contractURI: CONTRACT_URI,
                    owner: vm.envAddress("ANVIL_DEFAULT_ACCOUNT"),
                    maxSupply: MAX_SUPPLY,
                    maxWalletSize: 10,
                    batchLimit: 10,
                    royaltyNumerator: 500 // 5%
                }),
                feeAddress: vm.envAddress("ANVIL_DEFAULT_ACCOUNT"),
                tokenAddress: address(token),
                ethFee: ETH_FEE,
                tokenFee: TOKEN_FEE,
                merkleRoot: MERKLE_ROOT
            })
        });
    }
}
