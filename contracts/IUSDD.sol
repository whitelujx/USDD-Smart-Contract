pragma solidity ^0.5.8;

/**
 * @dev Interface of the the USSD token.
 */
interface IUSDD  {

    /**
     * Checks if the caller of an transaction is the owner of the contract
     * @return true or false
     */
    function isOwner() external view returns (bool);

    /**
     * Allows the current contract owner to transfer ownership to a new address
     * @param newOwner The new contract owner
     */
    function transferOwnership(address newOwner) external;

    /**
     * Allows the contract owner to pause the token (stop all transfers)
     */
    function pause() external;

    /**
     * Allows the contract owner to unpause the token
     */
    function unpause() external;

    /**
     * Returns the name of the token
     */
    function name() external view returns (string memory);

    /**
     * Returns the symbol of the token
     */
    function symbol() external view returns (string memory);

    /**
     * Returns the number of decimals
     */
    function decimals() external view returns (uint8);

     /**
     * Allows the contract owner to isue new tokens
     * @param account The account to be credited
     */
    function issue(address account, uint256 amount) external;

    /**
     * Allows the contract owner to remove tokens from circulation
     * @param account The account to be debited
     */
    function redeem(address account, uint256 amount) external returns (bool);


    /**
     * @dev Freezes an address balance from being transferred.
     * @param _addr The new address to freeze.
     */
    function freeze(address _addr) external;

    /**
     * @dev Unfreezes an address balance allowing transfer.
     * @param _addr The new address to unfreeze.
     */
    function unfreeze(address _addr) external;

    /**
     * @dev Wipes the balance of a frozen address, burning the tokens
     * and setting the approval to zero.
     * @param _addr The new frozen address to wipe.
     */
    function wipeFrozenAddress(address _addr) external;

    /**
     * @dev Adds a complianceRole address with specific regulatory compliance priveledges
     * @param _addr The address to be added
     */
    function addComplianceRole(address _addr) external returns (bool);

    /**
     * @dev Removes complianceRole address with specific regulatory compliance priveledges
     * @param _addr The address to be removed
     */
    function removeComplianceRole(address _addr) external returns (bool);

    /**
     * @dev Adds a issuer address with specific regulatory compliance priveledges
     * @param _addr The address to be added
     */

    function addIssuer(address _addr) external returns (bool);

    /**
     * @dev Removes issuer address with specific regulatory compliance priveledges
     * @param _addr The address to be removed
     */
    function removeIssuer(address _addr) external returns (bool);

    /**
     * @dev Upgrades the implementation address
     * @param _newImplementation address of the new implementation
     */
    function upgradeTo(address _newImplementation) external;

/**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Paused(address account);
    event Unpaused(address account);
    event AddressFrozen(address indexed addr);
    event AddressUnfrozen(address indexed addr);
    event FrozenAddressWiped(address indexed addr);


}