// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IERC20.sol";

contract SimpleSwap {
    error InsufficientInputAmount();
    error InsufficientLiquidity();
    /**
     *  PERFORM A SIMPLE SWAP WITHOUT ROUTER EXERCISE
     *
     *  The contract has an initial balance of 1 WETH.
     *  The challenge is to swap any amount of WETH for USDC token using the `swap` function
     *  from USDC/WETH pool.
     *
     */

    function performSwap(address pool, address weth, address usdc) public {
        /**
         *     swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data);
         *
         *     amount0Out: the amount of USDC to receive from swap.
         *     amount1Out: the amount of WETH to receive from swap.
         *     to: recipient address to receive the USDC tokens.
         *     data: leave it empty.
         */
        // Get WETH balance of this contract
        uint256 amountWETHIn = IERC20(weth).balanceOf(address(this));
        // Get reserves USDC and WETH from pool, token0 is USDC and token1 is WETH
        (uint256 reserveUSDC, uint256 reserveWETH,) = IUniswapV2Pair(pool).getReserves();
        // Calculate amount of USDC to receive using getAmountOut function from UniswapV2Library
        uint256 amountUSDCOut = getAmountOut(amountWETHIn, reserveWETH, reserveUSDC);
        // Transfer all WETH to pool
        IERC20(weth).transfer(pool, amountWETHIn);
        // Perform swap weth -> usdc
        IUniswapV2Pair(pool).swap(amountUSDCOut, 0, address(this), "");

        // @TODO: need slippage check
    }

    /**
     * @notice  . Given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
     * @dev     . Uniswap v2 getAmountOut function from UniswapV2Library.
     * @param   amountIn  . The amount of asset being swapped in.
     * @param   reserveIn  . The input asset reserve.
     * @param   reserveOut  . The output asset reserve.
     * @return  amountOut  . The amount of asset received after the swap.
     */
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut)
        internal
        pure
        returns (uint256 amountOut)
    {
        require(amountIn > 0, InsufficientInputAmount());
        require(reserveIn > 0 && reserveOut > 0, InsufficientLiquidity());
        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = (reserveIn * 1000) + amountInWithFee;
        amountOut = numerator / denominator;
    }
}
