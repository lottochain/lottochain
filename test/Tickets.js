var Tickets = artifacts.require("./Tickets.sol");

contract("Tickets", function(accounts){
  it('should be possible to add a new Ticket', function(){
    var contractInstance;
    Tickets.deployed().then(function(instance){
      contractInstance = instance;
      return contractInstance.addTicket("0xca4b9d1dc8be922f62a5f698ff927848b143a244", 1, {from: "0x84dc5b0a9e4b9123212f9ebc605366644387582a", value: 15000000000000000, gas: 1000000, gasPrice: 27000000000});
    }).then(function(tx){
       console.log(tx);
    });
  });
});
