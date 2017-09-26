pragma solidity ^0.4.11;

import "./Owned.sol";

///@title TokenHolders Adds new Tokens to the Token Holders list; Draws a winner for the Token Holder prize.
///@author paulofelipe84 - paulo.barbosa@lottochain.io

contract TokenHolders is Owned, mortal{

    address tokensWallet = 0x6Cb999135AF163f396d87C50b8DA132b516dbe64;

    address[] thList;
    
    ///@dev Defines the Token Holders prize wallet
    ///@param walletAddress The Token Holders prize wallet address
    function defineWallet(address walletAddress) onlyOwner{

        tokensWallet = walletAddress;
        
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
        	
        	uint hashDraw = uint(hashDraw1) + uint(hashDraw2);
                
            uint drawIndex = hashDraw % thList.length;

            address drawnTH = thList[drawIndex];

            //Re-organizes the Token Holder list by copying the last position address to the drawn position
            //That doesn't affect the drawn since the index is randomically generated so every 
            //position in the list has the same chances.
            thList[drawIndex] = thList[thList.length-1];

            //Removes the last position address since it was copied to the position of the drawn Token Holder address
            thList.length--;

            //Transfers the prize to the winner Token Holder
            drawnTH.transfer(msg.value);

            return drawnTH;
        
        } else {
            revert();
        }

    }
    
}
