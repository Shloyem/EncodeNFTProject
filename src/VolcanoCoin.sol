// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import "openzeppelin-contracts/access/Ownable.sol";
import "openzeppelin-contracts/token/ERC20/ERC20.sol";

contract VolcanoCoin is ERC20, Ownable {
    struct Payment {
        uint amount;
        address recipient;
    }

    uint constant initialSupply = 10000;
    mapping(address => Payment[]) public payments;

    constructor() ERC20("VolcanoCoin", "VLC") {
        _mint(msg.sender, initialSupply);
    }

    function increaseTotalSupply() public onlyOwner {
        _mint(msg.sender, 1000);
    }

    function transfer(uint _amount, address _recipient) public {
        super.transfer(_recipient, _amount);

        recordPayment(msg.sender, _recipient, _amount);
    }

    function getPaymentRecords(address _user)
        public
        view
        returns (Payment[] memory)
    {
        return payments[_user];
    }

    function recordPayment(
        address _sender,
        address _recipient,
        uint _amount
    ) private {
        payments[_sender].push(
            Payment({amount: _amount, recipient: _recipient})
        );
    }
}
