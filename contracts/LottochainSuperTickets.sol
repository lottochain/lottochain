pragma solidity ^0.4.21;

contract LottochainSuperTicket {

    string public name = 'LC3';
    string public symbol = 'LC3';
    
    string public standard = 'Token 0.1';

    uint8 public decimals = 0;
    
    uint256 public totalSupply = 330000;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    address public owner;
    address public potentialOwner;
    
    // Array that will contain the addresses that hold tokens
    // Those addresses will be the ones running for the prize
    address[] public superTickets;
    
    // Mapping that will show the indexes of each super ticket
    // belonging to an address, running for the prize.
    // As a single address can have multiple tickets (tokens),
    // the mapping points to an array of indexes.
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
    function setLottochainContractAddress(address _lottochainContract) public onlyOwner {
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
        // Checks if _from and _to are the same
        require(_from != _to);
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != 0x0);
        // Check if the sender has enough
        require(balanceOf[_from] >= _value);
        // Check for overflows
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
        
        // Ticket operations
        uint ticketIndex;
        
        // Checks if the transaction is starting from an excepted address.
        if(exceptedAddress[_from]) {
            // One operation for each super ticket being transferred
            while(_value > 0) {
                // If that's the case, the ticket is not indexed in the drawing list
                // therefore we just need to create a new item in the ticket array
                superTickets.push(_to);
                // and add the last index of ticket array to _to's ticket index list
                addressesTicketsIndexes[_to].push(superTickets.length - 1);
                // Decrements _value
                _value--;
            }
        // Checks if the transaction is going into an excepted address.
        } else if(exceptedAddress[_to]) {
            // One operation for each super ticket being transferred
            while(_value > 0) {
                // If that's the case, the ticket must just be removed from the drawing list
                // Moves the last address into the position of the ticket to be removed
                // The ticket to be transferred will always be the last one in the address list of tickets
                superTickets[addressesTicketsIndexes[_from][addressesTicketsIndexes[_from].length - 1]] = superTickets[superTickets.length - 1];
                // Deletes the last position of the ticket list
                superTickets.length--;
                // Removes the index reference to the transferred ticket from _from's indexes list 
                addressesTicketsIndexes[_from].length--;
                // Decrements _value
                _value--;
            }
        } else {
            // One operation for each super ticket being transferred
            while(_value > 0) {
                // If none of involved addresses is excepted
                // Transfers the ticket ownership within the reference list
                // Retrieves the index of the ticket to be transferred
                // The ticket to be transferred will always be the last one in the address list of tickets
                ticketIndex = addressesTicketsIndexes[_from][addressesTicketsIndexes[_from].length - 1];
                // Assign that ticket to _to
                superTickets[ticketIndex] = _to;
                // Adds the index reference to the transferred ticket into _to's indexes list 
                addressesTicketsIndexes[_to].push(ticketIndex);
                // Removes the index reference to the transferred ticket from _from's indexes list 
                addressesTicketsIndexes[_from].length--;
                // Decrements _value
                _value--;
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
