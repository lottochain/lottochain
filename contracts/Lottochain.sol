pragma solidity ^0.4.21;

///@title Tickets deals with whole lifecycle of a Ticket: 
///Adds to and draws from daily, weekly and monthly prize lists.
///Draws from Super Ticket prize list
///@author paulofelipe84 - paulo.barbosa@lottochain.io

contract LottochainSuperTickets {
    address[] public superTickets;
    function superTicketsQty() public view returns(uint);
    function chargeDrawnAddress(address _drawnAddress) public;
}

contract LottochainDrawsHistory {
    function addDrawHistory(uint _drawDate, uint8 _drawType, bytes32 _hashDraw1, bytes32 _hashDraw2, address _drawnAddress, uint _prize) public;
    function getDrawHistory(uint _drawDate, uint8 _drawType) public view returns(bytes32 hashDraw1, bytes32 hashDraw2, address drawnAddress, uint blockNumber, uint prize);
    function addAddressValidTicket(address _address) public;
    function getAddressCurrentTicketQty(address _address) public view returns(uint dailyTicketsBalance, uint weeklyTicketsBalance, uint monthlyTicketsBalance);
    function closeDraw(uint8 _drawType) public;
}

contract Lottochain {
    //Ownership support
    address public owner;
    address public potentialOwner;
    
    //LOTTO Token contract for Super Tickets draw
    address public superTicketsContractAddress;
    
    //DrawsHistory contract
    address public drawsHistoryContractAddress;
    
    //Lottery control
    bool public lotteryActive;

    //Prices definition
    uint public ticketPrice = 100000000;
    uint public superTicketPrice = 100000000;

    //Dev wallets
    uint public lottochainWallet1Balance;
    uint public lottochainWallet2Balance;

    //Prize variables
    uint public dailyPrize;
    uint public accumulatedDailyPrize;
    uint public weeklyPrize;
    uint public accumulatedWeeklyPrize;
    uint public monthlyPrize;
    uint public accumulatedMonthlyPrize;
    uint public superTicketsPrize;
    uint public accumulatedSuperTicketsPrize;

    //Indexes for the drawing device
    uint public dailyTicketsIndex;
    uint public weeklyTicketsIndex;
    uint public monthlyTicketsIndex;

    //Mappings that will store the addresses with tickets
    mapping (uint => address) public dailyTickets;
    mapping (uint => address) public weeklyTickets;
    mapping (uint => address) public monthlyTickets;

    //Maps a wallet address to a boolean that says if that 
    //address is authorized as an administrator
    mapping (address => bool) public authorizedAddresses;

    event BuyTicket(
        address userAddress, 
        uint ticketPrice, 
        uint ticketsQuantity
    );

    event DrawTicket(
        uint drawDate, 
        uint8 drawType,
        bytes32 hashDraw1, 
        bytes32 hashDraw2,
        address winner, 
        uint prize
    );
    
    /** 
     * SafeMath
     */
    function add(uint256 x, uint256 y) pure internal returns(uint256) {
      uint256 z = x + y;
      assert((z >= x) && (z >= y));
      return z;
    }

    function sub(uint256 x, uint256 y) pure internal returns(uint256) {
      assert(x >= y);
      uint256 z = x - y;
      return z;
    }

    function mul(uint256 x, uint256 y) pure internal returns(uint256) {
      uint256 z = x * y;
      assert((x == 0)||(z/x == y));
      return z;
    }
    
    function div(uint256 a, uint256 b) pure internal returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
    
        return c;
    }

    /**
     * Constructor function
     *
     * Assigns contract owner
     */
    function Lottochain() public {
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

    ///@dev Toggles the lottery status. 
    function toggleLotteryStatus() public onlyAdmins {
        lotteryActive = !lotteryActive;
    }
    
    ///@dev Updates the Super Ticket contract address. 
    ///@param _newAddress The new contract address
    function setSuperTicketsContractAddress(address _newAddress) public onlyAdmins {
        superTicketsContractAddress = _newAddress;
    }
    
    ///@dev Updates the Draws History contract address. 
    ///@param _newAddress The new contract address
    function setDrawsHistoryContractAddress(address _newAddress) public onlyAdmins {
        drawsHistoryContractAddress = _newAddress;
    }

    ///@dev Updates the Ticket price. 
    ///@param _newPrice The new ticket price
    function setTicketPrice(uint _newPrice) public onlyAdmins {
        ticketPrice = _newPrice;
    }
    
    ///@dev Updates the Super Ticket price. 
    ///@param _newPrice The new super ticket price
    function setSuperTicketPrice(uint _newPrice) public onlyAdmins {
        superTicketPrice = _newPrice;
    }

    ///@dev Adds the caller address to the Ticket draw list
    ///as many times as the amount sent divided by the Ticket price
    function buyTicket() public payable {
        //Lottery must be on
        require(lotteryActive);
        //User must be buying at least 1 Ticket
        require(msg.value >= ticketPrice);
        //Finds the purchased quantity
        uint ticketsQuantity = div(msg.value, ticketPrice);
        //Limits the amount of tickets per transaction
        require(ticketsQuantity > 0 && ticketsQuantity <= 30);
        //Instantiates the draws history contract
         LottochainDrawsHistory lottochainDrawsHistory = LottochainDrawsHistory(drawsHistoryContractAddress);
        //Adds the address to each drawing list, as many times as the purchased tickets
        while(ticketsQuantity > 0){
            dailyTicketsIndex++;
            dailyTickets[dailyTicketsIndex] = msg.sender;

            weeklyTicketsIndex++;
            weeklyTickets[weeklyTicketsIndex] = msg.sender;

            monthlyTicketsIndex++;
            monthlyTickets[monthlyTicketsIndex] = msg.sender;

            lottochainDrawsHistory.addAddressValidTicket(msg.sender);

            ticketsQuantity--;
        }
        //Finds percentages from the ticket(s) value for distribution
        uint fiftyPercent = div(msg.value, 2); // 50%
        uint twentyPercent = div(msg.value, 5); // 20%
        uint tenPercent = div(msg.value, 10); // 10%
        uint fivePercent = div(msg.value, 20); // 5%

        //Distributes the total ticket(s) amount amongst the prize and fees addresses
        //Regular prizes
        dailyPrize += fiftyPercent; 
        weeklyPrize += twentyPercent; 
        monthlyPrize += tenPercent;
        
        //Super Tickets
        superTicketsPrize += tenPercent;
        
        //Dev fees
        lottochainWallet1Balance += fivePercent;
        lottochainWallet2Balance += fivePercent;

        //Adds to the accumulated metrics
        accumulatedDailyPrize += fiftyPercent;
        accumulatedWeeklyPrize += twentyPercent;
        accumulatedMonthlyPrize += tenPercent;
        accumulatedSuperTicketsPrize += tenPercent;

        //Emits the event of the purchase
        emit BuyTicket(msg.sender, ticketPrice, ticketsQuantity);
        
    }

    ///@dev Draws the winning ticket and transfers the prize to its wallet address
    ///@param _drawDate The date of draw in format YYYYMMDD
    ///@param _drawType The type of Draw: 1 = Daily, 2 = Weekly, 3 = Monthly, 4 = Super Tickets
    ///@param _hashDraw1 First Hash to compose the draw seed
    ///@param _hashDraw2 Second Hash to compose the draw seed
    function drawWinner (
        uint _drawDate,
        uint8 _drawType,
        bytes32 _hashDraw1, 
        bytes32 _hashDraw2
    ) 
        onlyAdmins
        public
    {
    
        require(_drawType == 1 || _drawType == 2 || _drawType == 3 || _drawType == 4);
        
        uint prize;
        uint drawIndex;
        address drawnAddress;
        
        LottochainDrawsHistory lottochainDrawsHistory = LottochainDrawsHistory(drawsHistoryContractAddress);

        //Daily Draw
        if(_drawType == 1 && dailyTicketsIndex > 0) {
            //Checks if the prize is still a profit considering current ticket price
            require(dailyPrize >= ticketPrice);
            
            //Derives the index of the Winner
            drawIndex = (add(uint(_hashDraw1), uint(_hashDraw2)) % dailyTicketsIndex) + 1;

            require(drawIndex <= dailyTicketsIndex);
            
            //Finds the address related to the index in the Daily Tickets list
            drawnAddress = dailyTickets[drawIndex];
            
            //Resets the index so the list is reinitialized
            dailyTicketsIndex = 0;
            
            //Brings the prize to an internal variable
            prize = dailyPrize;
            
            //Clears the prize, preventing reentrancy attacks
            dailyPrize = 0;
    
            //Emits the draw event to the blockchain
            emit DrawTicket(_drawDate, _drawType, _hashDraw1, _hashDraw2, drawnAddress, prize);

            //Adds the draw attributes to the draws history contract for future reference
            lottochainDrawsHistory.addDrawHistory(_drawDate, 1, _hashDraw1, _hashDraw2, drawnAddress, prize);
            
            //Closes the daily draw in the address-ticket-tracking mapping
            lottochainDrawsHistory.closeDraw(1);
            
            //Transfers the net prize to the winner
            drawnAddress.transfer(prize);

        //Weekly Draw
        } else if(_drawType == 2 && weeklyTicketsIndex > 0) {
            //Checks if the prize is still a profit considering current ticket price
            require(weeklyPrize >= ticketPrice);
            
            //Deriving the index of the Winner
            drawIndex = (add(uint(_hashDraw1), uint(_hashDraw2)) % weeklyTicketsIndex) + 1;
        
            require(drawIndex <= weeklyTicketsIndex);
            
            //Finds the address related to the index in the Daily Tickets list
            drawnAddress = weeklyTickets[drawIndex];
            
            //Resets the index so the list is reinitialized
            weeklyTicketsIndex = 0;
            
            //Brings the prize to an internal variable
            prize = weeklyPrize;
    
            //Clears the prize, preventing reentrancy attacks
            weeklyPrize = 0;
    
            //Emits the draw event to the blockchain
            emit DrawTicket(_drawDate, _drawType, _hashDraw1, _hashDraw2, drawnAddress, prize);

            //Adds the draw attributes to the draws history contract for future reference
            lottochainDrawsHistory.addDrawHistory(_drawDate, 2, _hashDraw1, _hashDraw2, drawnAddress, prize);
            
            //Closes the weekly draw in the address-ticket-tracking mapping
            lottochainDrawsHistory.closeDraw(2);
            
            //Transfers the net prize to the winner
            drawnAddress.transfer(prize);

        //Monthly Draw
        } else if(_drawType == 3 && monthlyTicketsIndex > 0) {
            //Checks if the prize is still a profit considering current ticket price
            require(monthlyPrize >= ticketPrice);
            
            //Deriving the index of the Winner
            drawIndex = (add(uint(_hashDraw1), uint(_hashDraw2)) % monthlyTicketsIndex) + 1;

            require(drawIndex <= monthlyTicketsIndex);
            
            //Finds the address related to the index in the Daily Tickets list
            drawnAddress = monthlyTickets[drawIndex];
            
            //Resets the index so the list is reinitialized
            monthlyTicketsIndex = 0;
            
            //Brings the prize to an internal variable
            prize = monthlyPrize;
            
            //Clears the prize, preventing reentrancy attacks
            monthlyPrize = 0;
    
            //Emits the draw event to the blockchain
            emit DrawTicket(_drawDate, _drawType, _hashDraw1, _hashDraw2, drawnAddress, prize);

            //Adds the draw attributes to the draws history contract for future reference
            lottochainDrawsHistory.addDrawHistory(_drawDate, 3, _hashDraw1, _hashDraw2, drawnAddress, prize);
            
            //Closes the monthly draw in the address-ticket-tracking mapping
            lottochainDrawsHistory.closeDraw(3);
            
            //Transfers the net prize to the winner
            drawnAddress.transfer(prize);

        } else if(_drawType == 4) {
            //Instantiates the Super Tickets contract
            LottochainSuperTickets lottochainSuperTickets = LottochainSuperTickets(superTicketsContractAddress);
            
            //Brings the amount of Super Tickets in the draw
            uint superTicketsQty = lottochainSuperTickets.superTicketsQty();
            
            //Checks if there is at least one Super Ticket in the draw
            require(superTicketsQty > 0);
            
            //Checks if the prize is still a profit considering current super ticket price
            require(superTicketsPrize >= superTicketPrice);
            
            //Deriving the index of the Winner
            drawIndex = add(uint(_hashDraw1), uint(_hashDraw2)) % superTicketsQty;
            
            //Asserting that the derived index is within the array range
            assert(drawIndex <= superTicketsQty - 1);
            
            //Finds the address related to the index in the Daily Tickets list
            drawnAddress = lottochainSuperTickets.superTickets(drawIndex);

            //Brings the prize to an internal variable
            prize = superTicketsPrize;
            
            //Clears the prize, preventing reentrancy attacks
            superTicketsPrize = 0;
            
            //Charges the LOTTO token from the drawn address
            lottochainSuperTickets.chargeDrawnAddress(drawnAddress);
            
            //Transfers the net prize to the winner
            drawnAddress.transfer(prize);
            
            //Emits the draw event to the blockchain
            emit DrawTicket(_drawDate, _drawType, _hashDraw1, _hashDraw2, drawnAddress, prize);

            //Adds the draw attributes to the draws history contract for future reference
            lottochainDrawsHistory.addDrawHistory(_drawDate, 4, _hashDraw1, _hashDraw2, drawnAddress, prize);

        }

    }
    
    ///@dev Withdraws the fees gathered
    ///@param _to The address where to withdraw into
    function withdrawFees(address _to, uint _wallet) onlyAdmins public {
        require(_wallet == 1 || _wallet == 2);
        
        if (_wallet == 1) {
            _to.transfer(lottochainWallet1Balance);
            lottochainWallet1Balance = 0;
        } else {
            _to.transfer(lottochainWallet2Balance);
            lottochainWallet2Balance = 0;
        }
    }
    
    ///@dev Get data about a specific historic drawnAddress
    ///@param _drawDate the date of the draw
    ///@param _drawType the type of the draw (1 = Daily, 2 = Weekly, 3 = Monthly, 4 = Super Tickets)
    function drawsHistory(
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
        LottochainDrawsHistory lottochainDrawsHistory = LottochainDrawsHistory(drawsHistoryContractAddress);
        (hashDraw1, hashDraw2, drawnAddress, blockNumber, prize) = lottochainDrawsHistory.getDrawHistory(_drawDate, _drawType);
    }
    
    ///@dev Gets the amount of currently valid tickets for a specific address and draw type
    ///@param _address The address to be checked
    function getAddressCurrentTicketQty(address _address)
        public
        view
        returns(
            uint dailyTicketsBalance, 
            uint weeklyTicketsBalance, 
            uint monthlyTicketsBalance
        )
    {
        LottochainDrawsHistory lottochainDrawsHistory = LottochainDrawsHistory(drawsHistoryContractAddress);
        (dailyTicketsBalance, weeklyTicketsBalance, monthlyTicketsBalance) = lottochainDrawsHistory.getAddressCurrentTicketQty(_address);
    }
}