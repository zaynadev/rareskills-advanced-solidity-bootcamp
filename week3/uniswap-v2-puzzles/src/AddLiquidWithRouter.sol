// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "./interfaces/IUniswapV2Pair.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract AddLiquidWithRouter {
    /**
     *  ADD LIQUIDITY WITH ROUTER EXERCISE
     *
     *  The contract has an initial balance of 1000 USDC and 1 ETH.
     *  Mint a position (deposit liquidity) in the pool USDC/ETH to `msg.sender`.
     *  The challenge is to use Uniswapv2 router to add liquidity to the pool.
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

    /**
     * @notice  . Add liquidity to the pool USDC/ETH using the Uniswapv2 router.
     * @dev     . The contract has an initial balance of 1000 USDC and 1 ETH.
     * @param   usdcAddress  . The USDC address.
     * @param   deadline  . The timestamp after which the transaction will revert.
     */
    function addLiquidityWithRouter(address usdcAddress, uint256 deadline) public {
        // amount of USDC and ETH in the contract
        uint256 amountUSDCDesired = IERC20(usdcAddress).balanceOf(address(this));
        uint256 amountETHDesired = address(this).balance;

        // price of USDC in terms of ETH
        // 1 USDC =  ? ETH
        uint256 price = getLatestPrice(priceFeed);

        // amount of ETH optimal to add as liquidity
        // 1e6 * 1e18 / 1e6 = 1e18
        uint256 amountETHOptimal = (amountUSDCDesired * price) / 1e6;

        // tolerate 1% price impact
        uint256 amountUSDCMin = (amountUSDCDesired * 99) / 100;
        uint256 amountETHMin =
            amountETHOptimal <= amountETHDesired ? (amountETHOptimal * 99) / 100 : (amountETHDesired * 99) / 100;

        // approve USDC to the router
        IERC20(usdcAddress).approve(router, amountUSDCDesired);

        // add liquidity to the pool USDC/ETH
        IUniswapV2Router(router).addLiquidityETH{value: amountETHDesired}(
            usdcAddress, amountUSDCDesired, amountUSDCMin, amountETHMin, msg.sender, deadline
        );
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
     *     token: the usdc address
     *     amountTokenDesired: the amount of USDC to add as liquidity.
     *     amountTokenMin: bounds the extent to which the ETH/USDC price can go up before the transaction reverts. Must be <= amountUSDCDesired.
     *     amountETHMin: bounds the extent to which the USDC/ETH price can go up before the transaction reverts. Must be <= amountETHDesired.
     *     to: recipient address to receive the liquidity tokens.
     *     deadline: timestamp after which the transaction will revert.
     */
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

interface AggregatorV3Interface {
    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}
