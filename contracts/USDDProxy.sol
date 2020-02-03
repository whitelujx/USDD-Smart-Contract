pragma solidity ^0.5.8;

import "./USDDStorage.sol";
import "./implementations/USDDv1.sol";


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
