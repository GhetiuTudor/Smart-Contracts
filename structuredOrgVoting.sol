//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

enum State{Open, Closed, Ended}

contract Organization{
    string public name;
    address public owner;

    event OrganizationCreated(string, address);

    constructor(string memory _name){
        name= _name;
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(owner==msg.sender);
        _;
    }

}

contract Department is Organization {
    struct Employee{
        string name;
        bool isNominated;
    }

    mapping(address=> Employee) employeesAddr;
    address[] public candidates;
    mapping(address=> uint) votes;
    bool public electionOpen;
    mapping(address => bool) hasVoted;
    State public state;
    uint public startTime;
    uint public stopTime;

    event EmployeeAdded(string, address);
    event CandidateNominated(address);
    event Voted(address voter, address cand);
    event ElectionEnded(address, uint);

    constructor(string memory _n) Organization(_n){}

    function addEmployee(address _addr, string memory _name) public onlyOwner{
        employeesAddr[_addr]= Employee(_name, false);
        emit EmployeeAdded(_name, _addr);
    }

    function nominate(address _addr) public {
        //protection against double nominations
        require(!employeesAddr[_addr].isNominated, "Candidate already in the nominees list ");
        employeesAddr[_addr].isNominated= true;
        candidates.push(_addr);
        emit CandidateNominated(_addr);
    }

    function startElection() public onlyOwner{
        electionOpen=true;
        state=State(0);
        startTime= block.timestamp;
        stopTime= block.timestamp + 2 minutes;
    }

    function endElection() public onlyOwner{
        require(block.timestamp>stopTime, "election still ongoing");
        electionOpen= false;
        state= State(2);
    }

    function vote(address candidate) public returns(bool){
        //protection against double voting
        require(block.timestamp<stopTime, "election ended");
        require(!hasVoted[msg.sender], "you have already voted"); // check if the sender didnt already vote
        bool exists;
        for(uint i=0;i<candidates.length;i++){
            if(candidates[i]==candidate) exists=true;
        }
        require(exists, "the chosen person is not a candidate");
        votes[candidate]++;
        hasVoted[msg.sender]=true;
        emit Voted(msg.sender, candidate);
        return true; //in case the user voted (candidate exists and this is the first vote)
    }

    function getWinner() public returns(address, uint){
        address winner;
        uint maxVotes=0;
        for(uint i=0;i<candidates.length;i++){
            if(votes[candidates[i]]>maxVotes) {
                maxVotes= votes[candidates[i]];
                winner= candidates[i];
            }
        } // upon exiting this for loop the winner address is in the winner variable
        emit ElectionEnded(winner, maxVotes);       
        return(winner, maxVotes);
    }
    
}
