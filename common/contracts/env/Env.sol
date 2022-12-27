// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Env {
    address payable private _protocol;
    uint256 public _fee;

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

}
