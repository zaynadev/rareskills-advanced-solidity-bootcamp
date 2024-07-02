// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

contract UntustedEscrow is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    // Struct to store the escrow details.
    struct Escrow {
        address token;
        uint256 amount;
        address buyer;
        address seller;
        uint256 releaseTime;
        bool isReleased;
    }

    // Mapping to store the escrows. The key is the ID of the escrow.
    mapping(uint256 => Escrow) public escrows;
    uint256 public nextEscrowId;

    // Mapping to store whitelisted tokens.
    mapping(address => bool) public whitelistedTokens;

    event EscrowCreated(
        uint256 indexed escrowId, address indexed buyer, address indexed seller, address token, uint256 amount
    );
    event EscrowReleased(uint256 indexed escrowId);
    event EscrowRefunded(uint256 indexed escrowId);
    event TokenWhitelisted(address indexed token);
    event TokenRemovedFromWhitelist(address indexed token);

    error InvalidTokenAddress();
    error ZeroAmount();
    error InvalidSellerAddress();
    error TokenNotWhitelisted();
    error NoTokensReceived();
    error OnlySellerCanWithdraw();
    error TooEarlyToWithdraw();
    error EscrowAlreadyWithdraw();

    constructor() {
        nextEscrowId = 1;
    }

    /**
     * @notice  . Function to create an escrow.
     * @dev     . Transfers tokens from the buyer to the contract.
     * @param   _token  . The address of the token to escrow.
     * @param   _amount  . The amount of tokens to escrow.
     * @param   _seller  . The address of the seller. The seller can withdraw the tokens after the release time.
     */
    function createEscrow(address _token, uint256 _amount, address _seller) external nonReentrant {
        require(_token != address(0), InvalidTokenAddress());
        require(_amount > 0, ZeroAmount());
        require(_seller != address(0), InvalidSellerAddress());
        require(whitelistedTokens[_token], TokenNotWhitelisted());

        IERC20 token = IERC20(_token);
        uint256 balanceBefore = token.balanceOf(address(this));
        token.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 balanceAfter = token.balanceOf(address(this));
        uint256 actualAmount = balanceAfter - balanceBefore;

        require(actualAmount > 0, NoTokensReceived());

        uint256 escrowId = nextEscrowId++;
        escrows[escrowId] = Escrow({
            token: _token,
            amount: actualAmount,
            buyer: msg.sender,
            seller: _seller,
            releaseTime: block.timestamp + 3 days,
            isReleased: false
        });

        emit EscrowCreated(escrowId, msg.sender, _seller, _token, actualAmount);
    }

    /**
     * @notice  . Function to withdraw tokens from the escrow.
     * @dev     . Only the seller can withdraw the tokens after the release time.
     * @param   _escrowId  . The ID of the escrow.
     */
    function withdrawEscrow(uint256 _escrowId) external nonReentrant {
        Escrow storage escrow = escrows[_escrowId];
        require(msg.sender == escrow.seller, OnlySellerCanWithdraw());
        require(block.timestamp >= escrow.releaseTime, TooEarlyToWithdraw());
        require(!escrow.isReleased, EscrowAlreadyWithdraw());

        escrow.isReleased = true;
        IERC20(escrow.token).safeTransfer(escrow.seller, escrow.amount);

        emit EscrowReleased(_escrowId);
    }

    /**
     * @notice  . Function to whitelist a token.
     * @dev     . Only the owner can whitelist a token.
     * @param   _token  . The address of the token to whitelist.
     */
    function whitelistToken(address _token) external onlyOwner {
        require(_token != address(0), InvalidTokenAddress());
        whitelistedTokens[_token] = true;
        emit TokenWhitelisted(_token);
    }

    /**
     * @notice  . Function to remove a token from the whitelist.
     * @dev     . Only the owner can remove a token from the whitelist.
     * @param   _token  . The address of the token to remove from the whitelist.
     */
    function removeTokenFromWhitelist(address _token) external onlyOwner {
        require(_token != address(0), InvalidTokenAddress());
        whitelistedTokens[_token] = false;
        emit TokenRemovedFromWhitelist(_token);
    }
}
