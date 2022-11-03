// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/VolcanoCoin.sol";

contract VolcanoCoinTest is Test {
    VolcanoCoin private volcanoCoin;

    function setUp() public {
        volcanoCoin = new VolcanoCoin();
    }

    function testInitialTotalSupply() public {
        assertEq(volcanoCoin.totalSupply(), 10000);
    }

    function testTotalSupplyIncrease() public {
        assertEq(volcanoCoin.totalSupply(), 10000);
        volcanoCoin.increaseTotalSupply();
        assertEq(volcanoCoin.totalSupply(), 10000 + 1000);
    }

    function testOnlyOwnerIncreases(uint256 x) public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(address(0));
        volcanoCoin.increaseTotalSupply();
    }
}
