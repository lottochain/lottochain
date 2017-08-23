pragma solidity ^0.4.0;

import "./Owned.sol";

contract Tickets is mortal{
    
    uint ticketDailyIndex;
    uint ticketWeeklyIndex;
    uint ticketMonthlyIndex;
    uint drawIndex;
    uint dailyDrawBlock;
    uint weeklyDrawBlock;
    uint monthlyDrawBlock;
    address drawnAddress;
    
    mapping (uint => address) dailyTickets;
    mapping (uint => address) weeklyTickets;
    mapping (uint => address) monthlyTickets;

    function addTicket(address _from) onlyOwner{
        ticketDailyIndex++;
        dailyTickets[ticketDailyIndex] = _from;
        
        ticketWeeklyIndex++;
        weeklyTickets[ticketWeeklyIndex] = _from;
        
        ticketMonthlyIndex++;
        monthlyTickets[ticketMonthlyIndex] = _from;
        
    }
    
    // Convention
    // dwm: d = Daily, w = Weekly, m = Monthly
    
    function ticketCounts(byte dwm) returns(uint){
        if(dwm=="d"){
            return ticketDailyIndex;
        } else if(dwm=="w"){
            return ticketWeeklyIndex;
        } else if(dwm=="m"){
            return ticketMonthlyIndex;
        } else {
            revert();
        }
    }
    
    function pickTicket(byte dwm, uint pickIndex) returns(address){
        if(dwm=="d"){
            if(pickIndex <= ticketDailyIndex){
                return dailyTickets[pickIndex];
            } else {
                revert();
            }
        } else if(dwm=="w"){
            if(pickIndex <= ticketWeeklyIndex){
                return weeklyTickets[pickIndex];
            } else {
                revert();
            }
        } else if(dwm=="m"){
            if(pickIndex <= ticketMonthlyIndex){
                return monthlyTickets[pickIndex];
            } else {
                revert();
            }
        } else {
            revert();
        }
    }
    
    function cleanTickets(byte dwm) onlyOwner{
    //aiming to save gas.
    //Only reset the number of tickets instead of deleting the whole mapping.
        
        if(dwm=="d"){
            ticketDailyIndex = 0;
        } else if(dwm=="w"){
            ticketWeeklyIndex = 0;
        } else if(dwm=="m"){
            ticketMonthlyIndex = 0;
        } else {
            revert();
        }
        
    }
    
    function drawWinner(byte dwm) onlyOwner returns(address){
    //hardcoding blocks hashes. later they'll be parameterized
    
        dailyDrawBlock = uint(0xca35b7d915458ef540ade6068dfe2f44e8fa733c);
        weeklyDrawBlock = uint(0x14723a09acff6d2a60dcdf7aa4aff308fddc160c);
        monthlyDrawBlock = uint(0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db);
        
        if(dwm=="d" && ticketDailyIndex > 0){
            drawIndex = dailyDrawBlock % ticketDailyIndex + 1;            
        } else if(dwm=="w" && ticketWeeklyIndex > 0){
            drawIndex = weeklyDrawBlock % ticketWeeklyIndex + 1;
        } else if(dwm=="m" && ticketMonthlyIndex > 0){
            drawIndex = monthlyDrawBlock % ticketMonthlyIndex + 1;
        } else {
            revert();
        }
        
        drawnAddress = pickTicket(dwm,drawIndex);
        cleanTickets(dwm);
        return drawnAddress;
    }
    
}