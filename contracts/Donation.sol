// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";
contract Donation is Ownable {
    uint256 totalDonationsAmount;
    address _contract;
    address[] charityAddresses;
    address public immutable donationsReceiver;
    string public description;
    
    mapping(address => uint256) private _donations;

    error ZeroAmountError(address caller);
    error NotAnOwnerError(address caller);

    event Transfer(address indexed from, uint256 value);

    constructor(address _donationReceiver, string memory _description) Ownable(msg.sender) payable {
        description = _description;
        donationsReceiver = _donationReceiver;
    }

    function donate() external payable {
        if(msg.value <= 0) { 
            revert ZeroAmountError(msg.sender);
        }
        if(_donations[msg.sender] == 0){
            charityAddresses.push(msg.sender);
        }
        _donations[msg.sender] += msg.value;
        totalDonationsAmount += msg.value;
        emit Transfer(msg.sender, msg.value);        
    }

    function sendFundsToReceiver(uint256 amount) external onlyOwner {
        if (amount > address(this).balance ){
            revert ZeroAmountError(msg.sender);
        }
        bool sent = payable(donationsReceiver).send(amount);//2300 gas
        if(sent){
            emit Transfer(msg.sender, amount);
        }else {
            revert();
        }
        
    }
    
    function getDonators() external view returns(address[] memory){
        return charityAddresses;
    }
    function getSumOfDonations() external view returns(uint256){
        return totalDonationsAmount;
    }

    receive() external payable {
        emit Transfer(msg.sender, msg.value);
    }

}
