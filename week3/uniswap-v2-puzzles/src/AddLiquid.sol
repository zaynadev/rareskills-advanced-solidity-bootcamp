// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "./interfaces/IUniswapV2Pair.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract AddLiquid {
    error NotEnoughTokens();
    /**
     *  ADD LIQUIDITY WITHOUT ROUTER EXERCISE
     *
     *  The contract has an initial balance of 1000 USDC and 1 WETH.
     *  Mint a position (deposit liquidity) in the pool USDC/WETH to msg.sender.
     *  The challenge is to provide the same ratio as the pool then call the mint function in the pool contract.
     *
     */

    function addLiquidity(address usdc, address weth, address pool, uint256 usdcReserve, uint256 wethReserve) public {
        IUniswapV2Pair pair = IUniswapV2Pair(pool);

        // Get token balances owned by this contract
        uint256 amountUSDCDesired = IERC20(usdc).balanceOf(address(this));
        uint256 amountETHDesired = IERC20(weth).balanceOf(address(this));

        // Calculate the optimal amount of USDC to be sent to the pair
        // to get the same ratio as the pool
        uint256 amountUSDCOptimal = (amountETHDesired * usdcReserve) / wethReserve;

        // Check that the contract has enough amount of usdc to provide liquidity
        if (amountUSDCOptimal <= amountUSDCDesired) {
            // Transfer the tokens to the pair
            IERC20(usdc).transfer(address(pair), amountUSDCOptimal);
            IERC20(weth).transfer(address(pair), amountETHDesired);
        } else {
            // Otherwise calculate the optimal amount of weth to be sent to the pair
            uint256 amountETHOptimal = (amountUSDCDesired * wethReserve) / usdcReserve;
            // Check that the contract has enough amount of weth to provide liquidity
            if (amountETHOptimal <= amountETHDesired) {
                // Transfer the tokens to the pair
                IERC20(usdc).transfer(address(pair), amountUSDCDesired);
                IERC20(weth).transfer(address(pair), amountETHOptimal);
            } else {
                // This contract does not have enough tokens to provide liquidity
                revert NotEnoughTokens();
            }
        }

        // Mint the liquidity tokens to the msg.sender
        pair.mint(msg.sender);
    }
}
