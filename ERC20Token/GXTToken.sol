//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import "./IERC-20.sol";

contract GXT is IERC20{

event Transfer(address, address, uint);
event Approval(address, address,uint);
string public name;
string public symbol;
uint public decimals;
mapping(address=>uint) public balanceOf;
mapping(address => mapping(address=>uint))public allowance; //the amount that thse spender can spend from the owners wallet
uint256 public  totalSupply; // automatic getter generation (implementation of IERC20)

constructor() {
name="GXTToken";
symbol= "GXT";
decimals = 18; // the same mechanism as ETH (10^18 wei)
_mint(msg.sender, 500*10**decimals);
}

function transfer(address recipient, uint amount) external returns(bool){
    require(balanceOf[msg.sender]>= amount);
    require(recipient!= address(0));
    balanceOf[msg.sender]-=amount;
    balanceOf[recipient]+=amount;
    emit Transfer(msg.sender, recipient,amount);
    return true;
}

function approve(address spender, uint amount) external returns(bool){
require(spender !=address(0));
allowance[msg.sender][spender]+=amount;
emit Approval(msg.sender, spender, amount);
return true;
}

 function transferFrom(address sender, address recipient, uint256 amount)  external returns (bool)
    {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _mint(address to, uint amount) internal{
        balanceOf[to] += amount;
        totalSupply+=amount;
    }

    function mint(address to, uint amount) external{
        _mint(to, amount);
    }
}
