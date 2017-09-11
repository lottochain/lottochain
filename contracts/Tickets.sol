import "./Owned.sol";

contract Tickets is Owned, mortal{
    
    uint ticketDailyIndex;
    uint ticketWeeklyIndex;
    uint ticketMonthlyIndex;

    address mainWallet = 0xf14E5661f99818eb07FD6A0c593dFe70ceD96E25;

    address dailyWallet = 0xbAA886699b79e8E1048a0F4B6cDcC814392da218;
    address weeklyWallet = 0x957E5bA48aE5DF08768f802130BD38af9f2B40a4;
    address monthlyWallet = 0xD7c0dbF7bEd9b104E8DCBF73fED834cFD2451726;
    
    address lcWallet = 0x27A1fC31cb146B9A97A32f79DBa93E4920b056C8;
    address tokensWallet = 0x9394c3c1CdeEb01736Ace0CF65B77d8279504797;

    address lc1 = 0xa3744Cc050A533FeDD48BF944ceDF52c49967240;
    address lc2 = 0xACE95bD646A6ed7a8c17EB263157Bf03eDAEe7eB;
    address lc3 = 0x9dDAc2fdC17D3ED37fbAf11dA8323F6FA6BB295E;
    
    

    function defineWallet(uint walletType, address walletAddress) onlyOwner{
        /*
            1 - main
            2 - daily
            3 - weekly
            4 - monthly
            5 - LottoChain
            6 - tokens
            7 - lc1
            8 - lc2
            9 - lc3
        */

        if(walletType == 1){
            mainWallet = walletAddress;
        }else if(walletType == 2){
            dailyWallet = walletAddress;
        }else if(walletType == 3){
            weeklyWallet = walletAddress;
        }else if(walletType == 4){
            monthlyWallet = walletAddress;
        }else if(walletType == 5){
            lcWallet = walletAddress;
        }else if(walletType == 6){
            tokensWallet = walletAddress;
        }else if(walletType == 7){
            lc1 = walletAddress;
        }else if(walletType == 8){
            lc2 = walletAddress;
        }else if(walletType == 9){
            lc3 = walletAddress;
        }else {
            revert();
        }
    }

    
    function() payable{
        
    }
    
    mapping (uint => address) dailyTickets;
    mapping (uint => address) weeklyTickets;
    mapping (uint => address) monthlyTickets;
    
    function addTicket(address ticketAddress) onlyOwner payable returns(uint){

        ticketDailyIndex++;
        dailyTickets[ticketDailyIndex] = ticketAddress;
        dailyWallet.transfer(msg.value/2);
        
        ticketWeeklyIndex++;
        weeklyTickets[ticketWeeklyIndex] = ticketAddress;
        weeklyWallet.transfer(msg.value*20/100);
        
        ticketMonthlyIndex++;
        monthlyTickets[ticketMonthlyIndex] = ticketAddress;
        monthlyWallet.transfer(msg.value*10/100);

        lcWallet.transfer(msg.value*10/100);
        tokensWallet.transfer(msg.value*10/100);
        
    }
    
    // Convention
    // dwm: 1 = Daily, 2 = Weekly, 3 = Monthly
    
    function pickTicket(uint dwm, uint pickIndex) returns(address){
        if(dwm == 1){
            if(pickIndex <= ticketDailyIndex){
                return dailyTickets[pickIndex];
            } else {
                revert();
            }
        } else if(dwm == 2){
            if(pickIndex <= ticketWeeklyIndex){
                return weeklyTickets[pickIndex];
            } else {
                revert();
            }
        } else if(dwm == 3){
            if(pickIndex <= ticketMonthlyIndex){
                return monthlyTickets[pickIndex];
            } else {
                revert();
            }
        } else {
            revert();
        }
    }
    
    function cleanTickets(uint dwm){
    //aiming to save gas.
    //Only reset the number of tickets instead of deleting the whole mapping.
        
        if(dwm == 1 && msg.sender == dailyWallet){
            ticketDailyIndex = 0;
        } else if(dwm == 2 && msg.sender == weeklyWallet){
            ticketWeeklyIndex = 0;
        } else if(dwm == 3 && msg.sender == monthlyWallet){
            ticketMonthlyIndex = 0;
        } else {
            revert();
        }
        
    }
    
    function drawWinner(uint dwm, address hashDraw) payable{
    
        uint drawIndex;
        
        if(dwm == 1 && ticketDailyIndex > 0 && msg.sender == dailyWallet){
            drawIndex = uint(hashDraw) % ticketDailyIndex + 1;            
        } else if(dwm == 2 && ticketWeeklyIndex > 0 && msg.sender == weeklyWallet){
            drawIndex = uint(hashDraw) % ticketWeeklyIndex + 1;
        } else if(dwm == 3 && ticketMonthlyIndex > 0 && msg.sender == monthlyWallet){
            drawIndex = uint(hashDraw) % ticketMonthlyIndex + 1;
        } else {
            revert();
        }
        
        //drawnAddress = pickTicket(dwm,drawIndex);

        pickTicket(dwm,drawIndex).transfer(msg.value/1000*955);

        lc1.transfer(msg.value/1000*15);
        lc2.transfer(msg.value/1000*15);
        lc3.transfer(msg.value/1000*15);

        cleanTickets(dwm);
    }
    
}
