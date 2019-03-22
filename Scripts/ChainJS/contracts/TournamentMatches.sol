pragma solidity >=0.4.21 <0.6.0;

contract TournamentMatches {

  struct Match{
    address playerOne;
    bool oneClaimed;
    address playerTwo;
    bool twoClaimed;
    address claim;
    address winner;
    bool valid;
  }

  address public owner;
  address public transfer;

  uint public currentMatch;
  mapping (uint => Match) public matches;

  constructor() public {
    owner = msg.sender;
    return true;
  }

  modifier onlyOwner() {
    if (msg.sender == owner) _;
  }

  function createOwnershipOffer(address newOwner) public onlyOwner {
    transfer = newOwner;
  }

  function revokeOwnershipOffer() public onlyOwner {
    transfer = address(0x0);
  }

  function acceptOwnershipOffer() public {
    if(msg.sender == transfer){
      owner = transfer;
    }
  }

  function createMatch(address p1, address p2) public onlyOwner {
    currentMatch++;
    Match memory _new;
    _new.playerOne = p1;
    _new.playerTwo = p2;
    matches[currentMatch] = _new;
  }

  function validateMatch(uint _match, bool status) public onlyOwner {
    matches[_match].valid = status;
  }

  function callMatch(uint _num, address winner) public {
    Match storage _match = matches[_num];
    require(_match.valid);
    // Owner over-ride (manual)
    if(msg.sender == owner){
      _match.claim = address(0x0);
      _match.winner = winner;
      // Done with work
      return;
    }
    // If one of the players calls with a winner:
    // 1. Make sure they haven't claimed
    // 2. Check if they're the first to report and claim if so
    // 3. If they're not the first, see if they agree and set a winner or d-lock
    if((msg.sender == _match.playerOne)||(msg.sender == _match.playerTwo)){
      // NOTE: This will deadlock after two claims - then requires arbitration
      bool setClaim = false;
      if((msg.sender == _match.playerOne) && (!_match.oneClaimed)){
        _match.oneClaimed = true;
        setClaim = true;
      }
      if((msg.sender == _match.playerTwo) && (!_match.twoClaimed)){
        _match.twoClaimed = true;
        setClaim = true;
      }
      if(setClaim){
        if(_match.claim == address(0x0)){
          _match.claim = winner;
        } else if (_match.claim == winner){
          _match.winner = winner;
        }
        // Done with work, success
        return;
      }
    }
    // CRITICAL FAILURES
    // Sender must be owner or player
    // Player can only claim once
    require(false);
  }

}
