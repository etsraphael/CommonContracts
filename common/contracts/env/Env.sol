// SPDX-License-Identifier: MIT

import "./../utils/math/SafeMath.sol";

pragma solidity ^0.8.0;

abstract contract Env {

    // ============ Storage ============

    address payable private _protocol_address;
    uint256 private _protocol_fee;
    uint256 private _owner_fee;

    // ============ Library ============

    using SafeMath for uint256;

    // ============ Constructor ============

    constructor() {
        _protocol_address = payable(0xB790F2178D35f244D9EecF1130496309eAE063be);
        _protocol_fee = 1;
    }

    // ============ Functions ============

    function getProtocolAddress() public view virtual returns (address) {
        return _protocol_address;
    }

    function getProtocolFee() public view virtual returns (uint256) {
        return _protocol_fee;
    }

    function getOwnerFee() public view virtual returns (uint256) {
        return _owner_fee;
    }

    function setOwnerFee(uint256 owner_fee) public {
        _owner_fee = owner_fee;
    }

    function applyFeeAndGetAmount(address payable to, uint256 value) public returns (uint256) {

        // send protocol fee
        uint256 protocol_fee = value.mul(getProtocolFee()).div(100);
        payable(getProtocolAddress()).transfer(protocol_fee);

        // send owner fee
        uint256 owner_fee_value = value.mul(getOwnerFee()).div(100);
        to.transfer(owner_fee_value);

        // return amount
        return value.sub(protocol_fee).sub(owner_fee_value);
    }

}
