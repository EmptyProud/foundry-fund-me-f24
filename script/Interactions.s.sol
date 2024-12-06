// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// Fund
// Withdraw

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
        vm.startBroadcast(); // Broadcast and prank r not compatible, so we need to remove one of them, in here we remove broadcast
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded FundMe with %s", SEND_VALUE);
    }

    function run() external {
        // Note one thing that is we need to fund our most recently deployed FundMe contract
        // We have a tool called foundry-devops to grab our most recently deployed contract address
        // Ther're some other foundry-devops tools coming out so we need to follow the link provided that in description of patrick repo
        // The link is for the most up-to-date one we should use
        // This package helps foundry keep track of the most recently deployed contract address
        // For current time to install, Enter: forge install Cyfrin/foundry-devops --no-commit (it will return Installed foundry-devops 0.2.3)
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        // vm.startBroadcast();
        // It will look inside the broadcast/ folder based of the chain id n picks the run-latest.json file n grab the latest deploy address
        fundFundMe(mostRecentlyDeployed);
        // vm.stopBroadcast();
    }

    // Enter: forge script script/Interactions.s.sol:FundFundMe --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast
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

    // Enter: forge script script/Interactions.s.sol:WithdrawFundMe --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast
}
