// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// To tell foundry it is a script instead of contract
import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";

// Import helper config to get the address of the price feed
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract DeployFundMe is Script {
    // U can also deploy without return the contract
    function run() external returns (FundMe) {
        // Before startBoardcast -> Not a "real" tx
        HelperConfig helperConfig = new HelperConfig();
        address ethPriceFeed = helperConfig.activeNetworkConfig();

        // After startBoardcast -> Real tx
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
