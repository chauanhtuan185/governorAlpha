// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Proposal.sol";

contract MockNFT is IERC721 {
    mapping(address => uint256) private _balances;

    function mint(address to, uint256 amount) public {
        _balances[to] += amount;
    }

    function balanceOf(address owner) external view override returns (uint256) {
        return _balances[owner];
    }
}

contract ProposalContractTest is Test {
    ProposalContract proposalContract;
    MockNFT mockNFT;
    address user1;
    address user2;

    function setUp() public {
        proposalContract = new ProposalContract();
        mockNFT = new MockNFT();
        user1 = address(0x1);
        user2 = address(0x2);
    }

    function testCreateProposal() public {
        proposalContract.createProposal("Test Proposal", address(mockNFT));

        (address creator, string memory description, address nftAddress, uint256 votesFor, uint256 votesAgainst) =
            proposalContract.getProposal(1);

        assertEq(creator, address(this), "Creator should be the contract deployer");
        assertEq(description, "Test Proposal", "Proposal description should match");
        assertEq(nftAddress, address(mockNFT), "NFT address should match");
        assertEq(votesFor, 0, "Votes for should be 0");
        assertEq(votesAgainst, 0, "Votes against should be 0");
    }

    function testVote() public {
        mockNFT.mint(user1, 1); // Mint 1 NFT for user1
        proposalContract.createProposal("Test Proposal", address(mockNFT));

        // User1 votes for the proposal
        vm.prank(user1);
        proposalContract.vote(1, true);

        (,, , uint256 votesFor, uint256 votesAgainst) = proposalContract.getProposal(1);
        assertEq(votesFor, 1, "Votes for should be 1");
        assertEq(votesAgainst, 0, "Votes against should be 0");
    }

    function testVoteWithoutNFT() public {
        proposalContract.createProposal("Test Proposal", address(mockNFT));
        
        // User2 tries to vote without holding an NFT
        vm.prank(user2);
        vm.expectRevert("You do not hold the required NFT");
        proposalContract.vote(1, true);
    }

    function testDoubleVote() public {
        mockNFT.mint(user1, 1); // Mint 1 NFT for user1
        proposalContract.createProposal("Test Proposal", address(mockNFT));

        // User1 votes for the proposal
        vm.prank(user1);
        proposalContract.vote(1, true);

        // User1 tries to vote again
        vm.prank(user1);
        vm.expectRevert("Already voted");
        proposalContract.vote(1, false);
    }
}
