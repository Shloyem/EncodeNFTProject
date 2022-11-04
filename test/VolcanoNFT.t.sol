// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/VolcanoNFT.sol";
import "../src/VolcanoCoin.sol";
import "../src/ERC721Receiver.sol";

contract VolcanoNFTTest is Test {
    address public contractOwner;
    address public user1;
    address public user2;
    VolcanoNFT private volcanoNFT;
    VolcanoCoin private volcanoCoin;
    ERC721Receiver private erc721Receiver1;
    ERC721Receiver private erc721Receiver2;
    uint nftId = 1;

    function setUp() public {
        volcanoCoin = new VolcanoCoin();
        volcanoNFT = new VolcanoNFT(address(volcanoCoin));
        erc721Receiver1 = new ERC721Receiver();
        erc721Receiver2 = new ERC721Receiver();
        contractOwner = address(this);
        user1 = address(erc721Receiver1);
        user2 = address(erc721Receiver2);
    }

    function testNameAndSymbol() public {
        assertEq(volcanoNFT.name(), "AwesomeVolcanoNft");
        assertEq(volcanoNFT.symbol(), "AVN");
    }

    function testMint() public {
        volcanoNFT.mint(user1);
        assertEq(volcanoNFT.ownerOf(nftId), user1);
    }

    function testNotOwnerCantMint() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(user1);
        volcanoNFT.mint(user1);
    }

    function testHolderTransfer() public {
        volcanoNFT.mint(user1);
        assertEq(volcanoNFT.ownerOf(nftId), user1);
        vm.prank(user1); // changed to user1 from owner
        volcanoNFT.transferFrom(user1, user2, nftId);
        assertEq(volcanoNFT.ownerOf(nftId), user2);
    }

    function testNotHolderCantTransfer() public {
        volcanoNFT.mint(user1);
        assertEq(volcanoNFT.ownerOf(nftId), user1);
        vm.expectRevert("ERC721: caller is not token owner or approved");
        // attemp transfer from contract-owner but not NFT-owner or approved
        volcanoNFT.transferFrom(user1, user2, nftId);

        vm.expectRevert("ERC721: caller is not token owner or approved");
        // attemp transfer from another user that is not the holder
        vm.prank(user2);
        volcanoNFT.transferFrom(user1, user2, nftId);
    }

    function testApproveTransfer() public {
        volcanoNFT.mint(user1);
        assertEq(volcanoNFT.ownerOf(nftId), user1);
        vm.prank(user1);
        volcanoNFT.approve(contractOwner, nftId);
        vm.prank(contractOwner);
        volcanoNFT.transferFrom(user1, user2, nftId);
        assertEq(volcanoNFT.ownerOf(nftId), user2);
    }
}
