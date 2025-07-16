//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

contract Voting{
 string[] public candidates;
 mapping(address => bool) hasVoted;
 mapping(string=> uint) votes;

event candAdded(string);

 function addCandidate(string memory cand) public {
    for (uint i = 0; i < candidates.length; i++) {
    require(
        keccak256(abi.encodePacked(candidates[i])) != keccak256(abi.encodePacked(cand)),
        "Candidate already exists"
    );
    }
    candidates.push(cand);
    votes[cand]=0;
    emit candAdded(cand);
 }

event voted(address voter, string cand);

 function vote(string memory choice) public {
    require(!hasVoted[msg.sender], "you have already voted");
    bool x;
    for(uint i=0;i<candidates.length;i++)
    {
        if(keccak256(abi.encodePacked(choice))== keccak256(abi.encodePacked(candidates[i]))) x=true; 
        //set x= true in case the candidate exists
    }
    require(x, "Candidate does not exist");
    votes[choice]+=1;
    hasVoted[msg.sender]=true;
    emit voted(msg.sender, choice);
 }

 event winnerChosen(string, uint);

 function win() public returns(string memory){
    uint maxVotes=0;
    string memory winner;
    for(uint i=0;i<candidates.length;i++){
        if(votes[candidates[i]]>maxVotes) winner= candidates[i];
    }
    emit winnerChosen(winner,maxVotes);
    return winner;
 }
}
