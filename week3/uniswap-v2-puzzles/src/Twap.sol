// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "./interfaces/IUniswapV2Pair.sol";

contract Twap {
    /**
     *  PERFORM A ONE-HOUR AND ONE-DAY TWAP
     *
     *  This contract includes four functions that are called at different intervals: the first two functions are 1 hour apart,
     *  while the last two are 1 day apart.
     *
     *  The challenge is to calculate the one-hour and one-day TWAP (Time-Weighted Average Price) of the first token in the
     *  given pool and store the results in the return variable.
     *
     *  Hint: For each time interval, the player needs to take a snapshot in the first function,
     *  then calculate the TWAP
     *  in the second function and divide it by the appropriate time interval.
     *
     */
    IUniswapV2Pair pool;

    // 1HourTWAP storage slots
    uint256 public first1HourSnapShot_Price0Cumulative;
    uint32 public first1HourSnapShot_TimeStamp;
    uint256 public second1HourSnapShot_Price0Cumulative;
    uint32 public second1HourSnapShot_TimeStamp;

    // 1DayTWAP storage slots
    uint256 public first1DaySnapShot_Price0Cumulative;
    uint32 public first1DaySnapShot_TimeStamp;
    uint256 public second1DaySnapShot_Price0Cumulative;
    uint32 public second1DaySnapShot_TimeStamp;

    uint224 constant Q112 = 2 ** 112;

    constructor(address _pool) {
        pool = IUniswapV2Pair(_pool);
    }

    //**       ONE HOUR TWAP START      **//
    function first1HourSnapShot() public {
        first1HourSnapShot_Price0Cumulative = pool.price0CumulativeLast();

        (,, first1HourSnapShot_TimeStamp) = pool.getReserves();
    }

    function second1HourSnapShot() public returns (uint224 oneHourTwap) {
        pool.sync();

        second1HourSnapShot_Price0Cumulative = pool.price0CumulativeLast();
        (,, second1HourSnapShot_TimeStamp) = pool.getReserves();

        oneHourTwap = uint224(
            (second1HourSnapShot_Price0Cumulative - first1HourSnapShot_Price0Cumulative)
                / ((second1HourSnapShot_TimeStamp - first1HourSnapShot_TimeStamp))
        );
        return oneHourTwap;
    }
    //**       ONE HOUR TWAP END      **//

    //**       ONE DAY TWAP START      **//

    function first1DaySnapShot() public {
        pool.sync();
        first1DaySnapShot_Price0Cumulative = pool.price0CumulativeLast();
        (,, first1DaySnapShot_TimeStamp) = pool.getReserves();
    }

    function second1DaySnapShot() public returns (uint224 oneDayTwap) {
        pool.sync();
        second1DaySnapShot_Price0Cumulative = pool.price0CumulativeLast();
        (,, second1DaySnapShot_TimeStamp) = pool.getReserves();

        oneDayTwap = uint224(
            (second1DaySnapShot_Price0Cumulative - first1DaySnapShot_Price0Cumulative)
                / ((second1DaySnapShot_TimeStamp - first1DaySnapShot_TimeStamp))
        );

        return (oneDayTwap);
    }
    //**       ONE DAY TWAP END      **//
}
