pragma solidity ^0.4.21;

contract LottochainSTLogic {
    function transferTokens(address _from, address _to, uint _value) public;
}

contract LottochainSuperTickets {

    string public name = 'Lottochain Super Ticket';
    string public symbol = 'LOTTO';
    
    string public standard = 'Token 0.1';

    uint8 public decimals = 0;
    
    uint256 public totalSupply = 330000;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    address public owner;
    address public potentialOwner;
    
    // Lottochain logics also needs to be referenced
    address public lottochainSTLogicContract;
    
    // Mapping to freeze addresseses that violate Lottochain policies
    mapping (address => bool) public frozenAddress;
    
    //Maps a wallet address to a boolean that says if that 
    //address is authorized as an administrator
    mapping (address => bool) public authorizedAddresses;
    
    // Status of token contract
    bool public isContractActive = true;
    
    /**
     * Constructor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    function LottochainSuperTickets() public {
        owner = msg.sender;
        
        // Just being safe.
        potentialOwner = msg.sender;
        
        // Give the creator all initial tokens
        balanceOf[owner] = totalSupply;
        
        // Adds the owner as an administrator
        authorizedAddresses[owner] = true;
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

    /** 
     * Ownership transfer functions
     */
    function ownershipTransfer(address _newOwner) public onlyOwner {
        potentialOwner = _newOwner;
    }

    function ownershipTransferConfirm() public {
        require(msg.sender == potentialOwner);
        owner = potentialOwner;
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
    
    /**
     * Toggles contract status
     */
    function toggleContractStatus() public onlyAdmins {
        isContractActive = !isContractActive;
    }
    
    /**
     * Freezes an address
     * Frozen addresses cannot send or receive tokens
     */
    function freezeAddress(address _address) public onlyAdmins {
        // Freezes address
        frozenAddress[_address] = true;
    }
    
    /**
     * Unfreezes an address
     * Frozen addresses cannot send or receive tokens
     */
    function unfreezeAddress(address _address) public onlyAdmins {
        frozenAddress[_address] = false;
    }
    
    /**
     * Defines lottochainSTLogicContract
     */
    function setLottochainSTLogicContractAddress(address _lottochainSTLogicContract) public onlyAdmins {
        // Removes current contract from admin list
        removeAdmin(lottochainSTLogicContract);
        // Sets new address
        lottochainSTLogicContract = _lottochainSTLogicContract;
        // Adds new address to admin list
        addAdmin(lottochainSTLogicContract);
    }

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // Checks if contract is active
        require(isContractActive);
        // Checks for frozen address
        require(!frozenAddress[_from] && !frozenAddress[_to]);
        // Checks for zeroed values (just being safe)
        require(_value > 0);
        // Checks if _from and _to are the same
        require(_from != _to);
        // Prevents transfer to 0x0 address.
        require(_to != 0x0);
        // Checks if the sender has enough
        require(balanceOf[_from] >= _value);
        // Checks for overflows
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        // Saves this for an assertion in the future
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // Subtracts from the sender
        balanceOf[_from] -= _value;
        // Adds the same to the recipient
        balanceOf[_to] += _value;
        // Emits the transfer event
        emit Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
        
        // Instantiates the Super Ticket Logic contract
        LottochainSTLogic lottochainSTLogic = LottochainSTLogic(lottochainSTLogicContract);
        // Processes transfer in the logics contract
        lottochainSTLogic.transferTokens(_from, _to, _value);
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
     * Charges one Super Ticket from the drawn address
     */
    function chargeDrawnAddress(address _drawnAddress) public onlyAdmins {
        _transfer(_drawnAddress, owner, 1);
    }

    // disable pay HTMLCOIN to this contract
    function () public payable {
        revert();
    }
}