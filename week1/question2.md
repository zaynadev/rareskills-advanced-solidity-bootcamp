## Why does the SafeERC20 program exist and when should it be used?

Not all tokens adhere to the ERC20 standard strictly. Some tokens:

- Return a boolean value to indicate success or failure.
- Revert or throw an exception on failure.
- Return no value at all, assuming that the call succeeded if it doesn't revert.

SafeERC20 ensures that token operations like transfers, approvals, and transfers from are performed safely :

1. First, it Uses the `call` opcode to invoke a function on the token contract with the provided data.
2. If the call was not successful, it reverts the transaction.
3. Otherwise, it retrieves the size of the returned data `returnSize` and loads the first word of the returned data into `returnValue`.
4. If `returnSize` is zero (indicating no return data), it checks if the token contract exists `.code.length == 0`. If `returnValue` is not 1, it reverts with a custom error message indicating a failed operation.
