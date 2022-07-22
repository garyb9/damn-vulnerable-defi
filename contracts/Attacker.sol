// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @title Attacker
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract Attacker {
    using Address for address;
    using SafeMath for uint256;

    address private immutable owner;
    address private pool;

    constructor(address poolAddress) {
        owner = msg.sender;
        pool = poolAddress;
    }

    modifier onlyAttacker {
        require(msg.sender == owner, "Only owner can use this contract");
        _;
    }

    function exploit() external onlyAttacker {}
}