// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

contract Voting {
    // Define an Appropriate Data Type to Store Candidates

    address public owner;
    mapping(address => bool) public voters;

    struct Candidate {
        uint index;
        string name;
        uint voteCount;
        string externalId;
    }

    mapping(string => Candidate) candidates;
    string[] candidateExternalIds;

    constructor() {
        owner = msg.sender;
    }

    function generateUniqueId() private view returns (string memory) {
        bytes32 hash = keccak256(abi.encodePacked(block.timestamp, block.difficulty));

        string memory uniqueId = string(toBase32String(hash));
        require(bytes(uniqueId).length == 12, "Generated unique ID not of length 12");
        return uniqueId;
    }

    function toBase32String(bytes32 data) private pure returns (string memory) {
        bytes memory charSet = "0123456789abcdefghjkmnpqrstuvwxyz";
        bytes memory result = new bytes(12);

        for (uint256 i = 0; i < 12; i++) {
            result[i] = charSet[uint8(data[i]) % charSet.length];
        }

        return string(result);
    }

    function pushCandidateExternalId(string memory _externalId) private {
        candidateExternalIds.push(_externalId);
    }

    function candidatesCount() public view returns (uint) {
        return candidateExternalIds.length;
    }

    // Adds New Candidate
    function addCandidate(string memory _name) public {
        require(msg.sender == owner, "Only owner can add candidates");
        string memory externalId = generateUniqueId();
        candidates[externalId] = Candidate({
        index: candidateExternalIds.length,
        name: _name,
        voteCount: 0,
        externalId: externalId
        });
        pushCandidateExternalId(externalId);
    }

    function getCandidates() public view returns (Candidate[] memory) {
        uint count = candidatesCount();
        require(count > 0, "No candidates available"); // Handle empty list

        Candidate[] memory allCandidates = new Candidate[](count);
        for (uint i = 0; i < count; i++) {
            string memory externalId = candidateExternalIds[i];
            allCandidates[i] = candidates[externalId];
        }

        return allCandidates;
    }

    // Removes Already Added Candidate
    function removeCandidate(string memory _externalId) public {
        require(msg.sender == owner, "Only owner can remove candidates"); // Ensures that the sender of the transaction is the same as the owner of the contract.
        require(bytes(_externalId).length > 0, "Invalid candidate external ID"); // Ensures that the external ID is not an empty string.

        uint indexToRemove = candidates[_externalId].index;

        delete candidates[_externalId];

        // swapping the _externalId at the indexToRemove with the _externalId at the end of the array.
        // This is to maintain the order of the candidateExternalIds array while removing a candidate.
        candidateExternalIds[indexToRemove] = candidateExternalIds[candidateExternalIds.length - 1];
        candidateExternalIds.pop();
    }

    // Allows Voter to Cast a Vote for a Single Candidate
    function castVote(string memory _externalId) public {
        require(!voters[msg.sender], "You've already voted!");
        require(bytes(_externalId).length > 0, "Invalid candidate external ID");

        // Update the vote count for the candidate
        candidates[_externalId].voteCount++;

        // Mark the voter as voted
        voters[msg.sender] = true;
    }
}