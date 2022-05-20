const ERC20TokenBridge = artifacts.require("ERC20TokenBridge");

const { deployProxy } = require('@openzeppelin/truffle-upgrades');

module.exports = async function (deployer) {

  await deployProxy(ERC20TokenBridge, { deployer});
};

