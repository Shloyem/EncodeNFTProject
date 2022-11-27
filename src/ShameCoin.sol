// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import "openzeppelin-contracts/access/Ownable.sol";
import "openzeppelin-contracts/token/ERC20/ERC20.sol";

address administrator;

contract ShameCoin is ERC20, Ownable {
    uint constant _initialSupply = 10000;
    address _administrator;

    // /**
    //  * @dev Throws if called by any account other than the administrator.
    //  */
    // modifier onlyAdministrator() {
    //     require(_administrator == msg.sender, "Caller is not the administrator");
    //     _;
    // }

    constructor() ERC20("ShameCoin", "SHC") {
      _administrator = msg.sender;
      _mint(msg.sender, _initialSupply);
    }

    function decimals() public view virtual override returns (uint8) {
        return 0;
    }

    // copy documentation
    function transfer(uint _amount, address _recipient) public {
        if (msg.sender == _administrator){
          // Administrator can transfer 1 coin at a time to other addresses
          super.transfer(_administrator, 1);
        }
        else {
          // Non administrators transfer will increase their balance by one instead
          _mint(msg.sender, 1);
        }
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    // dev: amount is ignored on purpose. 
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        // Non administrators can approve the administrator (and only the administrator) to spend one token on their behalf
        require(spender == _administrator, "Spender is not the administrator");
        _approve(msg.sender, _administrator, 1);
        return true;
    }
}