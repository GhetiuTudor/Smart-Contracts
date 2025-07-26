//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

interface IERC721{
    function safeTransferFrom(address from, address to, uint tokenId) external;
    function transferFrom(address from, address to, uint256) external;
}

contract EnglishAuction{
    event Start();
    event Bid(address indexed, uint);
    event Withdraw(address indexed, uint);
    event End(address, uint);

    IERC721 public nft;
    uint nftId;

    address topBidder;
    uint topBid;
    mapping(address => uint) public bids;
    address payable public seller;
    uint endAt;
    bool started;
    bool ended;

    constructor( address _nft, uint _id, uint stB){
        seller= payable(msg.sender);
        topBid= stB;
        nft = IERC721(_nft);
        nftId= _id;
    }

    function start() external{
        require(msg.sender == seller && !started);
        nft.transferFrom(seller, address(this), nftId);
        started = true;
        endAt= block.timestamp + 7 days;
        emit Start();
    }

    function bid() external payable{
        require(started && block.timestamp < endAt && msg.value > topBid);

        if(topBidder != address(0)){
            bids[topBidder]+=topBid;
        }

        topBidder= msg.sender;
        topBid= msg.value;
        emit Bid(msg.sender, topBid);
    }

    function withdraw() external{
        payable(msg.sender).transfer(bids[msg.sender]);
        emit Withdraw(msg.sender,bids[msg.sender] );
        bids[msg.sender]=0;
    }

    function end() external{
        require(msg.sender == seller && started && !ended  && block.timestamp > endAt);
        ended = true;
        started = false;
        if(topBidder != address(0)){
            nft.safeTransferFrom(address(this), topBidder, nftId);
        }
        else {
            nft.transferFrom(address(this), seller, nftId);
        }

        emit End(topBidder, topBid);
        selfdestruct(seller);
    }
}
