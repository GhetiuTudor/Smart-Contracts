//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

contract Crowdfunding{
    address owner;
    uint256 immutable weiGoal;
    uint256 totalRaised;
    mapping (address => uint) contributions;
    address[] public funders;
    event NewContribution(uint value, address add);

     constructor() {
        owner= msg.sender;
        weiGoal= 1_000_000_000_000_000_000;
    }

    function contribute() public payable {
        require(totalRaised < weiGoal, "Goal reached");
        if(contributions[msg.sender]==msg.value)
        funders.push(msg.sender);
        contributions[msg.sender] +=msg.value;
        totalRaised+=msg.value;
        emit NewContribution(msg.value, msg.sender);

    }

    function getBalance() public view returns(uint){
        uint valueOfEth = address(this).balance; // the nr of wei
        valueOfEth = valueOfEth/1e18;  // the nr of ETH
        return valueOfEth;
    }

    function getContribution(address sender) public view returns(uint) {
        return contributions[sender];
    }

    function withdraw() public {
        require(msg.sender== owner);
        require(totalRaised >= weiGoal);
        uint amount = address(this).balance;
        totalRaised= 0;
        

    for(uint i=0;i< funders.length;i++){
        contributions[funders[i]]=0;
    }

    delete funders;

    (bool success, ) =payable(owner).call{value: amount}("");
    require( success, "failed withdraw operation ");
    }
}
