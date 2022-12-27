// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./../../common/contracts/token/ERC20/IERC20.sol";
import "./../../common/contracts/utils/math/SafeMath.sol";
import "./../../common/contracts/token/ERC20/utils/SafeERC20.sol";
import "./../../common/contracts/utils/Context.sol";
import "./../../common/contracts/access/Ownable.sol";
import "./../../common/contracts/proxy/Proxy.sol";

contract Fundraising is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // ============ Storage ============
    uint256 public goal;
    uint256 public deadline;
    uint256 public total;
    address payable private beneficiary;

    // ============ Events ============

    event Deposit(address indexed user, uint256 amount);

    event Withdraw(address indexed user, uint256 amount);

    event Transfer(address indexed user, uint256 amount);

    // ============ Modifiers ============

    modifier beforeDeadline() {
        require(block.timestamp < deadline, "Fundraising: deadline has passed");
        _;
    }

    modifier goalReached() {
        require(total >= goal, "Fundraising: goal not reached");
        _;
    }

    // ============ Constructor ============

    constructor(uint256 _goal, uint256 _deadline) {
        goal = _goal;
        deadline = _deadline;
        beneficiary = payable(_msgSender());
    }

    // ============ Functions ============
    
   function addAmount() external payable {
        emit Deposit(_msgSender(), msg.value);
        total = total.add(msg.value);
    }

    


}