pragma solidity ^0.4.11;

import "./Owned.sol";
import "./SafeMath.sol";

///@title SuperTickets deals with whole lifecycle of a Super Ticket: 
///Adds to and Draws from addresses list.
///@author paulofelipe84 - paulo.barbosa@lottochain.io
contract SuperTickets is Owned, mortal, SafeMath{
    
    address public superTicketsWallet = 0xe65e2d09e9a61e8b4db011e3ae759eecb212a505;

    address public lc1 = 0xEd4a3c84FDdF26de12b2a5b5D7C4b36d7156b5DB;
    address public lc2 = 0xdc962Fbe3155f37E45f3A5c4813a6a25F1A29De8;
    address public lc3 = 0x5D3Bf09dF458D100328fa5e4C6a078ffFd51c232;

    address[] public superTickets;
    
    event AddSuperTicket(address stPrizeAddress, uint stPrizeAddressIndex);
    event DrawSuperTicket(address hashDraw1, address hashDraw2, address winner, uint prize);
    
    ///@dev Defines the main wallets for the application to work
    ///@param walletType Type of the wallet to be defined:
    /*  
        Maintaning same codes as Tickets contract to keep consistency
        5 - SuperTickets
        6 - lc1
        7 - lc2
        8 - lc3
    */
    ///@param walletAddress Address of the wallet to be defined
    function defineWallet(uint walletType, address walletAddress) public onlyOwner{

        if(walletType == 5){
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

    ///@dev Adds a new Super Ticket to the list
    ///@param stPrizeAddress The wallet address where the Super Ticket owner will receive their prize
    ///@param stPurchasedQuantity The amount of SuperTickets purchased. Each SuperTicket grants 
    ///a position in the list for the prize draw.
    function addSuperTicket(address stPrizeAddress, uint stPurchasedQuantity) public onlyOwner{
        //Limits the amount of tickets per transaction
        require(stPurchasedQuantity > 0 && stPurchasedQuantity <= 330);

        //Adds the address to the drawing list, as many times as the purchased SuperTickets
        while(stPurchasedQuantity > 0){

            superTickets.push(stPrizeAddress);

            AddSuperTicket(stPrizeAddress, superTickets.length);

            stPurchasedQuantity--;
        }
                
    }

    ///@dev Drawns a Super Ticket address from the List
    ///@param hashDraw1 First Hash to compose the draw seed
    ///@param hashDraw2 Second Hash to compose the draw seed
    ///@return Drawn Super Ticket holder address
    function drawSuperTicket(address hashDraw1, address hashDraw2) public payable returns(address){
        
        require(msg.sender == superTicketsWallet);

        require(superTickets.length > 0);

        //Derives the index of the Winner    
        uint drawIndex = add(uint(hashDraw1),uint(hashDraw2)) % superTickets.length;
        
        //Finds the address related to the index in the SuperTickets list
        address drawnAddress = superTickets[drawIndex];

        //Re-organizes the Super Tickets list by copying the last position address to the drawn position
        //That doesn't affect the draw fairness since the index is randomically generated, hence every 
        //position in the list has the same chances of being picked.
        superTickets[drawIndex] = superTickets[superTickets.length-1];

        //Removes the last position address since it was copied to the position of the drawn Super Ticket address
        superTickets.length--;

        //Transfers the prize to the winning SuperTicket Holder

        //Dev fee 1 (1.5%)
        lc1.transfer(mul(div(msg.value,1000),15));
        //Dev fee 2 (1.5%)
        lc2.transfer(mul(div(msg.value,1000),15));
        //Dev fee 3 (1.5%)
        lc3.transfer(mul(div(msg.value,1000),15));
        
        //Transfers total amount minus dev fees (100% - 4.5% = 95.5%)
        drawnAddress.transfer(mul(div(msg.value,1000),955));

        DrawSuperTicket(hashDraw1, hashDraw2, drawnAddress, msg.value);

        return drawnAddress;

    }
    
}
