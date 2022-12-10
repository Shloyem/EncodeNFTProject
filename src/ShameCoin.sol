// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import "openzeppelin-contracts/access/Ownable.sol";
import "openzeppelin-contracts/token/ERC20/ERC20.sol";

/// @title An ERC20 contract for shame coin
/// @notice A coin with a weird behavior, for learning purposes only
contract ShameCoin is ERC20, Ownable {
    uint constant INITIAL_SUPPLY = 10000;
    address constant BURN_ADDRESS =
        address(0x000000000000000000000000000000000000dEaD);
    address public administrator;

    /// @dev Sets the value for administrator and mints him the initial supply 
    /// also sets the values for {name} and {symbol}.
    constructor() ERC20("ShameCoin", "SHC") {
        administrator = msg.sender;
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    /// @inheritdoc ERC20
    function decimals() public view virtual override returns (uint8) {
        return 0;
    }
    
    /// @dev The administrator can send 1 shame coin at a time to other addresses
    /// If non administrators try to transfer their shame coin it increases their balance by one.
    /// @inheritdoc ERC20
    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        if (msg.sender == administrator) {
            require(amount == 1, "Administrator can send 1 coin at a time");
            return super.transfer(to, 1);
        } else {
            // Non administrators transfer will increase their balance by one instead
            _mint(msg.sender, 1);
            return true;
        }
    }

    /// @dev Non administrators can approve only the administrator to spend one token on their behalf
    /// @inheritdoc ERC20
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        require(spender == administrator, "Spender is not the administrator");
        _approve(msg.sender, administrator, 1);
        return true;
    }

    /// @dev The transfer from function just reduces the balance of the holder.
    /// @inheritdoc ERC20
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        return super.transfer(BURN_ADDRESS, amount);
    }
}
