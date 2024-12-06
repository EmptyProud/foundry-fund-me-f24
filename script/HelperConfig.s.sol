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

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    // It can return a configuration for everything we need in Sepolia
    function getSepoliaEthConfig()
        public
        pure
        returns (NetworkConfig memory priceFeed)
    {
        NetworkConfig memory sepoliaEthConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaEthConfig;
    }

    function getEthereumEthConfig()
        public
        pure
        returns (NetworkConfig memory priceFeed)
    {
        NetworkConfig memory ethereumEthConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethereumEthConfig;
    }

    function getOrCreateAnvilEthConfig()
        public
        returns (NetworkConfig memory priceFeed)
    {
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

        vm.startBroadcast();
        // we will deploy our own price feed here so we need a price feed contract
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        // Dont put this in the broadcast section as we r not going to deploy it on the anvil chain
        // In the broadcast section, we only deploy the mock price feed contract on anvil chain so that we can use it
        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}
