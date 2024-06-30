// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// import  "@openzeppelin/contracts@4.9.6/token/ERC20/ERC20.sol" not working
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
/**
 * @author  . Zainab
 * @title   . TokenSanction
 * @dev     . A token that can blacklist accounts from sending and receiving tokens.
 * @notice  . This contract is based on OpenZeppelin ERC20 contract.
 */

contract TokenSanction is ERC20("TokenSanction", "TS"), Ownable {
    // Mapping to store blacklisted accounts.
    mapping(address => bool) private blacklisted;

    event Blacklisted(address account);
    event UnBlacklisted(address account);

    error BlacklistedAccount();

    /**
     * @notice  . Modifier to check if an account is not blacklisted.
     * @dev     . Reverts if the account is blacklisted.
     * @param   _account  . The account to check.
     */
    modifier notBlacklisted(address _account) {
        require(blacklisted[_account] == false, BlacklistedAccount());
        _;
    }

    /**
     * @notice  . Blacklists an account.
     * @dev     . Only the owner can blacklist an account.
     * @param   _account  . The account to blacklist.
     */
    function blacklist(address _account) external onlyOwner {
        blacklisted[_account] = true;
        emit Blacklisted(_account);
    }

    /**
     * @notice  . Unblacklists an account.
     * @dev     . Only the owner can unblacklist an account.
     * @param   _account  . The account to unblacklist.
     */
    function unBlacklist(address _account) external onlyOwner {
        blacklisted[_account] = false;
        emit UnBlacklisted(_account);
    }

    /**
     * @notice  . Transfers tokens to a specified address.
     * @dev     . Overrides the transfer function of ERC20. Checks if the sender and receiver are not blacklisted.
     * @param   to  . The address to transfer tokens to.
     * @param   amount  . The amount of tokens to transfer.
     * @return  bool  . Returns true if the transfer is successful.
     */
    function transfer(address to, uint256 amount)
        public
        override
        notBlacklisted(msg.sender)
        notBlacklisted(to)
        returns (bool)
    {
        return super.transfer(to, amount);
    }

    /**
     * @notice  . Transfers tokens from one address to another.
     * @dev     .  Overrides the transferFrom function of ERC20. Checks if the sender, receiver, and owner are not blacklisted.
     * @param   from  . The address to transfer tokens from.
     * @param   to  . The address to transfer tokens to.
     * @param   amount  . The amount of tokens to transfer.
     * @return  bool  . Returns true if the transfer is successful.
     */
    function transferFrom(address from, address to, uint256 amount)
        public
        override
        notBlacklisted(to)
        notBlacklisted(msg.sender)
        notBlacklisted(from)
        returns (bool)
    {
        return super.transferFrom(from, to, amount);
    }

    /**
     * @notice  . Checks if an account is blacklisted.
     * @dev     . Returns true if the account is blacklisted.
     * @param   _account  . The account to check.
     * @return  bool  . Returns true if the account is blacklisted.
     */
    function isBlacklisted(address _account) public view returns (bool) {
        return blacklisted[_account];
    }
}
