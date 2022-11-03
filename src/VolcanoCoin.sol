// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import "openzeppelin-contracts/access/Ownable.sol";

contract VolcanoCoin is Ownable {
    struct Payment {
        uint amount;
        address recipient;
    }

    uint public totalSupply = 10000;
    mapping(address => uint) public balances;
    mapping(address => Payment[]) public payments;

    event SupplyChanged(uint newAmount);
    event Transfer(uint amount, address recipient);

    constructor() {
        balances[owner()] = totalSupply;
    }

    function getTotalSupply() public view returns (uint) {
        return totalSupply;
    }

    function increaseTotalSupply() public onlyOwner {
        totalSupply += 1000;
        emit SupplyChanged(totalSupply);
    }

    function transfer(uint _amount, address _recipient) public {
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;

        emit Transfer(_amount, _recipient);

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
