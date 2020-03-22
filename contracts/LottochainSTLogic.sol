pragma solidity ^0.4.21;

contract LottochainSuperTickets {
    function chargeDrawnAddress(address _drawnAddress) public;
}

contract LottochainSTLogic {
    address public owner;
    address public potentialOwner;
    
    // Lottochain token contract needs to be referenced
    address public lottochainSuperTicketsContract;
    
    // Array that will contain the addresses that hold tokens
    // Those addresses will be the ones running for the prize
    address[] public superTickets;
    
    // Mapping that will show the indexes of each super ticket
    // belonging to an address, running for the prize.
    // As a single address can have multiple tickets (tokens),
    // the mapping points to an array of indexes.
    mapping (address => uint[]) public addressTickets;
    
    // Mapping that will show the ticket index within its address' array
    mapping (uint => uint) public ticketAddressIndex;
    
    // Mapping to flag addresses that should not be part of the draws,
    // such as the token contract owner and HTMLBunker wallets
    mapping (address => bool) public exceptedAddresses;
    
    //Maps a wallet address to a boolean that says if that 
    //address is authorized as an administrator
    mapping (address => bool) public authorizedAddresses;
    
     /**
     * Constructor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    function LottochainSTLogic() public {
        owner = msg.sender;
        // Just being safe.
        potentialOwner = msg.sender;
        // Add the owner as an excepted address
        exceptedAddresses[owner] = true;
        // Add the owner as an admin
        authorizedAddresses[owner] = true;
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
    
    ///@dev Allows only administrators to execute functions
    modifier onlyAdmins() {
        require(authorizedAddresses[msg.sender]);
        _;
    }
    
    ///@dev Adds an address to the exception list
    ///@param _address The address to be added to exception list
    function addExceptedAddress(address _address) public onlyAdmins {
        // Checks if the address has any currently indexed tokens. If so, it cannot be excepted.
        require(addressTickets[_address].length == 0);
        
        exceptedAddresses[_address] = true;
    }
    
    ///@dev Removes an address from the exception list
    ///@param _address The address to be removed from exception list
    function removesExceptedAddress(address _address) public onlyAdmins {
        exceptedAddresses[_address] = false;
    }
    
    ///@dev Defines lottochainSTLogicContract
    ///@param _lottochainSuperTicketsContract The address of lottochainSTLogic Contract
    function setLottochainSuperTicketContractAddress(address _lottochainSuperTicketsContract) public onlyAdmins {
        // Removes admin privileges from current lottochain super ticket contract
        removeAdmin(lottochainSuperTicketsContract);
        // Updates lottochain super ticket contract address
        lottochainSuperTicketsContract = _lottochainSuperTicketsContract;
        // Adds new super ticket contract address as an admin
        addAdmin(lottochainSuperTicketsContract);
    }
    
    ///@dev Adds an address to the admin list
    ///@param _address The address to be added
    function addAdmin(address _address) onlyAdmins public {
        authorizedAddresses[_address] = true;
    }

    ///@dev Removes an address from the admin list
    ///@param _address The address to be removed
    function removeAdmin(address _address) onlyAdmins public {
        // The owner cannot be removed
        require(_address != owner);
        
        authorizedAddresses[_address] = false;
    }
    
    ///@dev Returns the length of super tickets array
    function superTicketsQty() public view returns(uint){
        return superTickets.length;
    }
    
    
    ///@dev Makes the reorganization of tokens ownership after a token transfer
    ///@param _from The address from which the tokens are being transferred
    ///@param _to The address to which the tokens are being transferred
    ///@param _value The amount of tokens being transferred
    function transferTokens(address _from, address _to, uint _value) public onlyAdmins {
        // Ticket operations
        uint ticketIndex;
        address movingAddress;
        uint superTicketsLastPosition;
        
        // Tickets within excepted addresses' balances are not tracked.
        // The following logics should be only applied if at least one of the addresses is not excepted
        if(!exceptedAddresses[_from] || !exceptedAddresses[_to]) {
            // Checks if the transaction is starting from an excepted address into a non-excepted address
            if(exceptedAddresses[_from]) {
                // One operation for each super ticket being transferred
                while(_value > 0) {
                    // If that's the case, the ticket is not indexed in the drawing list
                    // therefore we need to create a new item in the ticket array
                    superTickets.push(_to);
                    // stores the position of the ticket in the superTickets array, which is the last position
                    ticketIndex = superTickets.length - 1;
                    // adds the ticket index to _to's ticket list
                    addressTickets[_to].push(ticketIndex);
                    // adds the ticket index to the ticket's address index
                    ticketAddressIndex[ticketIndex] = addressTickets[_to].length - 1;
                    // Decrements _value
                    _value--;
                }
            // Checks if the transaction is going into an excepted address from a non-excepted address.
            } else if(exceptedAddresses[_to]) {
                // One operation for each super ticket being transferred
                while(_value > 0) {
                    // Picks the last position in superTickets array
                    superTicketsLastPosition = superTickets.length - 1;
                    // Picks the address that's being moved from the end of superTickets array
                    movingAddress = superTickets[superTicketsLastPosition];
                    // Picks the superTickets array index of the ticket to be transferred.
                    // The index is always the last one stored in the address tickets reference
                    ticketIndex = addressTickets[_from][addressTickets[_from].length - 1];
                    // Moves the last item in superTickets array into ticketIndex
                    superTickets[ticketIndex] = movingAddress;
                    // Places the ticket into address tickets array into the position that's being moved
                    addressTickets[movingAddress][ticketAddressIndex[superTicketsLastPosition]] = ticketIndex;
                    // Updates the index for the moved ticket
                    ticketAddressIndex[ticketIndex] = ticketAddressIndex[superTicketsLastPosition];
                    // Removes the ticket index from _from's ticket list
                    addressTickets[_from].length--;
                    // Removes the last position from superTickets array since it's been repositioned
                    superTickets.length--;
                    // Decrements _value
                    _value--;
                }
            // Both addresses are not excepted
            } else {
                // One operation for each super ticket being transferred
                while(_value > 0) {
                    // Transfers the ticket ownership within the reference list
                    // Retrieves the index of the ticket to be transferred
                    // The ticket to be transferred will always be the last one in the address list of tickets
                    ticketIndex = addressTickets[_from][addressTickets[_from].length - 1];
                    // Assign that ticket to _to
                    superTickets[ticketIndex] = _to;
                    // Adds the index reference to the transferred ticket into _to's indexes list 
                    addressTickets[_to].push(ticketIndex);
                    // Updates the index for the moved ticket
                    ticketAddressIndex[ticketIndex] = addressTickets[_to].length - 1;
                    // Removes the index reference to the transferred ticket from _from's indexes list 
                    addressTickets[_from].length--;
                    // Decrements _value
                    _value--;
                }
            }
        }
    }
    
    ///@dev Returns the length of ticket indexes held by an address
    ///@param _address The address that holds the indexes
    function ticketIndexesLength(address _address) public view returns(uint) {
        return addressTickets[_address].length;
    }
    
    ///@dev Charges 1 token from specific address
    ///@param _drawnAddress The address to be charged
    function chargeDrawnAddress(address _drawnAddress) public onlyAdmins {
         // Instantiates the Super Ticket contract
        LottochainSuperTickets lottochainSuperTickets = LottochainSuperTickets(lottochainSuperTicketsContract);
        // Process transfer in the logics contract
        lottochainSuperTickets.chargeDrawnAddress(_drawnAddress);
    }
}