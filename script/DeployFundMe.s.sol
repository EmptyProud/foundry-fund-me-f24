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
        // Create the instance before we start broadcasting
        // As we don't want to spend gas to deploy this on a real chain
        HelperConfig helperConfig = new HelperConfig();
        // At the moment we deploy this helperConfig contract, our activeNetworkConfig will be set up which address to be used
        address ethPriceFeed = helperConfig.activeNetworkConfig();
        // In normally, we have to return the struct that we would like to get
        // When u have mutiple return values
        // U need to use like this: (address ethPriceFeed, uint256 gasPrice,) = helperConfig.activeNetworkConfig();
        // Wrap the thing that u want to return in the brackets
        // But for now, we only have one return value, so we can just use
        // address ethPriceFeed = helperConfig.activeNetworkConfig();

        // After startBoardcast -> Real tx
        vm.startBroadcast();
        // FundMe fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        // Change it after we have the HelperConfig contract
        FundMe fundMe = new FundMe(ethPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
