// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/access/Ownable.sol";
import "openzeppelin-contracts/utils/Counters.sol";

// import "@openzeppelin/contracts/token/ERC721/ERC721.sol"; // if using remix / npm
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";

contract VolcanoNFT is ERC721, Ownable {
    using Counters for Counters.Counter;
    address public coinAddress;
    Counters.Counter private tokenIdCounter;

    constructor(address _coinAddress) ERC721("AwesomeVolcanoNft", "AVN") {
        coinAddress = _coinAddress;
    }

    function setCoinAddress(address _coinAddress) public onlyOwner {
        coinAddress = _coinAddress;
    }

    function mint(address _to) public onlyOwner {
        _mint(_to);
    }

    function _mint(address _to) private {
        tokenIdCounter.increment();
        _safeMint(_to, tokenIdCounter.current());
    }

    function payToMint(address _to) public payable {
        bool executed;

        if (msg.value >= 0.01 ether) {
            payable(msg.sender).transfer(msg.value - 0.01 ether); // maybe improve
            executed = true;
        } else {
            IERC20(coinAddress).transferFrom(msg.sender, address(this), 100);
            executed = true;
        }

        require(executed, "Did not receive 0.01 ether or 100 tokens");

        _mint(_to);
    }
}
