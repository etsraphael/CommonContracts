// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./../../common/contracts/token/ERC20/IERC20.sol";
import "./../../common/contracts/utils/math/SafeMath.sol";
import "./../../common/contracts/token/ERC20/utils/SafeERC20.sol";
import "./../../common/contracts/utils/Context.sol";

/**
 * @title Ownable
 * @author  Rafael
 *
 * @notice Ownership related functions
 */
contract InitializableOwnable is Context {
    address public _OWNER_;
    address private _NEW_OWNER_;

    // ============ Events ============

    event OwnershipTransferPrepared(address indexed previousOwner, address indexed newOwner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // ============ Modifiers ============

    modifier onlyOwner() {
        require(_msgSender() == _OWNER_, "NOT_OWNER");
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

    function claimOwnership() public {
        require(_msgSender() == _NEW_OWNER_, "INVALID_CLAIM");
        emit OwnershipTransferred(_OWNER_, _NEW_OWNER_);
        _OWNER_ = _NEW_OWNER_;
        _NEW_OWNER_ = address(0);
    }
}