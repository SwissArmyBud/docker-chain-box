pragma solidity >=0.4.21 <0.6.0;

contract TournamentPrizewall {

  address public owner;
  address public transfer;

  mapping (address => uint256) public balances;

  constructor() public {
    owner = msg.sender;
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

  function credit(address account, uint amount) public onlyOwner {
    if((balances[account] + amount) > amount){
      balances[account] += amount;
    }
  }

  function debit(address account, uint amount) public onlyOwner {
    if(balances[account] > amount){
      balances[account] -= amount;
    }
  }
}
