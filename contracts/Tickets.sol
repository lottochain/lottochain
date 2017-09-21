import "./Owned.sol";

///@title Tickets deals with whole lifecycle of a Ticket: 
///Adds to and Draws from daily, weekly and monthly prize lists.
///@author paulofelipe84 - paulofelipe@lottochain.io
contract Tickets is Owned, mortal{
    //Temporary hardcoded addresses for private network testing sake
    address mainWallet = 0xEa5D43daD6528806A72456f763aF213E9045781C;
    
    address dailyWallet = 0x7d24C8680df4b7C8a0a53dD24a2eb94Cb650C49c;
    address weeklyWallet = 0xA1BaF2564F390B3aa301B113DA963b2947E1DCA2;
    address monthlyWallet = 0x4aFEaE22Df54A444B345fA9ad7F86c1f6d93DA1A;
    
    address lcWallet = 0xd21dA997FA88f4ea0675184b5900922EF65cB8b0;
    address tokensWallet = 0x6Cb999135AF163f396d87C50b8DA132b516dbe64;

    address lc1 = 0x315925032aE6849190CDe75954FaD9e1f36b2731;
    address lc2 = 0xe54BaBB09a427F413D77A0df934B8920aB20DE89;
    address lc3 = 0x10f14dDd6df1a6469a878f215492dd58461e64b2;

    uint dailyTicketsIndex;
    uint weeklyTicketsIndex;
    uint monthlyTicketsIndex;

    mapping (uint => address) dailyTickets;
    mapping (uint => address) weeklyTickets;
    mapping (uint => address) monthlyTickets;
    
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
    
    function addTicket(address ticketAddress, uint ticketQuantity) onlyOwner payable{

        while(ticketQuantity > 0){
            dailyTicketsIndex++;
            dailyTickets[dailyTicketsIndex] = ticketAddress;

            weeklyTicketsIndex++;
            weeklyTickets[weeklyTicketsIndex] = ticketAddress;

            monthlyTicketsIndex++;
            monthlyTickets[monthlyTicketsIndex] = ticketAddress;

            ticketQuantity--;
        }
        
        dailyWallet.transfer(msg.value/2);
        weeklyWallet.transfer(msg.value*20/100);
        monthlyWallet.transfer(msg.value*10/100);

        lcWallet.transfer(msg.value*10/100);
        tokensWallet.transfer(msg.value*10/100);
        
    }
    
    // Convention
    // dwm: 1 = Daily, 2 = Weekly, 3 = Monthly
    
    function pickTicket(uint dwm, uint pickIndex) returns(address){
        if(dwm == 1){
            if(pickIndex <= dailyTicketsIndex){
                return dailyTickets[pickIndex];
            } else {
                revert();
            }
        } else if(dwm == 2){
            if(pickIndex <= weeklyTicketsIndex){
                return weeklyTickets[pickIndex];
            } else {
                revert();
            }
        } else if(dwm == 3){
            if(pickIndex <= monthlyTicketsIndex){
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
            dailyTicketsIndex = 0;
        } else if(dwm == 2 && msg.sender == weeklyWallet){
            weeklyTicketsIndex = 0;
        } else if(dwm == 3 && msg.sender == monthlyWallet){
            monthlyTicketsIndex = 0;
        } else {
            revert();
        }
        
    }
    
    function drawWinner(uint dwm, address hashDraw1, address hashDraw2) payable returns(address){
    
        uint drawIndex;

        address drawnAddress;

        uint hashDraw = uint(hashDraw1) + uint(hashDraw2);
        
        if(dwm == 1 && dailyTicketsIndex > 0 && msg.sender == dailyWallet){
            drawIndex = hashDraw % dailyTicketsIndex + 1;            
        } else if(dwm == 2 && weeklyTicketsIndex > 0 && msg.sender == weeklyWallet){
            drawIndex = hashDraw % weeklyTicketsIndex + 1;
        } else if(dwm == 3 && monthlyTicketsIndex > 0 && msg.sender == monthlyWallet){
            drawIndex = hashDraw % monthlyTicketsIndex + 1;
        } else {
            revert();
        }

        drawnAddress = pickTicket(dwm,drawIndex);

        drawnAddress.transfer(msg.value/1000*955);

        lc1.transfer(msg.value/1000*15);
        lc2.transfer(msg.value/1000*15);
        lc3.transfer(msg.value/1000*15);

        cleanTickets(dwm);

        return drawnAddress;
    }
    
}
