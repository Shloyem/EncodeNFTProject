// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ShameCoin.sol";

contract ShameCoinTest is Test {
    ShameCoin private shameCoin;
    address private administratorAddress;
    address private recipient;

    function setUp() public {
        recipient = address(0x1Db3439a222C519ab44bb1144fC28167b4Fa6EE6);
        administratorAddress = address(
            0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84
        );
        vm.prank(administratorAddress);
        shameCoin = new ShameCoin();
    }

    function testInitialTotalSupply() public {
        assertEq(shameCoin.totalSupply(), 10000);
    }

    function testDecimals() public {
        assertEq(shameCoin.decimals(), 0);
    }

    function testAdministrator() public {
        assertEq(shameCoin.administrator(), administratorAddress);
    }

    function testTransferByAdministrator() public {
        assertEq(shameCoin.balanceOf(administratorAddress), 10000);
        uint recipientBalanceBefore = shameCoin.balanceOf(recipient);

        shameCoin.transfer(recipient, 2);

        assertEq(shameCoin.balanceOf(administratorAddress), 10000 - 1);
        assertEq(shameCoin.balanceOf(recipient), balanceBefore + 1);
    }
}
