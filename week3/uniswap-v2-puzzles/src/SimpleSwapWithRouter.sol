// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "./interfaces/IUniswapV2Pair.sol";

contract SimpleSwapWithRouter {
    /**
     *  PERFORM A SIMPLE SWAP USING ROUTER EXERCISE
     *
     *  The contract has an initial balance of 1 ETH.
     *  The challenge is to swap any amount of ETH for USDC token using Uniswapv2 router.
     *
     */
    address public immutable router;
    // price feed mainnet address USDC/ETH
    address public priceFeed = 0x986b5E1e1755e3C2440e960477f25201B0a8bbD4;

    // 1 hour grace period
    uint256 public constant GRACE_PERIOD_SECONDS = 3600; // 1 hour
    // heartbeat 24 hours: the price is considered outdated after HEARTBEAT_SECONDS + GRACE_PERIOD_SECONDS
    uint256 public constant HEARTBEAT_SECONDS = 86400; //  24 hours

    error PriceIsOutdated();
    error PriceIsNegative();

    constructor(address _router) {
        router = _router;
    }

    function performSwapWithRouter(address[] calldata path, uint256 deadline) public {
        // amount of ETH in the contract
        uint256 amountETHIn = address(this).balance;

        // price of USDC in terms of ETH
        // 1 USDC =  ? ETH
        uint256 USDCPrice = getLatestPrice(priceFeed);

        //price of 1 ETH = ? USDC
        uint256 ETHPrice = 1e24 / USDCPrice;

        // amount of USDC optimal to receive
        uint256 AmountUSDCOut = (amountETHIn * ETHPrice) / 1e18;

        // tolerate 1% price impact
        uint256 AmountUSDCMin = (AmountUSDCOut * 99) / 100;

        // swap ETH for USDC
        IUniswapV2Router(router).swapExactETHForTokens{value: amountETHIn}(AmountUSDCMin, path, address(this), deadline);
    }

    /**
     * @notice  . Get the latest price from the Chainlink price feed.
     * @dev     . Check if the price has been updated within the acceptable time frame.
     * @return  price  . The latest price.
     */
    function getLatestPrice(address _priceFeed) public view returns (uint256) {
        // get the latest price using chainlink price feed
        (uint80 roundID, int256 price,, uint256 timestamp, uint80 answeredInRound) =
            AggregatorV3Interface(_priceFeed).latestRoundData();

        // Check if the price has been updated within the acceptable time frame
        if (block.timestamp - timestamp > HEARTBEAT_SECONDS + GRACE_PERIOD_SECONDS) {
            revert PriceIsOutdated();
        }

        // Check if the round is complete
        if (answeredInRound < roundID) {
            revert PriceIsOutdated();
        }

        // Check if the price is positive
        if (price <= 0) {
            revert PriceIsNegative();
        }

        return uint256(price);
    }

    receive() external payable {}
}

interface IUniswapV2Router {
    /**
     *     amountOutMin: the minimum amount of output tokens that must be received for the transaction not to revert.
     *     path: an array of token addresses. In our case, WETH and USDC.
     *     to: recipient address to receive the liquidity tokens.
     *     deadline: timestamp after which the transaction will revert.
     */
    function swapExactETHForTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline)
        external
        payable
        returns (uint256[] memory amounts);
}

interface AggregatorV3Interface {
    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}
