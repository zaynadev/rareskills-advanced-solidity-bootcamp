# Solidity contract 4: (hard) Untrusted escrow.

## what issues do you need to defend against?

. Reentrancy attacks: The contract uses OpenZeppelin's ReentrancyGuard and the nonReentrant modifier on critical functions to prevent reentrancy attacks.
. Token transfer failures: The contract uses OpenZeppelin's SafeERC20 library, which handles transfer failures and reverts the transaction if the transfer is unsuccessful.

## Does your contract handle fee-on transfer tokens or non-standard ERC20 tokens.

. Fee-on-transfer tokens: The contract calculates the actual amount received by checking the balance before and after the transfer. This ensures that the correct amount is recorded even for fee-on-transfer tokens.
. Rebasing tokens: Tokens that automatically adjust balances (like some algorithmic stablecoins) could cause issues, as the balance in the contract might change unexpectedly.
. Tokens with blocklists: If a token contract can blacklist addresses, it might prevent the escrow contract from transferring tokens at release time.
