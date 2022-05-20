const ERC20TokenBridge = artifacts.require("ERC20TokenBridge");

const { deployProxy } = require('@openzeppelin/truffle-upgrades');

module.exports = async function (deployer) {
  // NOTE: DO CHANGE THE CONTRACT ADDRESS IN THE PARAMETER
  await deployProxy(ERC20TokenBridge, { deployer});
};

// module.exports = function (deployer) {
//   deployer.deploy(ERC20TokenBridge,"0xd5930c307d7395ff807f2921f12c5eb82131a789");
// };
