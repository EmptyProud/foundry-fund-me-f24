// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// The forge standard library has couple of standard packages that we can use to make running our tests easier
// That assert command for example is something that foundry automatically has built in
import {Test, console} from "forge-std/Test.sol";

// To deploy our contract in the setUp() function, we need to import our contract
import {FundMe} from "../../src/FundMe.sol";

// To use the deploy in the setUp() function, we need to import the DeployFundMe contract
// So we dont need to keep changing the address in the setUp() function when we want to deploy to other network
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    // Create a new user to send all the transactions
    address USER = makeAddr("Alice");
    // To remove magic number
    uint256 constant VALUE_SENT = 0.1 ether; // decimals doesn't work in Solidity, but if u do 0.1 ether, it works
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1; // 1 Gwei

    function setUp() external {
        // We can use the function in DeployFundMe contract to deploy our contract
        DeployFundMe deployFundMe = new DeployFundMe(); // create instance of DeployFundMe contract
        fundMe = deployFundMe.run(); // Use that instance to run the run() function in DeployFundMe contract

        vm.deal(USER, STARTING_BALANCE); // We need to fund the USER account to send transactions
    }

    function testMinimumDollarIsTwo() public view {
        assertEq(fundMe.MINIMUM_USD(), 2e18);
    }

    // We check whether the owner is the one who deployed the contract
    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    // This is a unit test and also an integration test
    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    // What we can do to work with addresses outside our system
    // 1. Unit
    //    - Testing a specific part of our code
    // 2. Integration
    //    - Testing how our code works with other parts of our code
    // 3. Forked
    //    - Testing our code on a simulated real environment
    // 4. Staging
    //    - Testing our code in a real environment that is not prod

    // Test for the fund() function
    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); // This tell that the next line should revert
        fundMe.fund(); // We don't put any value to send in the fund() function, so it will revert and our test is passed
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);
        fundMe.fund{value: VALUE_SENT}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, VALUE_SENT);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: VALUE_SENT}();
        assertEq(fundMe.getFundersAddress(0), USER);
    }

    modifier funded() {
        // We will first fund it with the USER account to send transactions
        vm.prank(USER);
        fundMe.fund{value: VALUE_SENT}();
        _;
    }

    // Test only owner can use the withdraw() function
    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    // Test withdraw() function with single funder
    function testWithdrawWithSingleFunder() public funded {
        // We need to check the balance of owner first before we call the withdraw() function, so we can see the balance before and after

        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }

    // Test withdraw() function with multiple funder
    function testWithdrawWithMultipleFunder() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        // we should use uint160 at here as we r using address(i)
        // It will error if we cast explicitly from uint256 to address instead of from uint160 to address
        // The reason for this is because uint160 has the same amount of bytes as an address
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank new address
            // vm.deal new address
            // Combination of vm.prank and vm.deal is hoax()
            hoax(address(i), 10 ether);
            fundMe.fund{value: VALUE_SENT}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        assertEq(address(fundMe).balance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, fundMe.getOwner().balance);
    }

    function testWithdrawWithMultipleFundersCheaper() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), 10 ether);
            fundMe.fund{value: VALUE_SENT}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();

        assertEq(address(fundMe).balance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, fundMe.getOwner().balance);
    }
}
