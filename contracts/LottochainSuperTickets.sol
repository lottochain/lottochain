pragma solidity ^0.4.21;

contract LottochainSuperTicket {

    string public name = 'LC1';
    string public symbol = 'LC1';
    
    string public standard = 'Token 0.1';

    uint8 public decimals = 0;
    
    uint256 public totalSupply = 330000;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    address public owner;
    address public potentialOwner;
    
    // Current valid tokens that should be considered for draws
    uint public superTicketsIndex;
    
    // Mapping that will contain the addresses that hold tokens
    // Those addresses will be the ones running for the prize
    mapping (uint => address) public superTickets;
    
    // Mapping that will show the indexes of each super ticket
    // belonging to an address, running for the prize
    mapping (address => uint[]) public addressesTicketsIndexes;
    
    // Mapping to flag addresses that should not be part of the draws,
    // such as the token contract owner and HTMLBunker wallets
    mapping (address => bool) public exceptedAddress;
    
    // Mapping to freeze addresseses that violate Lottochain policies
    mapping (address => bool) public frozenAddress;
    
    // Lottochain contract needs to be referenced
    address public lottochainContract;
    
    /**
     * Constructor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    function LottochainSuperTicket() public {
        owner = msg.sender;
        
        // Just being safe.
        potentialOwner = msg.sender;
        
        // Give the creator all initial tokens
        balanceOf[owner] = totalSupply;
        
        // Add the owner as an excepted address
        exceptedAddress[owner] = true;
    }

    /** 
     * Ownership transfer functions
     */
    function ownershipTransfer(address _newOwner) onlyOwner public {
        potentialOwner = _newOwner;
    }

    function ownershipTransferConfirm() public {
        require(msg.sender == potentialOwner);
        owner = potentialOwner;
    }
    
    ///@dev Defines a modifier that allwos only the contract owner to execute a function
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    /**
     * Adds an address to the exception list
     */
    function addExceptedAddress(address _address) public onlyOwner {
        exceptedAddress[_address] = true;
    }
    
    /**
     * Removes an address from the exception list
     */
    function removesExceptedAddress(address _address) public onlyOwner {
        exceptedAddress[_address] = false;
    }
    
    /**
     * Freezes an address
     * Frozen addresses cannot send or receive tokens
     */
    function freezeAddress(address _address) public onlyOwner {
        frozenAddress[_address] = true;
    }
    
    /**
     * Unfreezes an address
     * Frozen addresses cannot send or receive tokens
     */
    function unfreezeAddress(address _address) public onlyOwner {
        frozenAddress[_address] = false;
    }
    
    /**
     * Defines lottochainContract
     */
    function setLottochainContract(address _lottochainContract) public onlyOwner {
        lottochainContract = _lottochainContract;
    }

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // Check for frozen address
        require(!frozenAddress[_from] && !frozenAddress[_to]);
        // Checks for zeroed values (just being safe)
        require(_value > 0);
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != 0x0);
        // Check if the sender has enough
        require(balanceOf[_from] >= _value);
        // Check for overflows
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        // Save this for lottery handling by the end
        uint previousBalanceTo = balanceOf[_to];
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
        
        // Lottery Operations
        // Checks if the source address has no remaining balance
        if(balanceOf[_from] == 0) {
            // If that is the case, remove the address from the mapping for the draws
            // Checks if the address is not the last one in the order
            if(superTickets[superTicketsIndex] != _from) {
                // If that is the case, copies the last address into the position of the address that is being deleted.
                // Since the balance is now zero, it is safe to assume that _from had only one ticket index,
                // therefore we are referring directly to the position 0 of the ticket indexes array for
                // that address.
                superTickets[addressesTicketsIndexes[_from][0]] = superTickets[superTicketsIndex];
            }
            
            
            
            
            // Decreases the index for valid tokens
            // THE TOKEN IS GOING TO ANOTHER ADDRESS. IS THIS NEEDED? MAYBE NEED TO TEST IF _TO IS VALID
            superTicketsIndex--;
        } else {
            // If the new balance is not zero, it means that _from had more than one ticket,
            // therefore its array with ticket indexes needs to be reduced.
            superTickets[addressesTicketsIndexes[_from]].length--;
        }
        
        // Checks if the address is not in the address exception list
        if(!exceptedAddress[_to]) {
            // If that is the case, increases the index for valid tokens
            superTicketsIndex++;
            //Checks if the destination address did not have any previous balance
            if(previousBalanceTo == 0) {
                // Assigns the new index to the addresses
                addressesTicketsIndexes[_to].push(superTicketsIndex);

            }
        }
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    /**
     * Transfer tokens from other address
     *
     * Send `_value` tokens to `_to` on behalf of `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * Set allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens on your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }
    
    /**
     * Returns the current quantity of Super Tickets in the draw
     */
    function superTicketsQty() public view returns(uint) {
        return superTickets.length;
    }
    
    /**
     * Charges one Super Ticket from the drawn address
     */
    function chargeDrawnAddress(address _drawnAddress) public {
        require(msg.sender == lottochainContract);
        _transfer(_drawnAddress, owner, 1);
    }

    // disable pay HTMLCOIN to this contract
    function () public payable {
        revert();
    }
}
