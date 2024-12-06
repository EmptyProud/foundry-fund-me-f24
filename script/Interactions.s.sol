// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// To tell it is a script and using console log
import {Script, console} from "forge-std/Script.sol";

// To know the most recent deployment contract address
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

// To know the FundMe contract
import {FundMe} from "../src/FundMe.sol";

// This is our script for funding the FundMe contract
contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    // We need to seprate both these two functions
    function fundFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded FundMe with %s", SEND_VALUE);
    }

    function run() external {
        // Note one thing that is we need to fund our most recently deployed FundMe contract by using DevOpsTools.get_most_recent_deployment()
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        fundFundMe(mostRecentlyDeployed);
    }
}

// This is our script for withdrawing the FundMe contract
contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        withdrawFundMe(mostRecentlyDeployed);
    }
}
