// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IERC20.sol";

contract BurnLiquid {
    /**
     *  BURN LIQUIDITY WITHOUT ROUTER EXERCISE
     *
     *  The contract has an initial balance of 0.01 UNI-V2-LP tokens.
     *  Burn a position (remove liquidity) from USDC/ETH pool to this contract.
     *  The challenge is to use the `burn` function in the pool contract to remove all the liquidity from the pool.
     *
     */
    function burnLiquidity(address pool) public {
        /**
         *     burn(address to);
         *
         *     to: recipient address to receive tokenA and tokenB.
         */

        // Transfer all LP tokens to the pool contract
        IERC20(pool).transfer(pool, IERC20(pool).balanceOf(address(this)));
        // Burn all LP tokens and receive usdc and weth
        IUniswapV2Pair(pool).burn(address(this));
    }
}
