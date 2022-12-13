// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./../../common/contracts/token/ERC20/IERC20.sol";
import "./../../common/contracts/utils/math/SafeMath.sol";
import "./../../common/contracts/token/ERC20/utils/SafeERC20.sol";
import "./../../common/contracts/utils/Context.sol";
import "./../../common/contracts/access/Ownable.sol";
import "./../../common/contracts/proxy/Proxy.sol";

/**
 * @title Ownable
 * @author  Rafael
 *
 * @notice Ownership related functions
 */
contract InitializableOwnable is Context {
    address public _OWNER_;
    address public _NEW_OWNER_;

    // ============ Events ============

    event OwnershipTransferPrepared(address indexed previousOwner, address indexed newOwner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // ============ Modifiers ============

    modifier onlyOwner() {
        require(_msgSender() == _OWNER_, "NOT_OWNER");
        _;
    }

    modifier onlyNewOwner() {
        require(_msgSender() == _OWNER_, "NOT_NEW_OWNER");
        _;
    }

    // ============ Init ============
    constructor() {
        _OWNER_ = _msgSender();
        emit OwnershipTransferred(address(0), _OWNER_);
    }

    // ============ Functions ============

    function transferOwnership(address newOwner) public onlyOwner {
        emit OwnershipTransferPrepared(_OWNER_, newOwner);
        _NEW_OWNER_ = newOwner;
    }

    function claimOwnership() public onlyNewOwner {
        require(_msgSender() == _NEW_OWNER_, "INVALID_CLAIM");
        emit OwnershipTransferred(_OWNER_, _NEW_OWNER_);
        _OWNER_ = _NEW_OWNER_;
        _NEW_OWNER_ = address(0);
    }
}

/**
 * @title Approval
 * @author  Rafael
 *
 * @notice Approval related functions
 */
contract Approval is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // ============ Events ============

    event ApprovalReceived(address indexed sender, uint256 amount);

    event ApprovalWithdrawn(address indexed sender, uint256 amount);

    // ============ Storage ============

    IERC20 public token;

    mapping(address => uint256) public approved;

    // ============ Constructor ============

    constructor(IERC20 _token) {
        token = _token;
    }

    // ============ Functions ============

    function approve(uint256 amount) external {
        token.safeTransferFrom(_msgSender(), address(this), amount);
        approved[_msgSender()] = approved[_msgSender()].add(amount);
        emit ApprovalReceived(_msgSender(), amount);
    }

    function withdraw(uint256 amount) external {
        require(approved[_msgSender()] >= amount, "NOT_ENOUGH_APPROVED");
        approved[_msgSender()] = approved[_msgSender()].sub(amount);
        token.safeTransfer(_msgSender(), amount);
        emit ApprovalWithdrawn(_msgSender(), amount);
    }
}