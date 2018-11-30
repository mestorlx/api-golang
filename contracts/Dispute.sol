pragma solidity ^0.4.24;

import "./DIAToken.sol";
import "zos-lib/contracts/Initializable.sol";
import "openzeppelin-eth/contracts/ownership/Ownable.sol";
import "openzeppelin-eth/contracts/math/SafeMath.sol";

contract Dispute is Initializable, Ownable {
	DIAToken public dia_;
	mapping (uint256=>uint) public disputeDeadline_;
	mapping (uint256=>uint256) private totalVotesPerDispute_;
	mapping (uint256=>mapping(address => bool)) private ballots_;
	mapping (uint256=>mapping(uint=>Voter)) private voters_;
	mapping (uint256=>uint) private totalVoters_;
	using SafeMath for uint;
	uint public voteLength_;
	uint public voteCost_;
	struct Voter {
		address id;
		bool vote;
	}

	function initialize(address _owner, DIAToken _dia) public initializer()  {
		Ownable.initialize(_owner);
		dia_ = _dia;
		voteLength_ = 10;
	}

	function openDispute(uint256 _id) public{
		require(disputeDeadline_[_id] == 0, "Dispute already ongoing");
		disputeDeadline_[_id] = block.number+voteLength_;
	}

	function vote(uint256 _id, bool _ballot) public{
		dia_.transferFrom(msg.sender,this,voteCost_);
		voters_[_id][totalVoters_[_id]] = Voter(msg.sender, _ballot);
		totalVoters_[_id]++;
	}

	function triggerDecision(uint256 _id) public{
		require(disputeDeadline_[_id] > 0, "Dispute not available");
		require(block.number > disputeDeadline_[_id], "Dispute deadline not reached");
		uint256 dropVotes = 0;
		uint256 keepVotes = 0;
		for(uint i = 0;i<totalVoters_[_id];i++){
			if (voters_[_id][i].vote)
				dropVotes++;
			else
				keepVotes++;
		}
		bool drop = (dropVotes>keepVotes);
		uint payment;
		if(drop)
			payment = (dropVotes+keepVotes).div(dropVotes)*voteCost_;
		else
			payment = (dropVotes+keepVotes)*keepVotes*voteCost_;
		for( i = 0;i<totalVoters_[_id];i++){
			if ( voters_[_id][i].vote==drop){
				dia_.transfer(voters_[_id][i].id, payment);
			}
			delete voters_[_id][i];
		}
		delete disputeDeadline_[_id];
	}
}