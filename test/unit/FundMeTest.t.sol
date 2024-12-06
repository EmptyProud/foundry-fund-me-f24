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
    // Create a new user to send all the transactions
    address USER = makeAddr("Alice");
    // To remove magic number
    // uint256 constant VALUE_SENT = 7e15;
    uint256 constant VALUE_SENT = 0.1 ether; // decimals doesn't work in Solidity, but if u do 0.1 ether, it works
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1; // 1 Gwei

    /* This is for demo only */
    // uint256 number = 1; // Just for testing
    // // First thing we should do when we write our test
    // // We want to test that our FundMe contract is working as expected (doing what we want to do)
    // // At first we want to do is deploy our contract
    // // Pretty soon, we will learn how to import our deploy script in here to make our deployment environment exact same as testing environment
    // // But for now, we will just deploy our contract right in this test file
    // // On all our tests, the first thing that happens is the setup function (deploying our contract)
    // function setUp() external {
    //     number = 2;
    //     // Everything in here, setUp() will be run first, if u declare ur state variable in here, it will be using this value
    //     // Instead of using the value that u declared in the storage or state variable
    // }

    // // This is just for demo test
    // // Enter: forge test
    // // U will find 1 test is done, which is ur testDemo()
    // function testDemo() public {
    //     // Another way to test this and do some debugging is using something called console.log
    //     // In forge documentation, it got talks about console logging
    //     // We can actually do print statements that will print stuff out from our test and from our smart contracts
    //     console.log(number);
    //     // U should get printed out to out terminal the number associated with the number variable which should be 2
    //     // console.log("Hello, World!"); // u can use it to print something
    //     // Enter: forge test -vv (u can use up to 5 v)
    //     // the -vv specifies the visibility of logging in this test
    //     // If the visibility is too low (like 1 v), u will not see the log, a warning will pop up (restricted to view)
    //     assertEq(number, 2);
    // }

    /* Now we only start our real test with FundMe contract but it will be refactor afterwards*/
    FundMe fundMe;

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        // // Remember to check whether the contract FundMe has any input parameters, go to ur constructor in FundMe.sol to check
        // // For FundMe contract, it doesn't have any input parameters

        // Great, we don't change the address one by one, we can use the function in DeployFundMe contract to deploy our contract
        DeployFundMe deployFundMe = new DeployFundMe(); // create instance of DeployFundMe contract
        fundMe = deployFundMe.run(); // Use that instance to run the run() function in DeployFundMe contract

        vm.deal(USER, STARTING_BALANCE); // We need to fund the USER account to send the transaction
    }

    function testMinimumDollarIsTwo() public view {
        // We can test this FundMe contract, we can pick a function or a public variable to check to see what we're doing is working good
        assertEq(fundMe.MINIMUM_USD(), 2e18);
        // We call the MINIMUM_USD() function from our FundMe contract
        // Enter: forge test -vv (u will find it works)\
        // If u put other value in the assertEq() function, it will fail
    }

    // We check whether the owner is the one who deployed the contract
    function testOwnerIsMsgSender() public view {
        // // To debug in begining when u use msg.send and it fail and u dk what happened,
        // // U can use console.log() to check the value of the variable for debugging
        // // Remember to put on top of ur assertEq() function or not u will won't to find it
        // console.log(fundMe.i_owner());
        // console.log(msg.sender);
        // assertEq(fundMe.i_owner(), address(this));
        // // We check whether the owner is the one who deployed the contract
        // // We use address(this) because we are the one who deployed the contract
        // // If we use msg.sender, it will be the one who called the function and u will get an error
        // // As we (msg.sender) is not the one who deployed the contract, is this contract deployed the FundMe contract

        // Great, to avoid changing the address one by one, we can use run() function in DeployFundMe contract to deploy
        // So the i_owner is no more the address of this contract
        // The i_owner is the address of msg.sender as vm.broadcast() in run() function makes funder actually the msg.sender
        assertEq(fundMe.getOwner(), msg.sender);
    }

    /* Fund Me Forked Test Section*/

    // The most important pieces of the FundMe contract that we should absolutely get right is the fund() function
    // We need to make sure the conversion rate is actually working
    // In order to let the conversion rate working, we need to make sure that we actually able to get the version from the aggregatorV3Interface
    // So we use the getVersion function to try testing if our price feed integrations r working correctly
    // In remix, we need the getVersion will get a version of 4
    function testPriceFeedVersionIsAccurate() public {
        // This is a unit test and also an integration test
        // uint256 version = fundMe.getVersion(); \

        // Revised after having the HelperConfig contract to set the address
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }
    // It will fail if u run the command: forge test for this test as u r calling a address that doesn't exist
    // Without specifiying the rpc url in ur forge test command, it will auto create a new anvil chain to run test
    // Solution: u need to specify the rpc url in ur forge test command
    // Enter: forge test --match-test testPriceFeedVersionIsAccurate -vvvv --rpc-url (--fork-url also can) $SEPOLIA_RPC_URL
    // Then u will find the test is passed as u r able to use the outside address to get the version
    // In this case, anvil will actual get spun up but it'll take a copy of this sepolia rpc url
    // and it will spin up with anvil but it will simulate all of our transacstions
    // as if they're actaully running on the sepolia chain
    // In summary it take the rpc url and spin with anvil to simulate as they running on sepolia chain
    // it will pretend to deploy and read from the sepolia chain as opposed (instead of) to a completely blank chain (anvil)
    // It is a forked url, when we use the forked url, we gonna simulate what is on that actual chain
    // Which is a great way to easily test our contracts on an actual network
    // But the downside of it is that u gotta make a lot of api calls to ur alchemy node, which can run up ur bill
    // So it's best to write as many tests as possible as u can without any forking
    // But sadly, there's going to be a lot of tests that u have to run that can be only be done on a fork or using mocking

    // Coverage of testing of our code
    // Make we get plenty of coverage to test all of our contracts
    // Enter: forge coverage --rpc-url $SEPOLIA_RPC_URL
    // We can see how many lines of codes are actually tested

    // What we can do to work with addresses outside our system
    // 1. Uhit
    //    - Testing a specific part of our code
    // 2. Integration
    //    - Testing how our code works with other parts of our code
    // 3. Forked
    //    - Testing our code on a simulated real environment
    // 4. Staging
    //    = Testing our code in a real environment that is not prod

    // Test for the fund() function
    function testFundFailsWithoutEnoughETH() public {
        // The way that we can test something fails in foundry is that we can use one of those cheat codes
        // Check more on the foundry docs (cheat codes in test section or Cheatcodes Reference in Appendix section)
        // For here, we check out the assertion part in the cheatcodes reference and find expectRevert()
        vm.expectRevert(); // This tell that the next line should revert
        // Ex: uint256 cat = 1; // Run it as a test and u will find ur test fail as this line is not going to be reverted
        // U will get a failed with msg that said next call did not revert as expected
        // We need to do something that let it fail to pass the test

        // The below line won't be reverted as the value we put fulfills the require statement, 7 USD is more than 2 USD
        // fundMe.fund{value: 7e15}(); // the value is in wei, e15 is basically for Finney, which is another way of USD

        // This line will revert as we don't put any value to send in the fund() function
        fundMe.fund(); // We don't put any value to send in the fund() function, so it will revert and our test is passed
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // This line saying that the next transaction will be sent by USER
        fundMe.fund{value: VALUE_SENT}(); // We put 7 USD to fund the contract

        // Before creating USER
        // uint256 amountFunded = fundMe.getAddressToAmountFunded(address(this));

        // After creating USER
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);

        // Sometimes it's hard to know who is sending the transaction
        // It is confusing especially in our tests
        // To very explicitl that who is sending that transaction, we can use another cheatcode
        // assertEq(amountFunded, 7e15);
        assertEq(amountFunded, VALUE_SENT);
        // But u will still fail the fail as the USER account is out of fund
        // User must have some funds to send the transaction
        // To preventing potential issues such as negative balances or unpaid gas fees
        // U will pass the test after u fund the USER account
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER); // This line saying that the next transaction will be sent by USER
        fundMe.fund{value: VALUE_SENT}();
        assertEq(fundMe.getFundersAddress(0), USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: VALUE_SENT}();
        _;
    }

    // Test only owner can use the withdraw() function
    function testOnlyOwnerCanWithdraw() public funded {
        // We will first fund it with the USER account
        // vm.prank(USER); // This line saying that the next transaction will be sent by USER
        // fundMe.fund{value: VALUE_SENT}();
        // As the code is repeated in the above test function, we can just make it as a modifier, and call funded
        // To use it remember to put it on top of the function that u want to use it (after the public keyword)

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
        // It is funded once in the funded modifier
        // So lets add more funders
        uint160 numberOfFunders = 10;
        // Dont set it as 0, the reason here is bcs sometimes the zero address reverts and doesn't let u do stuff
        // So if u r running ur test, make sure that u r not sending stuff to the zero address
        // Bcs there're often sanity checks to make sure u dont do that
        uint160 startingFunderIndex = 1;
        // we should use uint160 at here as we r using address(i)
        // It will error if we cast explicitly from uint256 to address instead of from uint160 to address
        // @Extra u will get error also from address to uint256, should be uint160 to address
        // Ex: uint256 i = uint256(msg.sender); // It should be: uint256 i = uint256(uint160(msg.sender));
        // The reason for this is because uint160 has the same amount of bytes as an address
        // To easy understand, just remeber that if u want to use numbers to generate addresses, those numbers have to be uint160
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank new address
            // vm.deal new address
            hoax(address(i), 10 ether);
            fundMe.fund{value: VALUE_SENT}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        // Normal prank
        // vm.prank(fundMe.getOwner());
        // fundMe.withdraw();

        // // When working with anvil chain, the gas price actually defaults to zero
        // // So when working with a anvil chain be it forked or not, it actually defaults the gas price to zero
        // // If u want to simulate this transaction with actual gas price, we need to tell our test to pretend to use a real gas price
        // // by using the vm.txGasPrice() function
        // uint256 gasStart = gasleft(); // initial gas, which is 100%, we send gas
        // vm.txGasPrice(GAS_PRICE); // It is used to set the gas price for the next transaction
        // // vm.startPrank(fundMe.getOwner());
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        // // For example, the withdraw transaction only cost 80% of the gas we send
        // // vm.stopPrank(); // the start and stop prank use more gas, so we r not using in this case as we only have one transaction inside
        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; // tx.gasprice is another built-in in solidity which tell ur current gas price
        // // THE tx.gasprice is the gas price we put in here, line 253,
        // // Then we will have the 20% left of the gas as the transaction only take 80% of it
        // console.log(gasUsed);
        // // Derivative of prank
        // // It is basically same as vm.startBroadcast() and vm.stopBroadcast()
        // // Anything in between start prank and stop prank is going to be the one (address) who pretended to send transactions

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

// 11:59:20
