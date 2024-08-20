// SPDX-License-Identifier: MIT

// 1. Deploy mocks when we are on a local anvil chain
// 2. Keep track of contract address across different chains.
// Sepolia ETH/USD
// Mainnet ETH/USD

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/mockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaETHConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetETHConfig();
        } else if (block.chainid == 31337) {
            activeNetworkConfig = getAnvilETHConfig();
        }
    }

    function getMainnetETHConfig()
        public
        pure
        returns (NetworkConfig memory mainnetConfig)
    {
        mainnetConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
    }

    function getSepoliaETHConfig()
        public
        pure
        returns (NetworkConfig memory sepoliaConfig)
    {
        sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
    }

    function getAnvilETHConfig()
        public
        returns (NetworkConfig memory anvilConfig)
    {
        // 1. Deploy the mocks
        // 2. Return the mock address

        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(8, 2000e8);
        vm.stopBroadcast();

        anvilConfig = NetworkConfig({priceFeed: address(mockV3Aggregator)});
    }
}
