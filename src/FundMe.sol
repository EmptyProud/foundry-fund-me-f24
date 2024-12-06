// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    mapping(address funder => uint256 amountFunded)
        private s_addressToAmountFunded;
    address[] private s_fundersAddress;

    address private immutable i_owner;
    uint256 public constant MINIMUM_USD = 2e18;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        require(
            msg.value.convertToUSD(s_priceFeed) > MINIMUM_USD,
            "You didn't reach the minimum fund amount."
        );

        s_fundersAddress.push(msg.sender);

        s_addressToAmountFunded[msg.sender] =
            s_addressToAmountFunded[msg.sender] +
            msg.value;
    }

    function getVersion() public returns (uint256) {
        HelperConfig helperConfig = new HelperConfig();
        address ethVersion = helperConfig.activeNetworkConfig();
        return AggregatorV3Interface(ethVersion).version();
    }

    modifier onlyAdmin() {
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    function withdraw() public onlyAdmin {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_fundersAddress.length;
            funderIndex++
        ) {
            s_addressToAmountFunded[s_fundersAddress[funderIndex]] = 0;
        }

        s_fundersAddress = new address[](0);

        (bool callStatus, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callStatus, "Fail transaction.");
    }

    function cheaperWithdraw() public onlyAdmin {
        // For gas efficient, We read the length one time only from the storage and read one more time for every loop
        uint256 fundersAddressLength = s_fundersAddress.length;
        for (
            uint256 funderIndex = 0;
            funderIndex < fundersAddressLength;
            funderIndex++
        ) {
            s_addressToAmountFunded[s_fundersAddress[funderIndex]] = 0;
        }
        s_fundersAddress = new address[](0);

        (bool callStatus, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callStatus, "Fail transaction.");
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /**
     * View / Pure functions (Getters)
     */

    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFundersAddress(uint256 index) external view returns (address) {
        return s_fundersAddress[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
