// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// import  "@openzeppelin/contracts@4.9.6/token/ERC20/ERC20.sol" not working
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

/**
 * @author  . Zainab
 * @title   . TokenSale
 * @dev     . A token sale contract that allows users to buy and sell tokens.
 * @notice  . The price of the token increases and decrease linearly with the number of tokens sold.
 */
contract TokenSale is ERC20("TokenSale", "TSL") {
    // Variable to store the total tokens sold
    uint256 public totalTokensSold;

    error InsufficientEtherSent();
    error InsufficientTokensAvailable();

    /**
     * @notice  . Function to buy tokens.
     * @dev     . Calculates the cost of buying the tokens and mints tokens to the buyer.
     * @param   amount  . The number of tokens to buy.
     */
    function buyTokens(uint256 amount) external payable {
        // Calculate the cost of buying the tokens
        uint256 cost = getTokenBuyPrice(amount);
        // Check if the buyer has sent enough Ether
        require(msg.value == cost, InsufficientEtherSent());

        // Update the total tokens sold
        totalTokensSold += amount;

        // Mint tokens to the buyer
        _mint(msg.sender, amount);
    }

    /**
     * @notice  . Function to sell tokens.
     * @dev     . Calculates the price of selling the tokens and burns tokens from the seller.
     * @param   amount  . The number of tokens to sell.
     */
    function sellTokens(uint256 amount) external {
        // Check if the seller has enough tokens to sell
        require(amount <= totalTokensSold, InsufficientTokensAvailable());

        // Calculate sell price
        uint256 sellPrice = getTokenSellPrice(amount);

        // Burn tokens from the seller
        _burn(msg.sender, amount);
        // Update the total tokens sold
        totalTokensSold -= amount;

        // Transfer Ether to the seller
        payable(msg.sender).transfer(sellPrice);
    }

    /**
     * @notice  . Function to get the buy price of a given amount of tokens.
     * @dev     . The price of the token increases linearly with the number of tokens sold.
     * @param   amount  . The number of tokens to buy.
     * @return  uint256  . The total cost of buying the tokens.
     */
    function getTokenBuyPrice(uint256 amount) public view returns (uint256) {
        // The price of the token is equal to the total tokens sold
        /*
            if the amount to buy is 6, then
                price token 1 = 1 wei
                price token 2 = 2 wei
                price token 3 = 3 wei
                price token 4 = 4 wei
                price token 5 = 5 wei
                price token 6 = 6 wei
                totalPrice = 1 + 2 + 3 + 4 + 5 + 6 = 21 wei

        */
        uint256 currentPrice = totalTokensSold;

        // Calculate total price using arithmetic progression formula
        // The price of the token increases linearly with the number of tokens sold
        // Sum of last `amount` natural numbers: (price + 1) + (price + 2) + ... + (price + amount)
        return (amount * ((2 * currentPrice) + (amount + 1))) / 2;
    }

    /**
     * @notice  . Function to get the sell price of a given amount of tokens.
     * @dev     . The price of the token decreases linearly with the number of tokens sold.
     * @param   amount  . The number of tokens to sell.
     * @return  uint256  . The total price of selling the tokens.
     */
    function getTokenSellPrice(uint256 amount) public view returns (uint256) {
        // The price of the token is equal to the total tokens sold
        /* if totalTokensSold = 6 and amount to sell is 3, then
                price token 6 = 6 wei
                price token 5 = 5 wei
                price token 4 = 4 wei
                totalPrice = 6 + 5 + 4 = 15 wei
        */
        uint256 price = totalTokensSold;

        // Calculate total price using arithmetic progression formula
        // The price of the token decreases linearly with the number of tokens sold
        // Sum of last `amount` natural numbers: price + (price - 1) + (price - 2) + ... + (price - amount - 1)
        return (price * amount) - (amount * (amount - 1)) / 2;
    }

    /**
     * @notice  . Function to get the total tokens sold.
     * @return  uint256  . The total number of tokens sold.
     */
    function getTotalTokensSold() public view returns (uint256) {
        return totalTokensSold;
    }
}
