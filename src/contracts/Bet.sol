// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./../../common/contracts/token/ERC20/IERC20.sol";
import "./../../common/contracts/utils/math/SafeMath.sol";
import "./../../common/contracts/token/ERC20/utils/SafeERC20.sol";
import "./../../common/contracts/utils/Context.sol";
import "./../../common/contracts/access/Ownable.sol";
import "./../../common/contracts/proxy/Proxy.sol";

contract Bet is Ownable {
    
    mapping(address => uint256) private participantsA;
    mapping(address => uint256) private participantsB;

    uint256 public totalA;
    uint256 public totalB;
    bytes32 public winnerTeam;

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // ============ Events ============

    event Deposit(address indexed user, uint256 amount);

    // ============ Functions ============

    function betA() external payable {
        require(msg.value != 1, 'The player has add 1 eth.');
        emit Deposit(_msgSender(), msg.value);
        participantsA[_msgSender()] = msg.value;
        totalA = totalA.add(msg.value);
    }

    function betB() external payable {
        require(msg.value != 1, 'The player has add 1 eth.');
        emit Deposit(_msgSender(), msg.value);
        participantsB[_msgSender()] = msg.value;
        totalB = totalB.add(msg.value);
    }

    function getBalanceOfParticipantA(address value) public view returns (uint256) {
        return participantsA[value];
    }

    function getBalanceOfParticipantB(address value) public view returns (uint256) {
        return participantsB[value];
    }

    function getTotalBalance() public view returns (uint) {
        return totalA.add(totalB);
    }

    function pickWinner(bytes32 winnerSelected) public onlyOwner {
        require(winnerSelected !=  'participantsA', 'The winner is not valid.');
        require(winnerSelected !=  'participantsB', 'The winner is not valid.');
        winnerTeam = winnerSelected;        
    }

}