// SPDX-License-Identifier: MIT


pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    
    mapping (address => uint256) public addressToAmountFunded;
    address[] public funders;
    address public owner;
    
    // to set the owner of the contract
    constructor() public {
        owner = msg.sender;
    }
    
    function fund() public payable {
        uint256 minimumUsd = 50  * 10 ** 18;
        require(getConversionRate(msg.value) >= minimumUsd, "You need to spend more ETH!");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender); 
    }
    
    function getVersion() public view returns (uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        return priceFeed.version();
    }
    
    function getPrice() public view returns (uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (,int256 answer,,,)  = priceFeed.latestRoundData();
        return uint256(answer * 10000000000);
    }
    
    function getConversionRate(uint256 ethAmount) public view returns (uint256){
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 100000000000000000;
        return ethAmountInUsd;
    }
 
 
    modifier onlyOwner {
      require(msg.sender == owner);
      _;
    }
    
    function withdraw() payable onlyOwner public {
        // allows only the creator of the contract to be able to withdraw from the contract
        require(msg.sender == owner);
        msg.sender.transfer(address(this).balance);
        
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
    }
    
    // 2:35
    
}