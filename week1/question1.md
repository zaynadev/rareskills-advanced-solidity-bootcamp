# What problems ERC777 and ERC1363 solves

They are both ERC20 tokens with extended functionalities.

## ERC1363

- Regular ERC20 architectures use the `approve` then `transferFrom` workflow, but with ERC-1363 it can be done in one transaction with `approveAndCall`.

- ERC20 does not have a native way to notify smart contracts when tokens are received. For a contract that wishes to be notified that they have received ERC-1363 tokens, they must implement IERC1363Receiver. This feature helps ensure that tokens sent to a contract are handled correctly and can trigger specific contract logic.

## ERC777

- Similar to ERC1363, ERC777 includes hooks for smart contracts to react to token transfers. It notify the sender and the receiver.

# Why was ERC1363 introduced

ERC1363 was introduced to extend the functionality of ERC20 tokens by simplifying interactions and enabling new use cases. Here are the main reasons for its introduction:

- ERC20 tokens require multiple transactions to authorize and transfer tokens for payments (approve and transferFrom), which can be cumbersome and expensive in terms of gas costs.

- ERC1363 introduces transferAndCall and approveAndCall functions, allowing tokens to be transferred and a contract to be notified in a single transaction.

# what issues are there with ERC777?

- The hooks and callbacks in ERC77 can be exploited by malicious actors to create reentrancy attacks.

- Registering interfaces with the ERC1820 registry requires additional gas. This registration step is necessary for the hooks and callbacks to function correctly, adding to the overall transaction cost.
