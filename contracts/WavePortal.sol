// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint256 CANDIDATES=4;
    TotalVotes totalVotes;

    struct Voter {
        address voterAddress;
        uint totalVotes;
        uint firstVote;
        uint latestVote;
        uint[] votes; 
        uint256 latestTimestamp;
    }
    struct TotalVotes{
        uint totalVotes;
        uint[] votesByCandidate;
    }
    struct Vote {
        address voterAddress; // The address of the user who waved.
        string message; // The message the user sent.
        uint256 timestamp; // The timestamp when the user waved.
        uint candidateId;
    }
    mapping (address => Voter) voters;
    Vote[] votes;
    event NewVote(address indexed from, uint256 timestamp, string message, uint256 candidateId);
    uint256 private seed;

    constructor() payable {
        console.log("BeerPortal constructor invoked:");
        console.log("Yo yo, I am a contract and I am smart");
        seed = (block.timestamp + block.difficulty) % 100;
        totalVotes.totalVotes=0;
        totalVotes.votesByCandidate = new uint[](CANDIDATES);
        for(uint i=0;i<CANDIDATES;i++) totalVotes.votesByCandidate[i]=0;
    }

    function vote(uint timestamp,uint candidateId, string memory message) public returns (Voter memory) {
        if(candidateId>=1 && candidateId<=CANDIDATES){
            //Fetch wavePerson
            Voter memory v = voters[msg.sender];
            if(v.voterAddress==address(0)){
                //Never seen this person
                v.voterAddress=msg.sender;
                v.firstVote=timestamp;
                v.latestVote=timestamp;
                v.totalVotes++;
                v.votes = new uint[](CANDIDATES);
                for(uint i=0;i<CANDIDATES;i++) v.votes[i]=0;
                v.votes[candidateId-1]=1;
            }else{
                //Repeat visitor!
                //Cooldown
                require(
                v.latestTimestamp + 2 minutes < block.timestamp,
                "Wait 2m"
                );
                v.latestVote=timestamp;
                v.latestTimestamp = block.timestamp;
                v.totalVotes++;
                v.votes[candidateId-1]++;
            }
            totalVotes.totalVotes += 1;
            //Store it
            voters[msg.sender] = v;
            votes.push(Vote(msg.sender, message, timestamp,candidateId));
            totalVotes.votesByCandidate[candidateId-1]++;
            //Emit event
            emit NewVote(msg.sender, block.timestamp, message,candidateId);
            //Pay prize
            /*
            * Generate a new seed for the next user that sends a wave
            */
            seed = (block.difficulty + block.timestamp + seed) % 100;
            console.log("Random # generated: %d", seed);
            /*
            * Give a 50% chance that the user wins the prize.
            */
            if (seed <= 50) {
                console.log("%s won!", msg.sender);
                uint256 prizeAmount = 0.0001 ether;
                require(
                    prizeAmount <= address(this).balance,
                    "Trying to withdraw more money than the contract has."
                );
                (bool success, ) = (msg.sender).call{value: prizeAmount}("");
                require(success, "Failed to withdraw money from contract.");        
            }
            console.log("%s has voted %s times!", msg.sender, v.totalVotes);
            return v;
        }else{
            //Error - candidateId is outside range of candidates
            revert("No such candidate exists");
        }
    }

    function getVoter() public view returns (Voter memory) {
        Voter memory v = voters[msg.sender];
        return v;
    }
    function getTotalVotes() public view returns (TotalVotes memory) {
        console.log("We have %d total votes!", totalVotes.totalVotes);
        //Also return the sum of all voter votes
        return totalVotes;
    }
    function getAllVotes() public view returns (Vote[] memory){
        return votes;
    }
}