// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    address public ethUSDPriceFeed;

    function run() external returns (FundMe fundMe) {
        HelperConfig helperConfig = new HelperConfig();
        ethUSDPriceFeed = helperConfig.activeNetworkConfig();
        vm.startBroadcast();
        fundMe = new FundMe(ethUSDPriceFeed);
        vm.stopBroadcast();
    }
}
