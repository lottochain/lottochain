//<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>


// Tokens para o serviço do blockcypher
//var tokens = [secret]

// hora do sorteio
var prizeHour = "T15:15:00Z"

//consulta ultimo bloco
var urlBTC = "https://api.blockcypher.com/v1/btc/main";
var urlETH = "https://api.blockcypher.com/v1/eth/main";

//consulta bloco especificado
var urlHeightBTC = "https://api.blockcypher.com/v1/btc/main/blocks/";
var urlHeightETH = "https://api.blockcypher.com/v1/eth/main/blocks/";

//Recupera os dois ultimos blocos do BTC/ETH
blockBTC = httpGetBlockAsObject(urlBTC);
blockETH = httpGetBlockAsObject(urlETH);

// Encontra o ultimo
var validBlocks = findFirstBlockAfterPrizetime(blockBTC, blockETH);

document.getElementById("lottochain").innerHTML = "HashBTC: " + validBlocks.btc.hash + "<br>" + "HashEth: " + validBlocks.eth.hash;

// Funcao de exemplo apenas. Recuper ao hash e exibe na tela e salva no console do javascript ao clicar no botão
function getBlockByUrl (url) {
	$(document).ready(function(){
  	  $("button").click(function(){
    	    $.get("https://api.blockcypher.com/v1/btc/main", function(data, status){
              if (status === "success") {
  	     	      alert("Data: " + data + "\nStatus: " + status);
	              alert("HASH: " + data.hash);
                console.log(data);
							} else {
                console.log("ERROR");
                alert ("ERRO NO GET na url:" + url);
							}
       	 });
    	});
	});
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

function findFirstBlockAfterPrizetime (blockBTC, blockETH) {
	counter = 0; // contador para rotacionar os tokens
  
  hashETH = blockETH.hash;
  timeETH = blockETH.time;
  blockHeightETH = blockETH.height;
  
  hashBTC = blockBTC.hash;
  timeBTC = blockBTC.time;
  blockHeightBTC = blockBTC.height;
  
  var YYYYMMDD = blockBTC.time.split("T").slice(0,1);
  var prizeTime = YYYYMMDD + prizeHour;
  
  // Timestamp do ultimo bloco BTC, ETH e do horario do sorteio
  var tsBTC = Math.round(+new Date(timeBTC));
  var tsETH = Math.round(+new Date(timeETH));
  var tsPrize = Math.round(+new Date(prizeTime));
  
  // funcao recursiva para validar se o bloco é realmente o primeiro pos horário do premio
  var checkBlock = function myself (lastBlock,timePrize,blockChain) {
    counter = counter % 5;
    
    if (blockChain == "btc") {
    	url = urlHeightBTC;
    }
    else if (blockChain == "eth") {
    	url = urlHeightETH;
    }

    heightPrev = lastBlock.height-1;
    url = url+heightPrev+"?token="+tokens[counter];
    previousBTC = httpGetBlockAsObject(url);
    
    ts = Math.round(+new Date(lastBlock.time));
    tsPrev = Math.round(+new Date(previousBTC.time));
    
    if (ts <= timePrize) {
        return "ERROR: BLOCK ANTERIOR AO HORARIO DO PREMIO";
    }
    else if (tsPrev <= ts && tsPrev > timePrize) {
    		counter++;
		    return checkBlock(previousBTC,timePrize,blockChain);

    }
    return lastBlock;
  }
  typeof myself === 'undefined';
  
  
  var btcValidBlock = checkBlock(blockBTC,tsPrize,"btc");
  var ethValidBlock = checkBlock(blockETH,tsPrize,"eth");
  
  return {
        eth: ethValidBlock,
        btc: btcValidBlock
    };
    
 //  document.getElementById("lottochain").innerHTML = "HashBTC: " + hashBTC + "<br>" + "TimestampBTC: " + timeBTC + "<br>" + "HeightBTC: " + blockBTC.height+ "<br> SORTEIO HORA:" + prizeTime + "<br>" + "TimestampBTCVALIDO: " + btcValidBlock.time + "<br>" + "<br>" + "HashETH: " + hashETH + "<br>" + "TimestampETH: " + timeETH + "<br>" + "HeightETH: " + blockETH.height+ "<br> SORTEIO HORA:" + prizeTime + "<br>" + "TimestampETHVALIDO: " + ethValidBlock.time;

}

function httpGetBlockAsObject(theUrl) {
  var xmlHttp = null;
  xmlHttp = new XMLHttpRequest();
  xmlHttp.open( "GET", theUrl, false );
  xmlHttp.send( null );
  var jsonResponse = JSON.parse(xmlHttp.responseText);
  return jsonResponse;
}
