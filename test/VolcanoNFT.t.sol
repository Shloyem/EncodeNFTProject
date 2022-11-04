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
    uint constant NFT_ID = 1;
    uint constant ETH_PRICE = 0.01 ether;
    uint constant TOKENS_PRICE = 100;

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
        assertEq(volcanoNFT.ownerOf(NFT_ID), user1);
    }

    function testNotOwnerCantMint() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(user1);
        volcanoNFT.mint(user1);
    }

    function testHolderTransfer() public {
        volcanoNFT.mint(user1);
        assertEq(volcanoNFT.ownerOf(NFT_ID), user1);
        vm.prank(user1); // changed to user1 from owner
        volcanoNFT.transferFrom(user1, user2, NFT_ID);
        assertEq(volcanoNFT.ownerOf(NFT_ID), user2);
    }

    function testNotHolderCantTransfer() public {
        volcanoNFT.mint(user1);
        assertEq(volcanoNFT.ownerOf(NFT_ID), user1);
        vm.expectRevert("ERC721: caller is not token owner or approved");
        // attemp transfer from contract-owner but not NFT-owner or approved
        volcanoNFT.transferFrom(user1, user2, NFT_ID);

        vm.expectRevert("ERC721: caller is not token owner or approved");
        // attemp transfer from another user that is not the holder
        vm.prank(user2);
        volcanoNFT.transferFrom(user1, user2, NFT_ID);
    }

    function testApproveTransfer() public {
        volcanoNFT.mint(user1);
        assertEq(volcanoNFT.ownerOf(NFT_ID), user1);
        vm.prank(user1);
        volcanoNFT.approve(contractOwner, NFT_ID);
        vm.prank(contractOwner);
        volcanoNFT.transferFrom(user1, user2, NFT_ID);
        assertEq(volcanoNFT.ownerOf(NFT_ID), user2);
    }

    function testPayToMintFailures() public {
        // not sending ether or token
        vm.expectRevert("VolcanoNFT: couldnt charge eth or token");
        vm.prank(user1);
        volcanoNFT.payToMint(user1);

        // sending too little eth
        vm.deal(address(user1), ETH_PRICE);
        vm.expectRevert("VolcanoNFT: couldnt charge eth or token");
        vm.prank(user1);
        uint notEnoughEth = ETH_PRICE - 0.0001 ether;
        volcanoNFT.payToMint{value: notEnoughEth}(user1);

        // sending too little Token
        uint notEnoughTokens = TOKENS_PRICE - 1;
        vm.prank(contractOwner);
        volcanoCoin.transfer(notEnoughTokens, user1);
        vm.startPrank(user1);
        volcanoCoin.approve(address(volcanoNFT), notEnoughTokens);
        vm.expectRevert("VolcanoNFT: couldnt charge eth or token");
        volcanoNFT.payToMint(user1);
    }

    function testEtherPayToMintPasses() public {
        vm.deal(address(user1), ETH_PRICE);

        vm.expectRevert("ERC721: invalid token ID");
        assertTrue(volcanoNFT.ownerOf(NFT_ID) != user1);

        vm.prank(user1);
        volcanoNFT.payToMint{value: ETH_PRICE}(user1);

        assertEq(volcanoNFT.ownerOf(NFT_ID), user1);
    }

    function testEtherPayToMintReturnsExtraEth() public {
        vm.deal(address(user1), 1 ether);

        vm.expectRevert("ERC721: invalid token ID");
        assertTrue(volcanoNFT.ownerOf(NFT_ID) != user1);

        vm.prank(user1);
        volcanoNFT.payToMint{value: 1 ether}(user1);

        assertEq(volcanoNFT.ownerOf(NFT_ID), user1);
        assertEq(address(user1).balance, 0.99 ether);
    }

    function testTokensPayToMintPasses() public {
        vm.expectRevert("ERC721: invalid token ID");
        assertTrue(volcanoNFT.ownerOf(NFT_ID) != user1);

        vm.prank(contractOwner);
        volcanoCoin.transfer(TOKENS_PRICE, user1);

        vm.startPrank(user1);
        volcanoCoin.approve(address(volcanoNFT), TOKENS_PRICE);
        volcanoNFT.payToMint(user1);

        assertEq(volcanoNFT.ownerOf(NFT_ID), user1);
    }

    function testURI() public {
        volcanoNFT.mint(user1);

        string memory baseUri = "https://amazingURI.io/";
        string memory tokenUri = volcanoNFT.tokenURI(NFT_ID);
        assertEq(
            tokenUri,
            string.concat(
                baseUri,
                "1" /*NFT_ID*/
            )
        );
    }
}
