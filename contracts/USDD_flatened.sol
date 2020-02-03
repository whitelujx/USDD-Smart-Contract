// File: contracts/USDDStorage.sol

pragma solidity ^0.5.8;

/**
 * @dev Storage is eternal, as it is created in the context of the proxy contract.
 * Thhis storage contract must be inherited by all implementations and cannot be modified, as storage alignment needs to be preserved.
 */
contract USDDStorage {

    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) internal _allowances;
    uint256 internal _totalSupply;
    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;
    address owner;
    bool paused;
    mapping(address => bool) internal complianceRole;
    mapping(address => bool) internal issuer;
    mapping(address => bool) internal frozen;
}

// File: contracts/utils/SafeMath.sol

pragma solidity ^0.5.8;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// File: contracts/IERC20.sol

pragma solidity ^0.5.8;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions;
 */
interface IERC20 {
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
}

// File: contracts/implementations/USDDv1.sol

pragma solidity ^0.5.8;




contract USDDv1 is USDDStorage, IERC20  {
    using SafeMath for uint256;

    /*
     * Non-Standard Events
     */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Paused(address account);
    event Unpaused(address account);
    event AddressFrozen(address indexed addr);
    event AddressUnfrozen(address indexed addr);
    event FrozenAddressWiped(address indexed addr);

    /*
     * Modifyiers
     */
    modifier onlyOwner() {
        require(isOwner(), "Caller is not the owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused.");
        _;
    }

    modifier whenPaused() {
        require(paused, "Contract is not paused.");
        _;
    }

    modifier onlyComplianceRole() {
        require(complianceRole[msg.sender], "The caller does not have compliance role privileges");
        _;
    }

    modifier onlyIssuer() {
        require(issuer[msg.sender], "The caller does not have issuer role privileges");
        _;
    }

    /**
      * @dev We don't set any data apart from the proxy address here, as we are in the
      * wrong context if deployed through the proxy.
      * @param initialSupply Initial token supply that is minted to the contract owner.
      */
    constructor (uint initialSupply) public {
        _name = "USD Digital";
        _symbol = "USDD";
        _decimals = 18;

        if (initialSupply >= 0) _mint(msg.sender, initialSupply);

        owner = msg.sender;
        complianceRole[msg.sender] = true;
        issuer[msg.sender] = true;
    }

    /**
     * Checks if the caller of an transaction is the owner of the contract
     * @return true or false
     */
    function isOwner() public view returns (bool) {
        return msg.sender == owner;
    }

    /**
     * Allows the current contract owner to transfer ownership to a new address.
     * @param newOwner The new contract owner
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        require(!frozen[msg.sender], "Owner address is frozen");
        require(!frozen[newOwner], "New owner address frozen");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    /**
     * Allows the contract owner to pause the token (stop all transfers)
     */
    function pause() external onlyOwner whenNotPaused {
        paused = true;
        emit Paused(msg.sender);
    }

    /**
     * Allows the contract owner to unpause the token
     */
    function unpause() external onlyOwner whenPaused {
        paused = false;
        emit Unpaused(msg.sender);
    }

    /**
     * Returns the name of the token
     */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * Returns the symbol of the token
     */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
     * Returns the number of decimals
     */
    function decimals() external view returns (uint8) {
        return _decimals;
    }

    /**
     * Returns the total supply of USDD.
     */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /**
     * Returns the balance of an address.
     * @param account The address to check the balance of
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * Transfers balance from the message sender to the recipient if the accounts are not frozen.
     * @param recipient The address to send the balance to
     * @param amount The balance to transfer
     */
    function transfer(address recipient, uint256 amount) external whenNotPaused returns (bool) {
        require(!frozen[recipient] && !frozen[msg.sender], "address frozen");
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * Returns the allowance that the owner has given to a spender.
     * @param _owner The address that is giving the allowance.
     * @param spender The address that is granted the allowance.
     */
    function allowance(address _owner, address spender) external view returns (uint256) {
        return _allowances[_owner][spender];
    }

    /**
     * Grants an allowance to the spender.
     * @param spender The address that is granted the allowance.
     * @param value The amount that is granted to the spender.
     */
    function approve(address spender, uint256 value) external whenNotPaused returns (bool) {
        require(!frozen[spender] && !frozen[msg.sender], "address frozen");
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * Transfers balance from the address that has granted allowance.
     * @param sender The address that has granted the allowance.
     * @param recipient The address to transfer the balance to.
     * @param amount The amount that is transfered.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external whenNotPaused returns (bool) {
        require(!frozen[sender] && !frozen[recipient] && !frozen[msg.sender], "address frozen");
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    /**
     * Increases the allowance to the spender.
     * @param spender The address that is granted the allowance.
     * @param addedValue The amount that is granted.
     */
    function increaseAllowance(address spender, uint256 addedValue) external whenNotPaused returns (bool) {
        require(!frozen[spender] && !frozen[msg.sender], "address frozen");
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * Decreases the allowance to the spender.
     * @param spender The address that is granted the allowance.
     * @param subtractedValue The amount that is reduced.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) external whenNotPaused returns (bool) {
        require(!frozen[spender] && !frozen[msg.sender], "address frozen");
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * Allows an authorized issuer to isue new tokens
     * @param account The account to be credited
     * @param amount The balance to issue.
     */
    function issue(address account, uint256 amount) external onlyIssuer returns (bool) {
        _mint(account, amount);
        return true;
    }

    /**
     * Allows an authorized issuer to remove tokens from circulation
     * @param account The account that will have its balance reduced.
     * @param amount The balance to reduce.
     */
    function redeem(address account, uint256 amount) external onlyIssuer returns (bool) {
        _burn(account, amount);
        return true;
    }

    /**
     * @dev Freezes an address balance from being transferred.
     * @param _addr The new address to freeze.
     */
    function freeze(address _addr) public onlyComplianceRole {
        require(!frozen[_addr], "address already frozen");
        frozen[_addr] = true;
        emit AddressFrozen(_addr);
    }

    /**
     * @dev Unfreezes an address balance allowing transfer.
     * @param _addr The new address to unfreeze.
     */
    function unfreeze(address _addr) public onlyComplianceRole {
        require(frozen[_addr], "address already unfrozen");
        frozen[_addr] = false;
        emit AddressUnfrozen(_addr);
    }

    /**
     * @dev Wipes the balance of a frozen address, burning the tokens
     * and setting the approval to zero.
     * @param _addr The new frozen address to wipe.
     */
    function wipeFrozenAddress(address _addr) public onlyComplianceRole {
        require(frozen[_addr], "address is not frozen");
        _burn(_addr,balanceOf(_addr));
        emit FrozenAddressWiped(_addr);
    }

    /**
    * @dev Adds a complianceRole address with specific regulatory compliance privileges.
    * @param _addr The address to be added
    */
    function addComplianceRole(address _addr) public onlyOwner returns (bool) {
        require(_addr != address(0), "address cannot be 0");
        if(complianceRole[_addr] == false) {
            complianceRole[_addr] = true;
            return true;
        }
        return false;
    }

    /**
    * @dev Removes complianceRole address with specific regulatory compliance privileges.
    * @param _addr The address to be removed
    */
    function removeComplianceRole(address _addr) public onlyOwner returns (bool) {
        require(_addr != address(0), "address cannot be 0");
        if(complianceRole[_addr] == true) {
            complianceRole[_addr] = false;
            return true;
        }
        return false;
    }

    /**
    * @dev Adds a complianceRole address with specific regulatory compliance privileges.
    * @param _addr The address to be added
    */
    function addIssuer(address _addr) public onlyOwner returns (bool){
        require(_addr != address(0), "address cannot be 0");
        if(issuer[_addr] == false) {
            issuer[_addr] = true;
            return true;
        }
        return false;
    }

    /**
     * @dev Removes complianceRole address with specific regulatory compliance privileges.
     * @param _addr The address to be removed
     */
    function removeIssuer(address _addr) public onlyOwner returns (bool) {
        require(_addr != address(0), "address cannot be 0");
        if(issuer[_addr] == true) {
            issuer[_addr] = false;
            return true;
        }
        return false;
    }

    /*
     *Internal functions
     */

    /**
     * Transfers balance from the sender to the recipient.
     * @param sender The sender to reduce balance from
     * @param recipient The recipient to increase balance
     * @param amount The amount to transfer
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /**
     * Increases the balance of the account.
     * @param account The account to increase balance from
     * @param amount The amount to mint
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * Decreases the balance of the account.
     * @param account The account to increase balance from
     * @param value The amount to burn
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * Sets the allowance of the owner and spender.
     * @param _owner The account to authorize from
     * @param value The amount to burn
     */
    function _approve(address _owner, address spender, uint256 value) internal {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[_owner][spender] = value;
        emit Approval(_owner, spender, value);
    }


    /**
     * Internal burn function to reduce account balance.
     * @param account The account to decrease balance from
     * @param amount The amount to burn
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}

// File: contracts/USDDProxy.sol

pragma solidity ^0.5.8;




/**
 * @dev The USDD contract is the proxy cxontract for the token implementation.
 * It uses an inherited storage model. As all token functions pass through and are invoked
 * though delegatecall, storage is permanent in the proxy contract's context.
 * All implementations must use the same storage layout.
 */
contract USDDProxy is USDDStorage {

    address currentImplementation;


    modifier onlyOwner() {
        require (msg.sender == owner, "caller is not the contract owner");
        _;
    }

    /**
     * @dev The constructor sets the token's parameter and deploys the first implementation
     * @param initialSupply The initial supply at deploy time.
     */
    constructor (uint initialSupply) public {
        _name = "USD Digital";
        _symbol = "USDD";
        _decimals = 18;
        _totalSupply = initialSupply;
        _balances[msg.sender] = initialSupply;
    
        owner = msg.sender;
        complianceRole[msg.sender] = true;
        issuer[msg.sender] = true;

        //deploy initial version
        USDDv1 v1 = new USDDv1(0);
        //pause the implementation in its own context to avoid users trying to call directly
        v1.pause();
        currentImplementation = address(v1);
    }


    /**
     * @dev Upgrades the implementation address
     * @param _newImplementation address of the new implementation
     */
    function upgradeTo(address _newImplementation) external onlyOwner {
        require(currentImplementation != _newImplementation, "new Implementation must have different address");
        currentImplementation = _newImplementation;
    }

    /**
    * @dev Fallback function allowing to perform a delegatecall to the given implementation.
    * This function will return whatever the implementation call returns
    */
    function () external payable {
        address _impl = currentImplementation;
        require(_impl != address(0), "contract implementation cannot be 0 address");

        assembly {
        let ptr := mload(0x40)
        calldatacopy(ptr, 0, calldatasize)
        let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
        let size := returndatasize
        returndatacopy(ptr, 0, size)

        switch result
        case 0 { revert(ptr, size) }
        default { return(ptr, size) }
        }
    }


}