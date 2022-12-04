// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ShameCoin.sol";

contract ShameCoinTest is Test {
    ShameCoin private shameCoin;
    address private administrator;
    address private recipient;

    function setUp() public {
        recipient = address(0x1Db3439a222C519ab44bb1144fC28167b4Fa6EE6);
        administrator = address(0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84);
        vm.prank(administrator);
        shameCoin = new ShameCoin();
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
        uint recipientBalanceBefore = shameCoin.balanceOf(recipient);

        shameCoin.transfer(recipient, 1);

        // The administrator can send 1 shame coin at a time to other addresses
        // even though he passed amount as 2, only 1 is allowed
        assertEq(shameCoin.balanceOf(administrator), 10000 - 1);
        assertEq(shameCoin.balanceOf(recipient), recipientBalanceBefore + 1);
    }

    function testTransferMoreThanOneByAdministrator() public {
        vm.expectRevert("Administrator can send 1 coin at a time");
        shameCoin.transfer(recipient, 2);
    }

    // On non administrators transfer - increase their balance by one
    function testTransferByNonAdministrator() public {
        // send 1 coin to recipient so he has funds to send
        shameCoin.transfer(recipient, 1);
        assertEq(shameCoin.balanceOf(recipient), 1);

        uint adminBalanceBefore = shameCoin.balanceOf(administrator);

        vm.prank(recipient);
        shameCoin.transfer(administrator, 1);

        assertEq(shameCoin.balanceOf(administrator), adminBalanceBefore);
        assertEq(shameCoin.balanceOf(recipient), 2);
    }
}
