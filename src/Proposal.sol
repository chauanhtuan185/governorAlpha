// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721 {
    function balanceOf(address owner) external view returns (uint256);
}

contract ProposalContract {

    struct Proposal {
        address creator;
        string description;
        address nftAddress;
        uint256 votesFor;
        uint256 votesAgainst;
        mapping(address => bool) voted;
    }

    uint256 public proposalCount;
    mapping(uint256 => Proposal) public proposals;

    event ProposalCreated(uint256 proposalId, address creator, string description, address nftAddress);
    event Voted(uint256 proposalId, address voter, bool voteFor);

    function createProposal(string memory _description, address _nftAddress) public {
        proposalCount++;
        Proposal storage newProposal = proposals[proposalCount];
        newProposal.creator = msg.sender;
        newProposal.description = _description;
        newProposal.nftAddress = _nftAddress;

        emit ProposalCreated(proposalCount, msg.sender, _description, _nftAddress);
    }

    function vote(uint256 _proposalId, bool _voteFor) public {
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.voted[msg.sender], "Already voted");
        require(IERC721(proposal.nftAddress).balanceOf(msg.sender) > 0, "You do not hold the required NFT");

        if (_voteFor) {
            proposal.votesFor++;
        } else {
            proposal.votesAgainst++;
        }

        proposal.voted[msg.sender] = true;
        emit Voted(_proposalId, msg.sender, _voteFor);
    }

    function getProposal(uint256 _proposalId) public view returns (
        address creator,
        string memory description,
        address nftAddress,
        uint256 votesFor,
        uint256 votesAgainst
    ) {
        Proposal storage proposal = proposals[_proposalId];
        return (proposal.creator, proposal.description, proposal.nftAddress, proposal.votesFor, proposal.votesAgainst);
    }
}
