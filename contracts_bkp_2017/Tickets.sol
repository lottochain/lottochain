pragma solidity ^0.4.11;

import "./Owned.sol";
import "./SafeMath.sol";

///@title Tickets deals with whole lifecycle of a Ticket: 
///Adds to and Draws from daily, weekly and monthly prize lists.
///@author paulofelipe84 - paulo.barbosa@lottochain.io
contract Tickets is Owned, mortal, SafeMath{
    
    address public weeklyWallet = 0xc7c10a2c7b32481dF9d352f18894d3e3Ba37d868;
    address public dailyWallet = 0xa792C5B630f9197214Ab7ACFf28d16FaC1530240;
    address public monthlyWallet = 0x28b48BD5afb12B3c562eF17Ac9d00201695Fbf5A;

    address public lottoChainWallet = 0xC10AD05948140A3607B2cB6ee72898a3DbAA28a0;
    
    address public superTicketsWallet = 0x8059703cfFcbA7dbacF5Ba40603A02b6Da8a6B47;

    address public lc1 = 0xbF10888506525CBa498508d8a97Bd01991e9Fe67;
    address public lc2 = 0x13BeE6ab76B96246E6FCEFA620348ebF78A713a0;
    address public lc3 = 0x1E60d97D8804d5Cf68EDdB53E2D0B8c3511c5Fff;

    uint public dailyTicketsIndex;
    uint public weeklyTicketsIndex;
    uint public monthlyTicketsIndex;

    mapping (uint => address) public dailyTickets;
    mapping (uint => address) public weeklyTickets;
    mapping (uint => address) public monthlyTickets;
    
    
    ///@dev Defines the main wallets for the application to work
    ///@param walletType Type of the wallet to be defined:
    /*
        1 - daily
        2 - weekly
        3 - monthly
        4 - LottoChain
        5 - SuperTickets
        6 - lc1
        7 - lc2
        8 - lc3
    */
    ///@param walletAddress Address of the wallet to be defined
    function defineWallet(uint walletType, address walletAddress) onlyOwner public{

        if(walletType == 1){
            dailyWallet = walletAddress;
        }else if(walletType == 2){
            weeklyWallet = walletAddress;
        }else if(walletType == 3){
            monthlyWallet = walletAddress;
        }else if(walletType == 4){
            lottoChainWallet = walletAddress;
        }else if(walletType == 5){
            superTicketsWallet = walletAddress;
        }else if(walletType == 6){
            lc1 = walletAddress;
        }else if(walletType == 7){
            lc2 = walletAddress;
        }else if(walletType == 8){
            lc3 = walletAddress;
        }else {
            revert();
        }
    }
    

   ///@dev Adds a Ticket address to the daily, weekly and monthly draw lists
    ///@param ticketAddress Address of the ticket purchased, where the prize will be transferred to
    ///@param ticketQuantity Quantity of tickets purchased
    function addTicket(address ticketAddress, uint ticketQuantity) onlyOwner payable public{

        require(ticketQuantity > 0 && ticketQuantity <= 330);
        //Adds the address to each drawing list, as many times as the purchased tickets
        while(ticketQuantity > 0){
            dailyTicketsIndex++;
            dailyTickets[dailyTicketsIndex] = ticketAddress;

            weeklyTicketsIndex++;
            weeklyTickets[weeklyTicketsIndex] = ticketAddress;

            monthlyTicketsIndex++;
            monthlyTickets[monthlyTicketsIndex] = ticketAddress;

            ticketQuantity--;
        }
        //Distributes the total ticket(s) amount amongst the prize and fees addresses
        dailyWallet.transfer(div(msg.value,2)); // 50%
        weeklyWallet.transfer(div(msg.value,5)); // 20%
        monthlyWallet.transfer(div(msg.value,10)); // 10%

        lottoChainWallet.transfer(div(msg.value,10)); // 10% 
        
        superTicketsWallet.transfer(div(msg.value,10)); // 10%
        
    }    

    ///@dev Draws the winning ticket and transfers the prize to its wallet address
    ///@param dwm The type of Draw: 1 = Daily, 2 = Weekly, 3 = Monthly
    ///@param hashDraw1 First Hash to compose the draw seed
    ///@param hashDraw2 Second Hash to compose the draw seed
    function drawWinner(uint dwm, address hashDraw1, address hashDraw2) payable public returns(address){
    
        require(dwm == 1 || dwm == 2 || dwm == 3);

        require(msg.sender == dailyWallet || msg.sender == weeklyWallet || msg.sender == monthlyWallet);

        uint drawIndex;

        address drawnAddress;
        
        //Daily Draw
        if(dwm == 1 && dailyTicketsIndex > 0 && msg.sender == dailyWallet){
            //Derives the index of the Winner
            drawIndex = (add(uint(hashDraw1),uint(hashDraw2))) % dailyTicketsIndex + 1;

            if(drawIndex <= dailyTicketsIndex){
                //Finds the address related to the index in the Daily Tickets list
                drawnAddress = dailyTickets[drawIndex];
                //Resets the index so the list is reinitialized
                dailyTicketsIndex = 0;

            } else {
                revert();
            }

        //Weekly Draw
        } else if(dwm == 2 && weeklyTicketsIndex > 0 && msg.sender == weeklyWallet){
            //Deriving the index of the Winner
            drawIndex = (add(uint(hashDraw1),uint(hashDraw2))) % weeklyTicketsIndex + 1;
        
            if(drawIndex <= weeklyTicketsIndex){
                //Finds the address related to the index in the Daily Tickets list
                drawnAddress = weeklyTickets[drawIndex];
                //Resets the index so the list is reinitialized
                weeklyTicketsIndex = 0;

            } else {
                revert();
            }

        //Monthly Draw
        } else if(dwm == 3 && monthlyTicketsIndex > 0 && msg.sender == monthlyWallet){
            //Deriving the index of the Winner
            drawIndex = (add(uint(hashDraw1),uint(hashDraw2))) % monthlyTicketsIndex + 1;

            if(drawIndex <= monthlyTicketsIndex){
                //Finds the address related to the index in the Daily Tickets list
                drawnAddress = monthlyTickets[drawIndex];
                //Resets the index so the list is reinitialized
                monthlyTicketsIndex = 0;

            } else {
                revert();
            }

        } else {
            revert();
        }
        //Transfers the prize to the winning Ticket Holder

        //Dev fee 1 (1.5%)
        lc1.transfer(mul(div(msg.value,1000),15));
        //Dev fee 2 (1.5%)
        lc2.transfer(mul(div(msg.value,1000),15));
        //Dev fee 3 (1.5%)
        lc3.transfer(mul(div(msg.value,1000),15));

        //Transfers total amount minus dev fees (100% - 4.5% = 95.5%)
        drawnAddress.transfer(mul(div(msg.value,1000),955));

        return drawnAddress;
    }
    
}