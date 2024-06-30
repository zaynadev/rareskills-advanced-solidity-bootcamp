// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// import  "@openzeppelin/contracts@4.9.6/token/ERC20/ERC20.sol" not working
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

/**
 * @author  . Zainab
 * @title   . TokenGodMode
 * @dev     . A token that allows a special address to transfer tokens.
 * @notice  . This contract is based on OpenZeppelin ERC20 contract.
 */
contract TokenGodMode is ERC20("TokenGodMode", "TGM"), Ownable {
    // The special address that can transfer tokens.
    address private specialAddress;

    error NotSpecialAddress();
    error ZeroAddress();

    /**
     * @notice  . Modifier to check if the sender is the special address.
     * @dev     . Reverts if the sender is not the special address.
     */
    modifier onlySpecialAddress() {
        require(msg.sender == specialAddress, NotSpecialAddress());
        _;
    }

    /**
     * @notice  . Sets the special address.
     * @dev     . Only the owner can set the special address.
     * @param   _specialAddress  . The address to set as special.
     */
    function setSpecialAddress(address _specialAddress) external onlyOwner {
        require(_specialAddress != address(0), ZeroAddress());
        specialAddress = _specialAddress;
    }

    /**
     * @notice  . Transfers tokens to a specified address.
     * @dev     . Overrides the transfer function of ERC20. Checks if the sender is the special address.
     * @param   from  . The address to transfer tokens from.
     * @param   to  . The address to transfer tokens to.
     * @param   amount  . The amount of tokens to transfer.
     */
    function specialTransfer(address from, address to, uint256 amount) external onlySpecialAddress {
        _transfer(from, to, amount);
    }
}
