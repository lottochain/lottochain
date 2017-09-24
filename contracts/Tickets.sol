import "./Owned.sol";

///@title Tickets deals with whole lifecycle of a Ticket: 
///Adds to and Draws from daily, weekly and monthly prize lists.
///@author paulofelipe84 - paulo.barbosa@lottochain.io
contract Tickets is Owned, mortal{
    
    //Temporary hardcoded addresses for private network testing sake
    
    address public dailyWallet = 0x7d24C8680df4b7C8a0a53dD24a2eb94Cb650C49c;
    address public weeklyWallet = 0xA1BaF2564F390B3aa301B113DA963b2947E1DCA2;
    address public monthlyWallet = 0x4aFEaE22Df54A444B345fA9ad7F86c1f6d93DA1A;
    
    address public lcWallet = 0xd21dA997FA88f4ea0675184b5900922EF65cB8b0;
    address public tokensWallet = 0x6Cb999135AF163f396d87C50b8DA132b516dbe64;

    address public lc1 = 0x315925032aE6849190CDe75954FaD9e1f36b2731;
    address public lc2 = 0xe54BaBB09a427F413D77A0df934B8920aB20DE89;
    address public lc3 = 0x10f14dDd6df1a6469a878f215492dd58461e64b2;

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
    function defineWallet(uint walletType, address walletAddress) onlyOwner{

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
        
        dailyWallet.transfer(msg.value/2); // 50%
        weeklyWallet.transfer(msg.value*20/100); // 20%
        monthlyWallet.transfer(msg.value*10/100); // 10%

        lcWallet.transfer(msg.value*10/100); // 10% 
        tokensWallet.transfer(msg.value*10/100); // 10%
        
    }    

    ///@dev Draws the winning ticket and transfers the prize to its wallet address
    ///@param dwm The type of Draw: 1 = Daily, 2 = Weekly, 3 = Monthly
    ///@param hashDraw1 First Hash to compose the draw seed
    ///@param hashDraw2 Second Hash to compose the draw seed
    function drawWinner(uint dwm, address hashDraw1, address hashDraw2) payable returns(address){
    
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

        drawnAddress.transfer(msg.value/1000*955); // Transfers total amount minus taxes

        lc1.transfer(msg.value/1000*15); // Taxes 1
        lc2.transfer(msg.value/1000*15); // Taxes 2
        lc3.transfer(msg.value/1000*15); // Taxes 3

        return drawnAddress;
    }
    
}
