pragma solidity ^0.4.11;

contract Owned {

    address public owner = msg.sender;
    address public potentialOwner;

    modifier onlyOwner {
      require(msg.sender == owner);
      _;
    }

    modifier onlyPotentialOwner {
      require(msg.sender == potentialOwner);
      _;
    }

    event NewOwner(address old, address current);
    event NewPotentialOwner(address old, address potential);

    function setOwner(address _new)
      onlyOwner
    {
      NewPotentialOwner(owner, _new);
      potentialOwner = _new;
    }

    function confirmOwnership()
      onlyPotentialOwner
    {
      NewOwner(owner, potentialOwner);
      owner = potentialOwner;
      potentialOwner = 0;
    }
}

contract mortal is Owned{
    function kill(){
        if(msg.sender == owner)
            selfdestruct(owner);
    }
}


///@title TokenHolders Adds new Tokens to the Token Holders list; Draws a winner for the Token Holder prize.
///@author paulofelipe84 - paulo.barbosa@lottochain.io

contract TokenHolders is Owned, mortal{

    address tokensWallet = 0x6Cb999135AF163f396d87C50b8DA132b516dbe64;

    address[] thList;
    
    ///@dev Defines the wallets for the application to work
    ///@param walletType Type of the wallet to be defined:
    /*
        5 - tokens
        6 - lc1
        7 - lc2
        8 - lc3
    */
    ///@param walletAddress Address of the wallet to be defined
    function defineWallet(uint walletType, address walletAddress) onlyOwner{

        if(walletType == 5){
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

    ///@dev Adds a new Token to the Token Holders list
    ///@param thPrizeAddress The wallet address where the Token Holder will receive their prize
    ///@param thPurchasedQuantity The amount of Tokens purchased. Every single Token grants a position in the Token list for the Token Holder.
    function addTH(address thPrizeAddress, uint thPurchasedQuantity) onlyOwner{

        while(thPurchasedQuantity > 0){

            thList.push(thPrizeAddress);

            thPurchasedQuantity--;
        }
                
    }
    

    ///@dev Drawns a Token Holder address from the Token Holder List
    ///@param hashDraw1 First Hash to compose the draw seed
    ///@param hashDraw2 Second Hash to compose the draw seed
    ///@return Drawn Token Holder address
    function drawTH(address hashDraw1, address hashDraw2) payable returns(address){
        if(thList.length > 0 && msg.sender == tokensWallet){
                
            uint drawIndex = uint(hashDraw1) + uint(hashDraw2) % thList.length;

            address drawnTH = thList[drawIndex];

            //Re-organizes the Token Holder list by copying the last position address to the drawn position
            //That doesn't affect the drawn since the index is randomically generated so every 
            //position in the list has the same chances.
            thList[drawIndex] = thList[thList.length-1];

            //Removes the last position address since it was copied to the position of the drawn Token Holder address
            thList.length--;

            //Transfers the prize to the winner Token Holder
            drawnTH.transfer(msg.value/1000*955); // Transfers total amount minus fees (95%)

            lc1.transfer(msg.value/1000*15); // Fees 1 (1,5%)
            lc2.transfer(msg.value/1000*15); // Fees 2 (1,5%)
            lc3.transfer(msg.value/1000*15); // Fees 3 (1,5%)

            return drawnTH;
        
        } else {
            revert();
        }

    }
    
}
