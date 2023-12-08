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
        if (msg.value > 0){
            storeDonate();    
        }
    }
    function storeDonate() internal {
        if(_donations[tx.origin] == 0){
            charityAddresses.push(tx.origin);
        }
        _donations[tx.origin] += msg.value;
        totalDonationsAmount += msg.value;
        emit Transfer(tx.origin, msg.value);     
    }
    function donate() external payable {
        if(msg.value <= 0) { 
            revert ZeroAmountError(msg.sender);
        }
        storeDonate();       
    }

    function sendFundsToReceiver(uint256 amount) external payable onlyOwner {
        if (amount > address(this).balance ){
            revert ZeroAmountError(msg.sender);
        }
        (bool sent,) = donationsReceiver.call{value: msg.value}("");//2300 gas
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
        storeDonate();     
    }

}
