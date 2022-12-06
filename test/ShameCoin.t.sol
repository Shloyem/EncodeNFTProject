// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ShameCoin.sol";

contract ShameCoinTest is Test {
    ShameCoin private shameCoin;
    address private administrator;
    address private recipient1;
    address private recipient2;

    function setUp() public {
        recipient1 = address(0x1Db3439a222C519ab44bb1144fC28167b4Fa6EE6);
        recipient2 = address(0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045);
        administrator = address(0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84);
        vm.prank(administrator);
        shameCoin = new ShameCoin();
    }

    function fundRecipientWithCoin() public {
        // send 1 coin to recipient so he has funds to send
        shameCoin.transfer(recipient1, 1);
        assertEq(shameCoin.balanceOf(recipient1), 1);
    }

    function testInitialTotalSupply() public {
        assertEq(shameCoin.totalSupply(), 10000);
    }

    function testDecimals() public {
        assertEq(shameCoin.decimals(), 0);
    }

    function testAdministrator() public {
        assertEq(shameCoin.administrator(), administrator);
    }

    function testTransferOneByAdministrator() public {
        assertEq(shameCoin.balanceOf(administrator), 10000);
        uint recipientBalanceBefore = shameCoin.balanceOf(recipient1);

        shameCoin.transfer(recipient1, 1);

        // The administrator can send 1 shame coin at a time to other addresses
        // even though he passed amount as 2, only 1 is allowed
        assertEq(shameCoin.balanceOf(administrator), 10000 - 1);
        assertEq(shameCoin.balanceOf(recipient1), recipientBalanceBefore + 1);
    }

    function testTransferMoreThanOneByAdministrator() public {
        vm.expectRevert("Administrator can send 1 coin at a time");
        shameCoin.transfer(recipient1, 2);
    }

    // On non administrators transfer - increase their balance by one
    function testTransferByNonAdministrator() public {
        fundRecipientWithCoin();
        uint adminBalanceBefore = shameCoin.balanceOf(administrator);

        vm.prank(recipient1);
        shameCoin.transfer(administrator, 1);

        assertEq(shameCoin.balanceOf(administrator), adminBalanceBefore);
        assertEq(shameCoin.balanceOf(recipient1), 2);
    }

    function testNonAdministratorsApproveAdministrator() public {
        fundRecipientWithCoin();
        assertEq(shameCoin.balanceOf(recipient1), 1);
        assertEq(shameCoin.balanceOf(recipient2), 0);

        vm.prank(recipient1);
        shameCoin.approve(administrator, 1);

        assertEq(shameCoin.allowance(recipient1, administrator), 1);
    }

    function testNonAdministratorsApproveNonAdministrator() public {
        fundRecipientWithCoin();
        assertEq(shameCoin.balanceOf(recipient1), 1);
        assertEq(shameCoin.balanceOf(recipient2), 0);

        vm.prank(recipient1);
        vm.expectRevert("Spender is not the administrator");
        shameCoin.approve(recipient2, 1);
    }
}
