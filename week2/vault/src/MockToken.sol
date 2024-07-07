//SPDX-Licence-Identifier: MIT
pragma solidity 0.8.26;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
    constructor() ERC20("MockToken", "MT") {
        _mint(msg.sender, 1_000_000 * 10 ** decimals());
    }
}
