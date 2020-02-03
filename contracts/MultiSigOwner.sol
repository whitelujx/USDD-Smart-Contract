pragma solidity ^0.5.8;

import "./utils/SimpleMultiSig.sol";

/**
 * @dev This contract can act as a simple multisig owner contract.
 * It should be deployed seperately and ownership may be transferred to it.
 * The underlying multisig contract is Christian Lunkvist's simple multisig contract
 * https://github.com/christianlundkvist/simple-multisig
 */
contract MultiSigOwner is SimpleMultiSig {

    constructor(uint threshold_, address[] memory owners_, uint chainId) SimpleMultiSig(threshold_, owners_, chainId) public {

    }
}