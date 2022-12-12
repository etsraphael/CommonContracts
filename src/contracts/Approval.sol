// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./../../common/contracts/token/ERC20/IERC20.sol";
import "./../../common/contracts/utils/math/SafeMath.sol";
import "./../../common/contracts/token/ERC20/utils/SafeERC20.sol";

// File: contracts/lib/InitializableOwnable.sol

/**
 * @title Ownable
 * @author  Breeder
 *
 * @notice Ownership related functions
 */
contract InitializableOwnable {
    address public _OWNER_;
    address public _NEW_OWNER_;
    bool internal _INITIALIZED_;

    // ============ Events ============

    event OwnershipTransferPrepared(address indexed previousOwner, address indexed newOwner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // ============ Modifiers ============

    modifier notInitialized() {
        require(!_INITIALIZED_, "_INITIALIZED");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == _OWNER_, "NOT_OWNER");
        _;
    }

    // ============ Functions ============

    function initOwner(address newOwner) public notInitialized {
        _INITIALIZED_ = true;
        _OWNER_ = newOwner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        emit OwnershipTransferPrepared(_OWNER_, newOwner);
        _NEW_OWNER_ = newOwner;
    }

    function claimOwnership() public {
        require(msg.sender == _NEW_OWNER_, "INVALID_CLAIM");
        emit OwnershipTransferred(_OWNER_, _NEW_OWNER_);
        _OWNER_ = _NEW_OWNER_;
        _NEW_OWNER_ = address(0);
    }
}

// File: contracts/SmartRoute/Approve.sol

/**
 * @title Approve
 * @author  Breeder
 *
 * @notice Handle authorizations in  platform
 */
contract Approve is InitializableOwnable {
    using SafeERC20 for IERC20;
    
    // ============ Storage ============
    uint256 private constant _TIMELOCK_DURATION_ = 3 days;
    uint256 private constant _TIMELOCK_EMERGENCY_DURATION_ = 24 hours;
    uint256 public _TIMELOCK_;
    address public _PENDING__PROXY_;
    address public __PROXY_;

    // ============ Events ============
    event SetProxy(address indexed oldProxy, address indexed newProxy);
    
    // ============ Modifiers ============
    modifier notLocked() {
        require(
            _TIMELOCK_ <= block.timestamp,
            "SetProxy is timelocked"
        );
        _;
    }

    function init(address owner, address initProxyAddress) external {
        initOwner(owner);
        __PROXY_ = initProxyAddress;
    }

    function unlockSetProxy(address newProxy) public onlyOwner {
        if(__PROXY_ == address(0))
            _TIMELOCK_ = block.timestamp + _TIMELOCK_EMERGENCY_DURATION_;
        else
            _TIMELOCK_ = block.timestamp + _TIMELOCK_DURATION_;
        _PENDING__PROXY_ = newProxy;
    }


    function lockSetProxy() public onlyOwner {
       _PENDING__PROXY_ = address(0);
       _TIMELOCK_ = 0;
    }


    function setProxy() external onlyOwner notLocked() {
        emit SetProxy(__PROXY_, _PENDING__PROXY_);
        __PROXY_ = _PENDING__PROXY_;
        lockSetProxy();
    }


    function claimTokens(
        address token,
        address who,
        address dest,
        uint256 amount
    ) external {
        require(msg.sender == __PROXY_, "Approve:Access restricted");
        if (amount > 0) {
            IERC20(token).safeTransferFrom(who, dest, amount);
        }
    }

    function getProxy() public view returns (address) {
        return __PROXY_;
    }
}