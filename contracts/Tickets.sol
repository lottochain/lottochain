pragma solidity ^0.4.0;

import "./Owned.sol";

contract Tickets is mortal{
    
    uint userDailyIndex;
    uint userWeeklyIndex;
    uint userMonthlyIndex;
    
    mapping (uint => address) dailyTickets;
    mapping (uint => address) weeklyTickets;
    mapping (uint => address) monthlyTickets;
    
    function addTicket(address _from){
        userDailyIndex++;
        dailyTickets[userDailyIndex] = _from;
        
        userWeeklyIndex++;
        weeklyTickets[userWeeklyIndex] = _from;
        
        userMonthlyIndex++;
        monthlyTickets[userMonthlyIndex] = _from;
        
    }
    
    function TicketCounts(bytes1 dwm) returns(uint){
        if(dwm=="d"){
            return userDailyIndex;
        } else if(dwm=="w"){
            return userWeeklyIndex;
        } else if(dwm=="m"){
            return userMonthlyIndex;
        } else {
            revert();
        }
    }
    
    function pickTicket(bytes1 dwm, uint pickIndex) returns(address){
        if(dwm=="d"){
            if(pickIndex <= userDailyIndex){
                return dailyTickets[pickIndex];
            } else {
                revert();
            }
        } else if(dwm=="w"){
            if(pickIndex <= userWeeklyIndex){
                return weeklyTickets[pickIndex];
            } else {
                revert();
            }
        } else if(dwm=="m"){
            if(pickIndex <= userMonthlyIndex){
                return monthlyTickets[pickIndex];
            } else {
                revert();
            }
        } else {
            revert();
        }
    }
    
    function cleanTickets(bytes1 dwm){
        if(dwm=="d"){
            userDailyIndex = 0;
        } else if(dwm=="w"){
            userWeeklyIndex = 0;
        } else if(dwm=="m"){
            userMonthlyIndex = 0;
        } else {
            revert();
        }
        
    }
    
}
