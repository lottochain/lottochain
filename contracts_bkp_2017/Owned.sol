pragma solidity ^0.4.11;

contract Owned {

    address public owner = msg.sender;
    address public potentialOwner;

    modifier onlyOwner {
      require(msg.sender == owner);
      _;
    }

    modifier onlyPotentialOwner {
      require(msg.sender == potentialOwner);
      _;
    }

    event NewOwner(address old, address current);
    event NewPotentialOwner(address old, address potential);

    function setOwner(address _new) public onlyOwner {
      NewPotentialOwner(owner, _new);
      potentialOwner = _new;
    }

    function confirmOwnership() public onlyPotentialOwner {
      NewOwner(owner, potentialOwner);
      owner = potentialOwner;
      potentialOwner = 0;
    }
}

contract mortal is Owned{
  function kill() public{
    if(msg.sender == owner)
      selfdestruct(owner);
  }
}
