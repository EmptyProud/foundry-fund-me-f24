// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// The forge standard library has couple of standard packages that we can use to make running our tests easier
import {Test, console} from "forge-std/Test.sol";

// To deploy our contract in the setUp() function, we need to import our contract
import {FundMe} from "../../src/FundMe.sol";

// To use the deploy in the setUp() function, we need to import the DeployFundMe contract
// So we dont need to keep changing the address in the setUp() function when we want to deploy to other network
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

// To know the interaction script file
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;

    address USER = makeAddr("Alice");
    uint256 constant VALUE_SENT = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe)); // we need to go for the fundFundMe() function instead of the run() function
        // Then only we will be able to add my own address (fundMe) to the function

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}
