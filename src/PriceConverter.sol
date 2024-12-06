// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    // Set ur input parameter to AggregatorV3Interface instant that u created in ur FundMe contract
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        (, int256 price,,,) = priceFeed.latestRoundData();
        return uint256(price * 1e10);
    }

    // add one more input parameter to ur function, AggregatorV3Interface priceFeed as u need to use it in getPrice function
    function convertToUSD(uint256 EthAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        uint256 price = getPrice(priceFeed);
        uint256 EthValueInUSD = (EthAmount * price) / 1e18;
        return EthValueInUSD;
    }
}
