//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

contract ReceiverA{

    event Received(string method, uint amount, uint gasLeft);
   // uint public balance = address(this).balance;
    receive()external payable{
        emit Received("receive", msg.value, gasleft());
    }

    fallback() external payable{
         emit Received("fallback", msg.value, gasleft());
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }
}

contract ReceiverB{

    event Received(string method, uint amount, uint gasLeft);
    //uint public balance = address(this).balance;
    receive()external payable{

        emit Received("receive", msg.value, gasleft());
    }

    fallback() external payable{
         emit Received("fallback", msg.value, gasleft());
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }
}

contract EtherRouter{
    address payable public a;
    address payable public b;
    address immutable public owner;
    address public sender;

    event SameAddr(string);

    constructor(address payable _a, address payable  _b) {
        a=_a;
        b=_b;
        owner= msg.sender;
    }

    function setSender(address _s) public onlyOwner{
        sender = _s;
    }

    function route(bool toA) public payable{
        require(msg.sender==sender);
        bool ok;
        if(toA) 
            (ok, )= a.call{value: msg.value}("");
        else 
            (ok, )= b.call{value: msg.value}("");
        require(ok, "Transaction failed");
    }

    modifier onlyOwner(){
        require(owner==msg.sender);
        _;
    }

    function withdraw() public onlyOwner{
        (bool ok, ) = owner.call{value: address(this).balance}("");
        require(ok, "withdrawl failed");
    }

    function getBalance() public  view returns(uint){
        return address(this).balance;
    }
}

contract Sender{

    address immutable public router;
    event isOk(bool);

    constructor(address _r){
        router=_r;
    }

    function sendToRouter(bool x) public payable{
        (bool ok, bytes memory data) = router.call{value: msg.value}(abi.encodeWithSignature("route(bool)",x));
        emit isOk(ok);
    }
}
