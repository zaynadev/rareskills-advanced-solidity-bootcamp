// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "./interfaces/IERC20.sol";

contract ExactSwapWithRouter {
    /**
     *  PERFORM AN EXACT SWAP WITH ROUTER EXERCISE
     *
     *  The contract has an initial balance of 1 WETH.
     *  The challenge is to swap an exact amount of WETH for 1337 USDC token using UniswapV2 router.
     *
     */
    address public immutable router;

    constructor(address _router) {
        router = _router;
    }

    function performExactSwapWithRouter(address weth, address usdc, uint256 deadline) public {
        // amount of USDC to receive
        uint256 amountUSDCOut = 1337e6;
        // build the path   WETH -> USDC
        address[] memory path = new address[](2);
        path[0] = weth;
        path[1] = usdc;
        // get the amount of WETH needed to swap for 1337 USDC
        uint256[] memory amounts = IUniswapV2Router(router).getAmountsIn(amountUSDCOut, path);
        // approve the router to spend the WETH
        IERC20(weth).approve(router, amounts[0]);
        // swap WETH for 1337 USDC
        IUniswapV2Router(router).swapExactTokensForTokens(amounts[0], amountUSDCOut, path, address(this), deadline);
    }
}

interface IUniswapV2Router {
    /**
     *     amountIn: the amount of input tokens to swap.
     *     amountOutMin: the minimum amount of output tokens that must be received for the transaction not to revert.
     *     path: an array of token addresses. In our case, WETH and USDC.
     *     to: recipient address to receive the liquidity tokens.
     *     deadline: timestamp after which the transaction will revert.
     */
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] memory path) external view returns (uint256[] memory amounts);
}
