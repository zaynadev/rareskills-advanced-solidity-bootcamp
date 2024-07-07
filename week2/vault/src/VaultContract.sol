//SPDX-Licence-Identifier: MIT
pragma solidity 0.8.26;

import {ERC4626} from "openzeppelin-contracts/contracts/token/extensions/ERC4626.sol";

contract VaultContract is ERC4626 {
    constructor(address _asset) ERC4626(_asset) ERC20("Vault Token", "VT") {}
}
