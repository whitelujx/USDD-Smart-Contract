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