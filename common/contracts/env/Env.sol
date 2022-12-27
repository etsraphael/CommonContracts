// SPDX-License-Identifier: MIT

import "./../utils/math/SafeMath.sol";

pragma solidity ^0.8.0;

abstract contract Env {
    address payable private _protocol;
    uint256 public _fee;

    // ============ Library ============

    using SafeMath for uint256;

    // ============ Constructor ============

    constructor() {
        _protocol = payable(0xB790F2178D35f244D9EecF1130496309eAE063be);
        _fee = 1;
    }

    // ============ Functions ============

    function protocol() public view virtual returns (address) {
        return _protocol;
    }

    function fee() public view virtual returns (uint256) {
        return _fee;
    }

    // send transaction with protocol fees
    function applyFeeAndGetAmount(address payable to, uint256 value, uint256 owner_fee) public returns (uint256) {

        // send protocol fee
        uint256 protocol_fee = value.mul(fee()).div(100);
        payable(protocol()).transfer(protocol_fee);

        // send owner fee
        uint256 owner_fee_value = value.mul(owner_fee).div(100);
        to.transfer(owner_fee_value);

        // return amount
        return value.sub(protocol_fee).sub(owner_fee_value);
    }

}
