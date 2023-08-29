// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

contract Voting {
    // Define an Appropriate Data Type to Store Candidates
    struct Candidate {
        uint index;
        string name;
        uint voteCount;
    }

    // Define an Appropriate Data Type to Track If Voter has Already Voted
    mapping(address => bool) public voters;

    Candidate[] public candidates;

    constructor() {
        // Contract creator is the owner
        owner = msg.sender;
    }

    // Address of the contract owner
    address public owner;

    // Gets the index of a candidate by name
    function getCandidateIndexByName(string memory _name) internal view returns (uint) {
        for (uint256 i = 0; i < candidates.length; i++) {
            if (keccak256(bytes(candidates[i].name)) == keccak256(bytes(_name))) {
                return i;
            }
        }
        return candidates.length;
    }

    // Checks if a candidate with the given name already exists.
    // Solidity requires explicit type conversions when working with strings. By converting to bytes, you ensure that the name string is properly encoded before being hashed.
    // This is done to avoid issues related to the internal representation of strings and to ensure consistent hashing behavior.
    function candidateNameExists(string memory _name) internal view returns (bool) {
        for (uint256 i = 0; i < candidates.length; i++) {
            if (keccak256(bytes(candidates[i].name)) == keccak256(bytes(_name))) return true;
        }
        return false;
    }

    function isEmptyName(string memory _name) private pure returns (bool) {
        return bytes(_name).length == 0;
    }

    // Adds New Candidate
    function addCandidate(string memory _name) public {
        require(msg.sender == owner, "Only owner can add candidates");
        require(!isEmptyName(_name), "Candidate name cannot be empty");
        require(!candidateNameExists(_name), "Candidate with this name already exists");

        candidates.push(Candidate({
        index: candidates.length,
        name: _name,
        voteCount: 0
        }));
    }


    // Removes Already Added Candidate
    function removeCandidate(string memory _name) public {
        require(msg.sender == owner, "Only owner can remove candidates");
        require(!isEmptyName(_name), "Candidate name cannot be empty");

        uint candidateIndex = getCandidateIndexByName(_name);
        require(candidateIndex < candidates.length, "Candidate not found");

        candidates[candidateIndex] = candidates[candidates.length - 1];
        candidates.pop();
    }

    // Retrieves All Candidates for Viewing
    function getAllCandidates() public view returns (Candidate[] memory) {
        return candidates;
    }

    // Allows Voter to Cast a Vote for a Single Candidate
    function castVote(string memory _name) public {
        require(!voters[msg.sender], "You've already voted!");
        require(!isEmptyName(_name), "Candidate name cannot be empty");
        uint candidateIndex = getCandidateIndexByName(_name);
        require(candidateIndex < candidates.length, "Candidate not found");

        candidates[candidateIndex].voteCount++;

        voters[msg.sender] = true;
    }
}
