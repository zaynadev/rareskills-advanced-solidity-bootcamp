//SPDX-Licence-Identifier: MIT
pragma solidity 0.8.26;

import {ERC4626} from "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC4626.sol";
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract VaultContract is ERC4626 {
    constructor(ERC20 _asset) ERC4626(_asset) ERC20("Vault Token", "VT") {}
}
