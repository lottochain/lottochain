var Tickets =  artifacts.require("./Tickets.sol");

module.exports = function(deployer) {
  deployer.deploy(Tickets);
};
