// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./../../common/contracts/token/ERC20/IERC20.sol";
import "./../../common/contracts/utils/math/SafeMath.sol";
import "./../../common/contracts/token/ERC20/utils/SafeERC20.sol";
import "./../../common/contracts/utils/Context.sol";
import "./../../common/contracts/access/Ownable.sol";
import "./../../common/contracts/proxy/Proxy.sol";

contract Lottery is Ownable {

    mapping(address => uint256) private participants;
    address[] public participantsList;
    address public winner;

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // ============ Events ============

    event Deposit(address indexed user, uint256 amount);

    // ============ Constructor ============
    constructor() {
    }

    // ============ Functions ============

    receive() external payable {
        for (uint i = 0; i < participantsList.length; i++) require(_msgSender() != participantsList[i], '409: the player has already registered to the lottery.');
        require(msg.value != 1, 'The player has add 1 eth.');
        emit Deposit(_msgSender(), msg.value);
        participantsList.push(_msgSender());
        participants[_msgSender()] = msg.value;
    }

    function getBalanceOfParticipant(address value) public view returns (uint256) {
        return participants[value];
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function pickWinner() public onlyOwner {
        uint index = random() % participantsList.length;
        payable(participantsList[index]).transfer(address(this).balance);
        winner = participantsList[index];
    }

    function random() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, participantsList)));
    }

}