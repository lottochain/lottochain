pragma solidity ^0.4.0;

import "./Owned.sol";

///@title Tickets deals with whole lifecycle of a Ticket: 
///Adds to and Draws from daily, weekly and monthly prize lists.
///@author paulofelipe84 - paulo.barbosa@lottochain.io
contract Tickets is Owned, mortal{
    
    address public dailyWallet;
    address public weeklyWallet;
    address public monthlyWallet;

    address public lcWallet;
    address public tokensWallet;

    address public lc1;
    address public lc2;
    address public lc3;

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
        5 - tokens
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
            lcWallet = walletAddress;
        }else if(walletType == 5){
            tokensWallet = walletAddress;
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

        require(ticketQuantity <= 10);

        while(ticketQuantity > 0){
            dailyTicketsIndex++;
            dailyTickets[dailyTicketsIndex] = ticketAddress;

            weeklyTicketsIndex++;
            weeklyTickets[weeklyTicketsIndex] = ticketAddress;

            monthlyTicketsIndex++;
            monthlyTickets[monthlyTicketsIndex] = ticketAddress;

            ticketQuantity--;
        }
        
        dailyWallet.transfer(msg.value/2); // 50%
        weeklyWallet.transfer(msg.value/5); // 20%
        monthlyWallet.transfer(msg.value/10); // 10%

        lcWallet.transfer(msg.value/10); // 10% 
        tokensWallet.transfer(msg.value/10); // 10%
        
    }    

    ///@dev Draws the winning ticket and transfers the prize to its wallet address
    ///@param dwm The type of Draw: 1 = Daily, 2 = Weekly, 3 = Monthly
    ///@param hashDraw1 First Hash to compose the draw seed
    ///@param hashDraw2 Second Hash to compose the draw seed
    function drawWinner(uint dwm, address hashDraw1, address hashDraw2) payable public returns(address){
    
        uint drawIndex;

        address drawnAddress;
        
        //Daily Draw
        if(dwm == 1 && dailyTicketsIndex > 0 && msg.sender == dailyWallet){
 
            drawIndex = (uint(hashDraw1) + uint(hashDraw2)) % dailyTicketsIndex + 1;

            if(drawIndex <= dailyTicketsIndex){

                drawnAddress = dailyTickets[drawIndex];
                dailyTicketsIndex = 0;

            } else {
                revert();
            }

        //Weekly Draw
        } else if(dwm == 2 && weeklyTicketsIndex > 0 && msg.sender == weeklyWallet){
            
            drawIndex = (uint(hashDraw1) + uint(hashDraw2)) % weeklyTicketsIndex + 1;
        
            if(drawIndex <= weeklyTicketsIndex){

                drawnAddress = weeklyTickets[drawIndex];
                weeklyTicketsIndex = 0;

            } else {
                revert();
            }

        //Monthly Draw
        } else if(dwm == 3 && monthlyTicketsIndex > 0 && msg.sender == monthlyWallet){
            
            drawIndex = (uint(hashDraw1) + uint(hashDraw2)) % monthlyTicketsIndex + 1;

            if(drawIndex <= monthlyTicketsIndex){

                drawnAddress = monthlyTickets[drawIndex];
                monthlyTicketsIndex = 0;

            } else {
                revert();
            }

        } else {
            revert();
        }

        drawnAddress.transfer(msg.value/1000*955); // Transfers total amount minus fees (95%)

        lc1.transfer(msg.value/1000*15); // Fee 1 (1.5%)
        lc2.transfer(msg.value/1000*15); // Fee 2 (1.5%)
        lc3.transfer(msg.value/1000*15); // Fee 3 (1.5%)

        return drawnAddress;
    }
    
}
