pragma solidity ^0.4.21;

///@title Controls sales of super tickets (LOTTO tickets)
///@author paulofelipe84 - paulo.barbosa@lottochain.io

contract Lottochain {
    uint public superTicketPrice;
}

contract LottochainSuperTickets {
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
}

contract LottochainSTSales {

    //Ownership support
    address public owner;
    address public potentialOwner;
    
    //Contract control
    bool public saleActive;
    
    //Main super tickets address, where the tokens will be transferred from
    address public mainSuperTicketsAddress;
    
    //LOTTO Token contract for Super Tickets draw
    address public superTicketsContractAddress;
    
    //Lottochain contract
    address public lottochainContractAddress;
    
    //Dev wallets
    uint public lottochainWallet1Balance;
    uint public lottochainWallet2Balance;
    
    //Prices initialization
    uint public superTicketPrice = 1 ether; //100000000;
    
    event BuySuperTicket(
        address userAddress, 
        uint superTicketPrice,
        uint superTicketsQuantity
    );
    
    /** 
     * SafeMath
     */
    function div(uint256 a, uint256 b) pure internal returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
    
        return c;
    }
    
    //Maps a wallet address to a boolean that says if that 
    //address is authorized as an administrator
    mapping (address => bool) public authorizedAddresses;
    
     /**
     * Constructor function
     *
     * Assigns contract owner
     */
    function LottochainSTSales() public {
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
    function toggleSaleStatus() public onlyAdmins {
        saleActive = !saleActive;
    }
    
    ///@dev Updates the Super Ticket contract address. 
    ///@param _newAddress The new contract address
    function setSuperTicketsContractAddress(address _newAddress) public onlyAdmins {
        superTicketsContractAddress = _newAddress;
    }
    
    ///@dev Updates the Lottochain contract address. 
    ///@param _newAddress The new contract address
    function setLottochainContractAddress(address _newAddress) public onlyAdmins {
        lottochainContractAddress = _newAddress;
    }
    
    ///@dev Updates the main super tickets address 
    ///@param _newAddress The new address
    function setMainSuperTicketsAddress(address _newAddress) public onlyAdmins {
        mainSuperTicketsAddress = _newAddress;
    }
    
    ///@dev Transfer LOTTO tokens to the function caller
    ///as many times as the amount sent divided by the Super Ticket price
    function buySuperTicket() public payable {
        //Sale must be on
        require(saleActive);
        //Instantiates the Lottochain contract
        Lottochain lottochain = Lottochain(lottochainContractAddress);
        //Retrieves the super ticket price from lottochain contract
        superTicketPrice = lottochain.superTicketPrice();
        //User must be buying at least 1 Ticket
        require(msg.value >= superTicketPrice);
        //Finds the purchased quantity
        uint superTicketsQuantity = div(msg.value, superTicketPrice);
        //Limits the amount of tickets per transaction
        require(superTicketsQuantity > 0 && superTicketsQuantity <= 10);
        //Instantiates the Super Tickets contract
        LottochainSuperTickets lottochainSuperTickets = LottochainSuperTickets(superTicketsContractAddress);
        //Makes the transfer
        lottochainSuperTickets.transferFrom(mainSuperTicketsAddress, msg.sender, superTicketsQuantity);
        
        //Distributes the income into two equal parts
        uint fiftyPercent = div(msg.value, 2); // 50%

        //Distributes the total ticket(s) amount amongst the fees addresses
        lottochainWallet1Balance += fiftyPercent;
        lottochainWallet2Balance += fiftyPercent;

        //Emits the event of the purchase
        emit BuySuperTicket(msg.sender, superTicketPrice, superTicketsQuantity);
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
    
}