// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "contracts/Donation.sol";
contract FundManager {

    // количество созданных фондов
    uint256 public numberOfFoundationsCreated;
    // Маппинг хранящий адрес создателя фонда, где ключём является адрес фонда.
    mapping(address => address) public ownersOfFunds;


    event Create(address indexed foundation, address indexed owner);
    event Transfer(address indexed from, uint256 value);
    error NotAnOwnerError(address caller);

    function createFoundation(
    address donationReceiver,
    string memory description
    ) external payable{
        Donation donation = new Donation{value: msg.value}(donationReceiver,description);
        ownersOfFunds[address(donation)] = msg.sender;
        numberOfFoundationsCreated += 1;
        emit Create(address(donation), msg.sender);
    }

    function transferFundsToReceiver(
    address payable foundationAddress,
    uint256 amount) 
    external{
        if (ownersOfFunds[foundationAddress] != msg.sender) {
            revert NotAnOwnerError(msg.sender);
        }
        Donation donation = Donation(foundationAddress);
        donation.sendFundsToReceiver(amount);
        emit Transfer(foundationAddress,amount);
    }
}
