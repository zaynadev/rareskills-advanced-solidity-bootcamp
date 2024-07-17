// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IERC20.sol";

contract ExactSwap {
    /**
     *  PERFORM AN SIMPLE SWAP WITHOUT ROUTER EXERCISE
     *
     *  The contract has an initial balance of 1 WETH.
     *  The challenge is to swap an exact amount of WETH for 1337 USDC token using the `swap` function
     *  from USDC/WETH pool.
     *
     */
    function performExactSwap(address pool, address weth, address usdc) public {
        /**
         *     swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data);
         *
         *     amount0Out: the amount of USDC to receive from swap.
         *     amount1Out: the amount of WETH to receive from swap.
         *     to: recipient address to receive the USDC tokens.
         *     data: leave it empty.
         */

        // USDC amount to receive
        uint256 amountUSDCOut = 1337 * 1e6;

        // get USDC and WETH reserves from the pool
        (uint256 reserveUSDC, uint256 reserveETH,) = IUniswapV2Pair(pool).getReserves();

        // calculate the amount of WETH to swap using the getAmountIn function from UniswapV2Library
        uint256 amountEthIn = getAmountIn(amountUSDCOut, reserveETH, reserveUSDC);

        // transfer the WETH to the pool
        IERC20(weth).transfer(pool, amountEthIn);

        // perform the swap
        IUniswapV2Pair(pool).swap(amountUSDCOut, 0, address(this), "");
    }

    /**
     * @notice  . Given an output amount of an asset and pair reserves, returns a required input amount of the other asset
     * @dev     . Uniswap v2 getAmountIn function from UniswapV2Library.
     * @param   amountOut  . The amount of asset being swapped out.
     * @param   reserveIn  . The input asset reserve.
     * @param   reserveOut  . The output asset reserve.
     * @return  amountIn  .  The amount of asset required to be swapped in.
     */
    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut)
        internal
        pure
        returns (uint256 amountIn)
    {
        require(amountOut > 0, "UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        uint256 numerator = reserveIn * amountOut * 1000;
        uint256 denominator = (reserveOut - amountOut) * 997;
        amountIn = (numerator / denominator) + 1;
    }
}
