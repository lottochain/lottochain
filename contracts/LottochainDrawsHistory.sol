pragma solidity ^0.4.21;

///@title Used as storage for Lottochain data/metadata
///@author paulofelipe84 - paulo.barbosa@lottochain.io

contract LottochainDrawsHistory {
    //Ownership support
    address public owner;
    address public potentialOwner;
    
    //Lottochain contract reference
    address public lottochainContractAddress;
    
    //Maps a wallet address to a boolean that says if that 
    //address is authorized as an administrator
    mapping (address => bool) public authorizedAddresses;
    
    //Attributes of a draw to be stored for future reference
    struct drawAttributes {
        bytes32 hashDraw1;
        bytes32 hashDraw2;
        address drawnAddress;
        uint blockNumber;
        uint prize;
    }
    
    //Mapping to store historical data about draws
    //First level is the date in the format YYYYMMDD
    //Second level is the draw type: 1 = Daily, 2 = Weekly, 3 = Monthly, 4 = Super Tickets
    mapping (uint => mapping (uint8 => drawAttributes)) public drawsHistory;
    
    //Helpers for ticket history storage
    uint public dailyDrawIndex = 1;
    uint public weeklyDrawIndex = 1;
    uint public monthlyDrawIndex = 1;
    
    //Maps an address to draws where it has tickets purchased
    //First level is the address
    //Second level is the draw type: 1 = Daily, 2 = Weekly, 3 = Monthly, 4 = Super Tickets
    //Third level is the draw number, which is sequential.
    mapping (address => mapping (uint => mapping (uint => uint))) public addressTicketsHistory;
    
    /**
     * Constructor function
     *
     * Assigns contract owner
     */
    function LottochainDrawsHistory() public {
        owner = msg.sender;
        // Just being safe.
        potentialOwner = msg.sender;

        authorizedAddresses[msg.sender] = true;
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
    
    ///@dev Adds a draw to history
    ///@param _drawDate The date of draw in format YYYYMMDD
    ///@param _drawType The type of Draw: 1 = Daily, 2 = Weekly, 3 = Monthly, 4 = Super Tickets
    ///@param _hashDraw1 First Hash to compose the draw seed
    ///@param _hashDraw2 Second Hash to compose the draw seed
    ///@param _drawnAddress The address drawn (winner)
    ///@param _prize The amount transferred to the winner
    function addDrawHistory(
        uint _drawDate, 
        uint8 _drawType, 
        bytes32 _hashDraw1, 
        bytes32 _hashDraw2, 
        address _drawnAddress, 
        uint _prize
    )
        public
        onlyAdmins
    {
        drawsHistory[_drawDate][_drawType].hashDraw1 = _hashDraw1;
        drawsHistory[_drawDate][_drawType].hashDraw2 = _hashDraw2;
        drawsHistory[_drawDate][_drawType].drawnAddress = _drawnAddress;
        drawsHistory[_drawDate][_drawType].blockNumber = block.number;
        drawsHistory[_drawDate][_drawType].prize = _prize;
    }
    
    ///@dev Get data about a specific historic drawnAddress
    ///@param _drawDate the date of the draw
    ///@param _drawType the type of the draw (1 = Daily, 2 = Weekly, 3 = Monthly, 4 = Super Tickets)
    function getDrawHistory(
        uint _drawDate, 
        uint8 _drawType
    ) 
        public 
        view 
        returns(
            bytes32 hashDraw1,
            bytes32 hashDraw2,
            address drawnAddress,
            uint blockNumber,
            uint prize
        )
    {
        hashDraw1 = drawsHistory[_drawDate][_drawType].hashDraw1;
        hashDraw2 = drawsHistory[_drawDate][_drawType].hashDraw2;
        drawnAddress = drawsHistory[_drawDate][_drawType].drawnAddress;
        blockNumber = drawsHistory[_drawDate][_drawType].blockNumber;
        prize = drawsHistory[_drawDate][_drawType].prize;
    }
    
    ///@dev Increments the counter of tickets purchased by an address
    ///@param _address The address purchasing the ticket
    function addAddressValidTicket(address _address) public onlyAdmins {
        addressTicketsHistory[_address][1][dailyDrawIndex]++;
        addressTicketsHistory[_address][2][weeklyDrawIndex]++;
        addressTicketsHistory[_address][3][monthlyDrawIndex]++;
    }
    
    ///@dev Retrieves the counter of current tickets purchased by an address in a specific draw type
    ///@param _address The address purchasing the ticket
    function getAddressCurrentTicketQty(address _address) 
        public 
        view
        returns(
            uint dailyTicketsBalance, 
            uint weeklyTicketsBalance, 
            uint monthlyTicketsBalance
        )
    {
        dailyTicketsBalance = addressTicketsHistory[_address][1][dailyDrawIndex];
        weeklyTicketsBalance = addressTicketsHistory[_address][2][weeklyDrawIndex];
        monthlyTicketsBalance = addressTicketsHistory[_address][3][monthlyDrawIndex];
    }
    
    ///@dev Increments the draw index for daily, weekly or monthly draws
    ///@param _drawType The type of Draw: 1 = Daily, 2 = Weekly, 3 = Monthly, 4 = Super Tickets
    function closeDraw(uint8 _drawType) public onlyAdmins {
        require(_drawType == 1 || _drawType == 2 || _drawType == 3);
        
        if(_drawType == 1) {
            dailyDrawIndex++;
        } else if (_drawType == 2) {
            weeklyDrawIndex++;
        } else if (_drawType == 3) {
            monthlyDrawIndex++;
        }
    }
}