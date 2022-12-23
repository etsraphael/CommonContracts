// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./../../common/contracts/token/ERC20/IERC20.sol";
import "./../../common/contracts/utils/math/SafeMath.sol";
import "./../../common/contracts/token/ERC20/utils/SafeERC20.sol";
import "./../../common/contracts/utils/Context.sol";
import "./../../common/contracts/access/Ownable.sol";
import "./../../common/contracts/proxy/Proxy.sol";

contract Bet is Ownable {
    
    mapping(address => uint256) private participants0;
    mapping(address => uint256) private participants1;

    address payable[] private participantList0;
    address payable[] private participantList1;

    uint256 public total0;
    uint256 public total1;
    uint256 public winner;

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // ============ Events ============

    event Deposit(address indexed user, uint256 amount);

    event Withdraw(address indexed user, uint256 amount);

    // ============ Functions ============

    function getParticipantList0() public view returns (address payable[] memory) {
        return participantList0;
    }

    function getParticipantList1() public view returns (address payable[] memory) {
        return participantList1;
    }

    function bet0() external payable {
        require(msg.value != 1, 'The player has add 1 eth.');
        emit Deposit(_msgSender(), msg.value);
        participants0[_msgSender()] = msg.value;
        participantList0.push(payable(_msgSender()));
        total0 = total0.add(msg.value);
    }

    function bet1() external payable {
        require(msg.value != 1, 'The player has add 1 eth.');
        emit Deposit(_msgSender(), msg.value);
        participants1[_msgSender()] = msg.value;
        participantList1.push(payable(_msgSender()));
        total1 = total1.add(msg.value);
    }

    function getBalanceOfParticipantA(address value) public view returns (uint256) {
        return participants0[value];
    }

    function getBalanceOfParticipantB(address value) public view returns (uint256) {
        return participants1[value];
    }

    function getTotalBalance() public view returns (uint) {
        return total0.add(total1);
    }

    function pickWinner(uint256 winnerSelected) public onlyOwner {
        require(total0 != 0 && total1 != 0, 'The total of the two teams is 0.');
        require(winnerSelected == 0 || winnerSelected == 1, 'The winner selected is not valid.');
        winnerSelected = winnerSelected;  

        // send the funds to all the participants
        if (winnerSelected == 0) {
            for (uint i = 0; i < participantList0.length; i++) {
                uint256 amount = participants0[participantList0[i]];
                uint256 percent = amount.mul(100).div(total0);
                uint256 amountToTransfer = total1.mul(percent).div(100);
                emit Withdraw(participantList0[i], amountToTransfer);
                payable(participantList0[i]).transfer(amountToTransfer);
            }
        } else {
            for (uint i = 0; i < participantList1.length; i++) {
                uint256 amount = participants1[participantList1[i]];
                uint256 percent = amount.mul(100).div(total1);
                uint256 amountToTransfer = total0.mul(percent).div(100);
                emit Withdraw(participantList1[i], amountToTransfer);
                payable(participantList1[i]).transfer(amountToTransfer);
            }
        }     
    }

}