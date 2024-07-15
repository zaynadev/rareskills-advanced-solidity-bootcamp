// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IERC20.sol";

contract BurnLiquidWithRouter {
    /**
     *  BURN LIQUIDITY WITH ROUTER EXERCISE
     *
     *  The contract has an initial balance of 0.01 UNI-V2-LP tokens.
     *  Burn a position (remove liquidity) from USDC/ETH pool to this contract.
     *  The challenge is to use Uniswapv2 router to remove all the liquidity from the pool.
     *
     */
    address public immutable router;

    constructor(address _router) {
        router = _router;
    }

    function burnLiquidityWithRouter(address pool, address usdc, address weth, uint256 deadline) public {
        // Get the amount of liquidity tokens in the contract.
        uint256 liquidity = IERC20(pool).balanceOf(address(this));
        // Get the total supply of liquidity tokens.
        uint256 totalSupply = IERC20(pool).totalSupply();

        // Get the balance of USDC and WETH in the pool.
        uint256 usdcBalance = IERC20(usdc).balanceOf(pool);
        uint256 wethBalance = IERC20(weth).balanceOf(pool);

        // Calculate the minimum amount of USDC and WETH to receive.
        uint256 amountUSDCMin = (liquidity * usdcBalance) / totalSupply;
        uint256 amountWETHMin = (liquidity * wethBalance) / totalSupply;

        // Approve the router to spend the liquidity tokens.
        IERC20(pool).approve(router, liquidity);
        // Remove liquidity from the pool.
        IUniswapV2Router(router).removeLiquidity(
            usdc, weth, liquidity, amountUSDCMin, amountWETHMin, address(this), deadline
        );
    }
}

interface IUniswapV2Router {
    /**
     *     tokenA: the address of tokenA, in our case, USDC.
     *     tokenB: the address of tokenB, in our case, WETH.
     *     liquidity: the amount of LP tokens to burn.
     *     amountAMin: the minimum amount of amountA to receive.
     *     amountBMin: the minimum amount of amountB to receive.
     *     to: recipient address to receive tokenA and tokenB.
     *     deadline: timestamp after which the transaction will revert.
     */
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);
}
