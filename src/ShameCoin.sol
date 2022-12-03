// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import "openzeppelin-contracts/access/Ownable.sol";
import "openzeppelin-contracts/token/ERC20/ERC20.sol";

contract ShameCoin is ERC20, Ownable {
    uint constant INITIAL_SUPPLY = 10000;
    address constant BURN_ADDRESS =
        address(0x000000000000000000000000000000000000dEaD);
    address public administrator;

    constructor() ERC20("ShameCoin", "SHC") {
        administrator = msg.sender;
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    function decimals() public view virtual override returns (uint8) {
        return 0;
    }

    // copy documentation
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
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        // Non administrators can approve the administrator (and only the administrator) to spend one token on their behalf
        require(spender == administrator, "Spender is not the administrator");
        _approve(msg.sender, administrator, 1);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    // The transfer from function should just reduce the balance of the holder.
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        return super.transfer(BURN_ADDRESS, amount);
    }
}
