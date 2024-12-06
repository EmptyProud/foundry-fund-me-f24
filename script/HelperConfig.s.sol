// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// As this is a script so u need to import the Script.sol
import {Script} from "forge-std/Script.sol";

// We need to use it as our price feed address in our anvil chain
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is
    Script // The script contract will let us have the access for the vm keyword
{
    uint8 public constant DECIMALS = 8; // The decimal of USD, decimal is uint8
    int256 public constant INITIAL_PRICE = 2000e8; // The initial price of the price feed contract
    // We can set this variable to whichever one of the configs that fits with the active network that we're on
    NetworkConfig public activeNetworkConfig;

    // This is the way that how we set up the active network config which is based on the chain id
    constructor() {
        if (block.chainid == 11155111) {
            // Sepolia chain id
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            // Ethereum mainnet chain id
            activeNetworkConfig = getEthereumEthConfig();
        } else if (block.chainid == 31337) {
            // Anvil chain id
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    // 1. Deploy local mocks when we are on our local chain
    // 2. Keep track of contract addresses across different chains
    // Sepolia ETH/USD: 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
    // Ethereum ETH/USD: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
    // With setting up this helper config correctly, we can work with local chain and work with any chain we want to

    // Summary
    // If we r on a local anvil, we deploy mocks
    // Otherwise, grab the existing address from the live network

    // What if we have a whole bunch of stuff we need, maybe price feed address, vrf address, gas price, etc
    // Solution: turn this config into its own type
    struct NetworkConfig {
        // But for now, we only need one, which is the price feed address
        address priceFeed; // ETH/USD price feed address
    }

    // It gonna return a configuration for everything we need in Sepolia
    function getSepoliaEthConfig() public pure returns (NetworkConfig memory priceFeed) {
        // Need to use memory as it is a special object
        // We need price feed address
        NetworkConfig memory sepoliaEthConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        // U create an instance of the struct and u set the price feed address to the address that we want

        // or we can use this way, patrick use the above way as it is more explicit
        // NetworkConfig memory getSepoliaEthConfig = NetworkConfig(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return sepoliaEthConfig;
    }

    function getEthereumEthConfig() public pure returns (NetworkConfig memory priceFeed) {
        NetworkConfig memory ethereumEthConfig = NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return ethereumEthConfig;
    }

    // function getAnvilEthConfig() public returns(NetworkConfig memory priceFeed){
    // Also changing the function name as we also deploy the mock price feed contract on the anvil chain
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory priceFeed) {
        // Add one more thing to this anvil config to avoid deploying one more new price feed contract if we already have one
        if (activeNetworkConfig.priceFeed != address(0)) {
            // This checks that have we set the price feed up to something other than 0
            // Address defaults to address(0), so if it is not address(0), means that we've already set it up
            return activeNetworkConfig;
        }

        // We also need the price feed address
        // In local network, those contract doesnt exist
        // So we're going to deploy those contracts ourselves on the anvil config
        // Steps:
        // 1. Deploy the mocks (it basically a fake contract, it's real but it's a contract that we owned and can control)
        // 2. Return the mock address

        vm.startBroadcast(); // This way we can actually deploy these mock contracts to the anvil chain
        // @notice as we r using the vm keyword, we actually can't have this function as pure
        // we will deploy our own price feed here so we need a price feed contract
        // Create a new folder called mocks in ur test/ folder, which will put all the contracts that we need to do for testing
        // We have one older version of the mockV3Aggregator.sol in the brownie-contracts folder but the solidity version is 0.6.0
        // So we copy the new version of the mockV3Aggregator.sol from patrick's repo
        // and import it at here
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE); // it takes a decimal n initial ans in the constructor
        // We knwo the decimal of USD is 8 and the initial answer is PRICEe8 as the decimal of USD is 8
        vm.stopBroadcast();

        // Dont put this in the broadcast section as we r not going to deploy it on the anvil chain
        // In the broadcast section, we only deploy the mock price feed contract on anvil chain so that we can use it
        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
        return anvilConfig;
    }
}
